import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:signature/signature.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/ai/roboflow_service.dart';
import '../../../../core/ai/ocr_service.dart';

class ReportCreatePageNew extends StatefulWidget {
  const ReportCreatePageNew({super.key});

  @override
  State<ReportCreatePageNew> createState() => _ReportCreatePageNewState();
}

class _ReportCreatePageNewState extends State<ReportCreatePageNew> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _signatureController = SignatureController(
    penStrokeWidth: 2,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  // 이미지 관련
  final List<File> _selectedImages = []; // 실제 이미지 파일들
  final List<String> _selectedImageTypes = []; // 더미 이미지 타입 저장 (테스트용)
  final List<ObjectDetectionResult> _detectionResults = [];
  final List<OCRResult> _ocrResults = [];
  final ImagePicker _imagePicker = ImagePicker();

  // 위치 관련
  Position? _currentPosition;

  // 폼 데이터
  String _selectedCategory = '기타';
  String _selectedPriority = '보통';
  bool _isProcessing = false;

  // 하이브리드 AI 분석 관련
  int _primaryImageIndex = -1; // 대표 이미지 인덱스
  bool _hasComplexIssue = false; // 복합 민원 플래그
  List<String> _conflictingCategories = []; // 충돌하는 카테고리들
  String _complexIssueDescription = ''; // 복합 민원 설명
  
  // API 키 상태 관리
  bool _hasValidApiKey = false;

  final List<String> _categories = [
    '도로/교통',
    '환경/위생',
    '상하수도',
    '전기/조명',
    '건축물',
    '공원/시설물',
    '공사/안전',
    '기타',
  ];

  final List<String> _priorities = ['긴급', '높음', '보통', '낮음'];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _checkApiKeyStatus();
  }
  
  /// API 키 상태 확인
  Future<void> _checkApiKeyStatus() async {
    final hasValidKey = await RoboflowService.hasValidApiKey;
    setState(() {
      _hasValidApiKey = hasValidKey;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _signatureController.dispose();
    super.dispose();
  }

  /// 현재 위치 가져오기
  Future<void> _getCurrentLocation() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final requestedPermission = await Geolocator.requestPermission();
        if (requestedPermission == LocationPermission.denied) {
          throw Exception('위치 권한이 거부되었습니다');
        }
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      setState(() {
        _currentPosition = position;
      });
    } catch (e) {
      debugPrint('Location error: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('위치 정보를 가져올 수 없습니다: $e')));
      }
    }
  }

  /// 이미지 선택 (더미 기능)
  Future<void> _selectImage(String source) async {
    if (_selectedImages.length >= 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('최대 10장까지 첨부할 수 있습니다'))
      );
      return;
    }

    try {
      XFile? pickedFile;
      
      if (source == '카메라') {
        pickedFile = await _imagePicker.pickImage(
          source: ImageSource.camera,
          maxWidth: 1920,
          maxHeight: 1920,
          imageQuality: 85,
        );
      } else if (source == '갤러리') {
        pickedFile = await _imagePicker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 1920,
          maxHeight: 1920,
          imageQuality: 85,
        );
      }

      if (pickedFile != null) {
        final imageFile = File(pickedFile.path);
        await _addImageAndAnalyze(imageFile, source);
      }
    } catch (e) {
      debugPrint('Image selection error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('이미지 선택 중 오류가 발생했습니다: $e'))
      );
    }
  }

  /// 실제 이미지 추가 및 AI 분석
  Future<void> _addImageAndAnalyze(File imageFile, String source) async {
    setState(() {
      _isProcessing = true;
      _selectedImages.add(imageFile);
      _selectedImageTypes.add(source);
    });

    try {
      // 실제 Roboflow AI 분석 실행
      final objectDetection = await RoboflowService.instance.detectObjects(imageFile);
      final ocrResult = await OCRService.instance.extractText(imageFile);

      _detectionResults.add(objectDetection);
      _ocrResults.add(ocrResult);

      // 첫 번째 이미지인 경우에만 기본 AI 추천 적용
      if (_selectedImages.length == 1) {
        final recommendedCategory = RoboflowService.recommendCategory(
          objectDetection.detections,
        );
        final recommendedPriority = RoboflowService.recommendPriority(
          objectDetection.detections,
        );

        setState(() {
          _selectedCategory = recommendedCategory;
          _selectedPriority = recommendedPriority;
        });

        // 자동 제목 생성
        if (_titleController.text.isEmpty && objectDetection.hasDetections) {
          final mainObject = objectDetection.detections.first;
          _titleController.text = '${mainObject.koreanName} 신고';
        }

        // OCR 결과 활용
        if (ocrResult.hasText && ocrResult.extractedInfo.hasUsefulInfo) {
          final extractedInfo = ocrResult.extractedInfo;
          final autoDescription = StringBuffer();

          if (extractedInfo.primaryAddress.isNotEmpty) {
            autoDescription.writeln('위치: ${extractedInfo.primaryAddress}');
          }

          if (extractedInfo.keywords.isNotEmpty) {
            autoDescription.writeln(
              '관련 키워드: ${extractedInfo.keywords.join(', ')}',
            );
          }

          if (_descriptionController.text.isEmpty) {
            _descriptionController.text = autoDescription.toString();
          }
        }
      }

      // 복합 민원 검사 (2개 이상 이미지가 있을 때)
      if (_selectedImages.length > 1) {
        _checkForComplexIssues();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('AI 분석 완료: ${objectDetection.summary}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Image analysis error: $e');
      // 에러 발생 시 마지막 추가된 이미지 제거
      setState(() {
        if (_selectedImages.isNotEmpty) {
          _selectedImages.removeLast();
        }
        if (_selectedImageTypes.isNotEmpty) {
          _selectedImageTypes.removeLast();
        }
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('이미지 분석 중 오류가 발생했습니다: $e'))
        );
      }
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  /// 더미 이미지 생성 및 추가
  Future<void> _createDummyImage(String source) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      // 더미 이미지 타입을 선택된 이미지 목록에 추가
      setState(() {
        _selectedImageTypes.add(source);
      });

      // AI 분석 시뮬레이션 실행
      await _simulateImageAnalysis(source);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$source 테스트 이미지가 추가되었습니다'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      debugPrint('Dummy image creation error: $e');
      // 에러 발생 시 마지막 추가된 항목 제거
      if (_selectedImageTypes.isNotEmpty) {
        setState(() {
          _selectedImageTypes.removeLast();
        });
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('테스트 이미지 생성 중 오류가 발생했습니다: $e'))
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  /// 더미 이미지 분석 시뮬레이션
  Future<void> _simulateImageAnalysis(String imageType) async {
    try {
      // 더미 이미지 파일을 생성하여 AI 서비스로 분석
      final dummyImagePath = await _createDummyImageFile(imageType);
      final dummyFile = File(dummyImagePath);
      
      // 실제 Roboflow 서비스로 분석
      final objectDetection = await RoboflowService.instance.detectObjects(dummyFile);
      final ocrResult = await OCRService.instance.extractText(dummyFile);

      _detectionResults.add(objectDetection);
      _ocrResults.add(ocrResult);

      // 첫 번째 이미지인 경우에만 기본 AI 추천 적용
      final totalImages = _selectedImages.length + _selectedImageTypes.length;
      if (totalImages == 1) {
        final recommendedCategory = RoboflowService.recommendCategory(
          objectDetection.detections,
        );
        final recommendedPriority = RoboflowService.recommendPriority(
          objectDetection.detections,
        );

        setState(() {
          _selectedCategory = recommendedCategory;
          _selectedPriority = recommendedPriority;
        });

        // 자동 제목 생성
        if (_titleController.text.isEmpty && objectDetection.hasDetections) {
          final mainObject = objectDetection.detections.first;
          _titleController.text = '${mainObject.koreanName} 신고';
        }

        // OCR 결과 활용 (시뮬레이션)
        if (ocrResult.hasText && ocrResult.extractedInfo.hasUsefulInfo) {
          final extractedInfo = ocrResult.extractedInfo;
          final autoDescription = StringBuffer();

          if (extractedInfo.primaryAddress.isNotEmpty) {
            autoDescription.writeln('위치: ${extractedInfo.primaryAddress}');
          }

          if (extractedInfo.keywords.isNotEmpty) {
            autoDescription.writeln(
              '관련 키워드: ${extractedInfo.keywords.join(', ')}',
            );
          }

          if (_descriptionController.text.isEmpty) {
            _descriptionController.text = autoDescription.toString();
          }
        }
      }

      // 복합 민원 검사 (2개 이상 이미지가 있을 때)
      if (totalImages > 1) {
        _checkForComplexIssues();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('AI 분석 완료: ${objectDetection.summary}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Image analysis error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('이미지 분석 중 오류가 발생했습니다: $e'))
        );
      }
    }
  }

  /// 더미 이미지 파일 생성 (테스트용)
  Future<String> _createDummyImageFile(String type) async {
    // 임시 파일 경로 생성 (타입에 따라 다른 이름 패턴)
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    String fileName;
    
    switch (type) {
      case '도로 파손':
        fileName = 'road_damage_$timestamp.jpg';
        break;
      case '환경 문제':
        fileName = 'environment_issue_$timestamp.jpg';
        break;
      case '시설물 파손':
        fileName = 'facility_damage_$timestamp.jpg';
        break;
      case '복합 문제':
        fileName = 'complex_issue_$timestamp.jpg';
        break;
      default:
        fileName = 'test_${type.toLowerCase()}_$timestamp.jpg';
        break;
    }
    
    return '/tmp/$fileName';
  }

  /// 이미지 제거
  void _removeImage(int index) {
    setState(() {
      // 실제 이미지 파일 제거
      if (index < _selectedImages.length) {
        _selectedImages.removeAt(index);
      }
      
      // 테스트 타입 제거 
      if (index < _selectedImageTypes.length) {
        _selectedImageTypes.removeAt(index);
      }
      
      // 분석 결과도 함께 제거
      if (index < _detectionResults.length) {
        _detectionResults.removeAt(index);
      }
      if (index < _ocrResults.length) {
        _ocrResults.removeAt(index);
      }
      
      // 대표 이미지 인덱스 조정
      if (_primaryImageIndex == index) {
        _primaryImageIndex = -1; // 대표 이미지가 삭제되면 초기화
      } else if (_primaryImageIndex > index) {
        _primaryImageIndex--; // 인덱스 조정
      }
      
      // 복합 민원 다시 검사
      if (_selectedImages.length > 1) {
        _checkForComplexIssues();
      } else {
        // 이미지가 1개 이하면 복합 민원 플래그 제거
        _hasComplexIssue = false;
        _conflictingCategories.clear();
        _complexIssueDescription = '';
      }
    });
  }

  /// 신고서 제출
  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImages.isEmpty && _selectedImageTypes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('최소 1장의 사진을 첨부해주세요'))
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      // 서명 이미지 생성 (TODO: 실제 전송 시 사용)
      await _signatureController.toPngBytes();

      // TODO: 실제 API 호출로 교체
      // 제출 데이터에 복합 민원 정보 포함
      final submitData = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'category': _selectedCategory,
        'priority': _selectedPriority,
        'location': _currentPosition != null ? {
          'latitude': _currentPosition!.latitude,
          'longitude': _currentPosition!.longitude,
        } : null,
        'images': _selectedImages.asMap().entries.map((entry) => {
          'index': entry.key,
          'path': entry.value.path,
          'isPrimary': entry.key == _primaryImageIndex,
        }).toList(),
        'testImages': _selectedImageTypes.asMap().entries.map((entry) => {
          'index': entry.key,
          'type': entry.value,
          'isPrimary': entry.key == _primaryImageIndex,
        }).toList(),
        'aiAnalysis': {
          'detectionResults': _detectionResults.length,
          'ocrResults': _ocrResults.length,
          'hasComplexIssue': _hasComplexIssue,
          'conflictingCategories': _conflictingCategories,
          'complexIssueDescription': _complexIssueDescription,
        },
      };
      
      debugPrint('Submit data: $submitData');
      
      await Future.delayed(const Duration(seconds: 2)); // 시뮬레이션

      if (mounted) {
        final message = _hasComplexIssue 
            ? '신고서가 제출되었습니다. 복합 민원으로 담당자가 추가 검토합니다.'
            : '신고서가 성공적으로 제출되었습니다.';
            
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: _hasComplexIssue ? Colors.orange : Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      debugPrint('Submit error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('제출 중 오류가 발생했습니다: $e'))
        );
      }
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  /// API 연결 테스트
  Future<void> _testApiConnection() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('API 연결 테스트 중...'),
          ],
        ),
      ),
    );

    try {
      final isConnected = await RoboflowService.testApiConnection();
      
      if (mounted) {
        Navigator.pop(context); // 로딩 다이얼로그 닫기
        
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(
                  isConnected ? Icons.check_circle : Icons.error,
                  color: isConnected ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(isConnected ? 'API 연결 성공' : 'API 연결 실패'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isConnected 
                      ? '✅ Roboflow API와 정상적으로 연결되었습니다.\n실제 이미지 분석이 가능합니다.'
                      : '❌ API 연결에 실패했습니다.\n다음을 확인해주세요:',
                ),
                if (!isConnected) ...[
                  const SizedBox(height: 12),
                  const Text('• API 키가 올바른지 확인'),
                  const Text('• 인터넷 연결 상태 확인'),
                  const Text('• Roboflow 계정 상태 확인'),
                  const Text('• 모델 엔드포인트 확인'),
                  const SizedBox(height: 12),
                  Text(
                    'API 키 정보: ${RoboflowService.apiKeyInfo}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ],
            ),
            actions: [
              if (!isConnected)
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _showApiKeyDialog();
                  },
                  child: const Text('API 키 수정'),
                ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('확인'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // 로딩 다이얼로그 닫기
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('API 테스트 중 오류 발생: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 신고서 작성'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 이미지 섹션
              _buildImageSection(),
              const SizedBox(height: 24),

              // 기본 정보 섹션
              _buildBasicInfoSection(),
              const SizedBox(height: 24),

              // 위치 정보 섹션
              if (_currentPosition != null) _buildLocationSection(),
              const SizedBox(height: 24),

              // AI 분석 결과 섹션
              if (_detectionResults.isNotEmpty || _ocrResults.isNotEmpty)
                _buildAnalysisSection(),
              const SizedBox(height: 24),

              // 서명 섹션
              _buildSignatureSection(),
              const SizedBox(height: 32),

              // 제출 버튼
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _submitReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: _isProcessing
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('신고서 제출'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.photo_camera),
                const SizedBox(width: 8),
                const Text(
                  '사진 첨부 (AI 분석)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  '${_selectedImages.length + _selectedImageTypes.length}/10',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 이미지 그리드
            if (_selectedImages.isNotEmpty || _selectedImageTypes.isNotEmpty) ...[
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _selectedImages.length + _selectedImageTypes.length,
                itemBuilder: (context, index) {
                  final isPrimary = _primaryImageIndex == index;
                  return GestureDetector(
                    onLongPress: () => _setPrimaryImage(index),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            decoration: BoxDecoration(
                              border: isPrimary 
                                  ? Border.all(color: Colors.orange, width: 3)
                                  : null,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: _buildImageWidget(index),
                          ),
                        ),
                        // 대표 이미지 표시
                        if (isPrimary)
                          Positioned(
                            bottom: 4,
                            left: 4,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                '대표',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        // 삭제 버튼
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () => _removeImage(index),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                        // AI 분석 결과 표시
                        if (index < _detectionResults.length &&
                            _detectionResults[index].hasDetections)
                          Positioned(
                            bottom: isPrimary ? 24 : 4, // 대표 이미지일 경우 위치 조정
                            right: 4,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'AI 분석됨',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ),
                        // 실제 이미지 표시 (테스트 이미지와 구분)
                        if (index < _selectedImages.length)
                          Positioned(
                            top: 4,
                            left: 4,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                '실제',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],

            // 이미지 추가 버튼들
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _selectImage('카메라'),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('카메라'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _selectImage('갤러리'),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('갤러리'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showImageTestDialog(),
                    icon: const Icon(Icons.science),
                    label: const Text('AI 테스트'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.green,
                      side: const BorderSide(color: Colors.green),
                    ),
                  ),
                ),
              ],
            ),

            if (_selectedImages.isEmpty && _selectedImageTypes.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.auto_awesome, color: Colors.blue, size: 32),
                    SizedBox(height: 8),
                    Text(
                      'AI 기반 자동 분석',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '사진을 첨부하면 AI가 자동으로 객체를 탐지하고\n텍스트를 인식하여 신고 내용을 추천합니다',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),

            // 복합 민원 알림 표시
            if (_hasComplexIssue) ...[
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(top: 16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withOpacity(0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.warning, color: Colors.orange, size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          '복합 민원 감지됨',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: _showComplexIssueDialog,
                          child: const Text('상세보기'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '현재 카테고리: $_selectedCategory',
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '추가 감지된 문제: ${_conflictingCategories.join(', ')}',
                      style: const TextStyle(fontSize: 12, color: Colors.orange),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '💡 이미지를 길게 눌러 대표 이미지를 선택하면 주요 문제에 집중할 수 있습니다.',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],

            // 대표 이미지 선택 가이드
            if ((_selectedImages.length + _selectedImageTypes.length) > 1 && _primaryImageIndex < 0) ...[
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(top: 16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.touch_app, color: Colors.blue, size: 20),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        '이미지를 길게 눌러 대표 이미지를 선택하세요',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _showPrimaryImageGuide,
                      child: const Text('도움말'),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.edit),
                SizedBox(width: 8),
                Text(
                  '기본 정보',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 제목
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: '제목',
                border: OutlineInputBorder(),
                hintText: 'AI가 자동으로 제목을 추천합니다',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '제목을 입력해주세요';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // 카테고리 및 우선순위
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: '카테고리',
                      border: OutlineInputBorder(),
                    ),
                    items: _categories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedPriority,
                    decoration: const InputDecoration(
                      labelText: '우선순위',
                      border: OutlineInputBorder(),
                    ),
                    items: _priorities.map((priority) {
                      return DropdownMenuItem(
                        value: priority,
                        child: Text(priority),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedPriority = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 설명
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: '상세 설명',
                border: OutlineInputBorder(),
                hintText: 'AI가 OCR로 추출한 정보를 자동으로 채워줍니다',
              ),
              maxLines: 4,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '상세 설명을 입력해주세요';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.location_on),
                SizedBox(width: 8),
                Text(
                  '위치 정보',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green),
                      SizedBox(width: 8),
                      Text(
                        '위치 정보 확인됨',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '위도: ${_currentPosition!.latitude.toStringAsFixed(6)}',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  Text(
                    '경도: ${_currentPosition!.longitude.toStringAsFixed(6)}',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  Text(
                    '정확도: ${_currentPosition!.accuracy.toStringAsFixed(1)}m',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.auto_awesome, color: Colors.purple),
                SizedBox(width: 8),
                Text(
                  'AI 분석 결과',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 객체 탐지 결과
            if (_detectionResults.any((r) => r.hasDetections)) ...[
              const Text(
                '🎯 객체 탐지 결과',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ..._detectionResults.where((r) => r.hasDetections).map((result) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(result.summary),
                      const SizedBox(height: 4),
                      ...result.detections.map(
                        (detection) => Text(
                          '• ${detection.koreanName} (${detection.confidencePercent})',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 16),
            ],

            // OCR 결과
            if (_ocrResults.any((r) => r.hasText)) ...[
              const Text(
                '📝 텍스트 인식 결과 (OCR)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ..._ocrResults.where((r) => r.hasText).map((result) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(result.summary),
                      if (result.extractedInfo.hasUsefulInfo) ...[
                        const SizedBox(height: 4),
                        if (result.extractedInfo.addresses.isNotEmpty)
                          Text('주소: ${result.extractedInfo.addresses.first}'),
                        if (result.extractedInfo.businessNames.isNotEmpty)
                          Text(
                            '업체: ${result.extractedInfo.businessNames.first}',
                          ),
                        if (result.extractedInfo.keywords.isNotEmpty)
                          Text(
                            '키워드: ${result.extractedInfo.keywords.join(', ')}',
                          ),
                      ],
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSignatureSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.edit),
                SizedBox(width: 8),
                Text(
                  '디지털 서명',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Signature(
                controller: _signatureController,
                backgroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                TextButton.icon(
                  onPressed: () => _signatureController.clear(),
                  icon: const Icon(Icons.clear),
                  label: const Text('지우기'),
                ),
                const Spacer(),
                const Text(
                  '위 서명란에 서명해주세요',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 대표 이미지 설정
  void _setPrimaryImage(int index) {
    setState(() {
      _primaryImageIndex = index;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${index + 1}번째 이미지가 대표 이미지로 설정되었습니다'),
        backgroundColor: Colors.green,
      ),
    );
  }

  /// 복합 민원 검사
  void _checkForComplexIssues() {
    if (_detectionResults.length < 2) return;

    // 각 이미지의 추천 카테고리 수집
    final categories = <String>[];
    for (final result in _detectionResults) {
      if (result.hasDetections) {
        final category = RoboflowService.recommendCategory(result.detections);
        if (!categories.contains(category)) {
          categories.add(category);
        }
      }
    }

    setState(() {
      _hasComplexIssue = categories.length > 1;
      _conflictingCategories = categories;
      
      if (_hasComplexIssue) {
        _complexIssueDescription = '발견된 문제 유형: ${categories.join(', ')}';
      } else {
        _complexIssueDescription = '';
      }
    });
  }

  /// 빠른 설정 정보 표시
  void _showQuickSetupInfo(BuildContext context, String setupType) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$setupType 설정이 적용되었습니다.'),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.blue,
      ),
    );
  }

  /// 프로젝트 설정 상세 가이드
  void _showProjectGuide() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('📖 Roboflow 프로젝트 설정 가이드'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '🎯 프로젝트 이름이 중요한 이유',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text('Roboflow API는 workspace/project/version 형태로 모델을 식별합니다.'),
                const SizedBox(height: 16),
                
                const Text(
                  '✅ 추천 설정',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('🆓 무료 공개 모델 (API 키 불필요)'),
                      Text('• Workspace: microsoft'),
                      Text('• Project: coco'),
                      Text('• 설명: 일반 객체 감지 (사람, 차량, 동물 등)'),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                
                const Text(
                  '🔧 내 프로젝트 만들기',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                ),
                const SizedBox(height: 8),
                const Text('1. Roboflow.com 방문'),
                const Text('2. "Create New Project" 클릭'),
                const Text('3. "Object Detection" 선택'),
                const Text('4. 프로젝트 이름 입력 (예: field-reports)'),
                const Text('5. 클래스 추가 (damage, pothole, graffiti 등)'),
                const Text('6. Settings > API Key 복사'),
                const SizedBox(height: 12),
                
                const Text(
                  '🎯 프로젝트 이름 예시',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('• field-reports (현장 보고용)'),
                      Text('• damage-detection (손상 감지)'),
                      Text('• road-inspection (도로 점검)'),
                      Text('• facility-monitoring (시설 모니터링)'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }
}
