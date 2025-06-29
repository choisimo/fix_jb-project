import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/ai/roboflow_service.dart';

class ReportCreatePageEnhanced extends StatefulWidget {
  const ReportCreatePageEnhanced({super.key});

  @override
  State<ReportCreatePageEnhanced> createState() =>
      _ReportCreatePageEnhancedState();
}

class _ReportCreatePageEnhancedState extends State<ReportCreatePageEnhanced> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  // 이미지 관련
  final List<File> _selectedImages = [];
  final ImagePicker _imagePicker = ImagePicker();

  // 위치 관련
  Position? _currentPosition;
  String? _currentAddress;
  bool _isLoadingLocation = false;

  // AI 분석 관련
  bool _isAnalyzing = false;
  List<DetectedObject> _analysisResults = [];

  // 폼 데이터
  String _selectedCategory = '안전';
  bool _isSubmitting = false;

  final List<String> _categories = ['안전', '품질', '진행상황', '유지보수', '기타'];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('새 신고서 작성'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isSubmitting
          ? const Center(child: CircularProgressIndicator())
          : _buildForm(),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitleField(),
            const SizedBox(height: 16),
            _buildCategoryField(),
            const SizedBox(height: 16),
            _buildContentField(),
            const SizedBox(height: 16),
            _buildImageSection(),
            const SizedBox(height: 16),
            _buildLocationSection(),
            const SizedBox(height: 16),
            if (_analysisResults.isNotEmpty) _buildAnalysisResults(),
            const SizedBox(height: 32),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      decoration: const InputDecoration(
        labelText: '제목',
        border: OutlineInputBorder(),
        hintText: '신고 제목을 입력해주세요',
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '제목을 입력해주세요';
        }
        return null;
      },
    );
  }

  Widget _buildCategoryField() {
    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      decoration: const InputDecoration(
        labelText: '카테고리',
        border: OutlineInputBorder(),
      ),
      items: _categories.map((category) {
        return DropdownMenuItem(value: category, child: Text(category));
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedCategory = value;
          });
        }
      },
    );
  }

  Widget _buildContentField() {
    return TextFormField(
      controller: _contentController,
      maxLines: 4,
      decoration: const InputDecoration(
        labelText: '내용',
        border: OutlineInputBorder(),
        hintText: '신고 내용을 자세히 입력해주세요',
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '내용을 입력해주세요';
        }
        return null;
      },
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              '이미지',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            if (_isAnalyzing)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (_selectedImages.isEmpty)
          _buildAddImageButton()
        else
          _buildImageGrid(),
      ],
    );
  }

  Widget _buildAddImageButton() {
    return Container(
      width: double.infinity,
      height: 150,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: _showImagePickerDialog,
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate, size: 48, color: Colors.grey),
            SizedBox(height: 8),
            Text('이미지 추가', style: TextStyle(color: Colors.grey)),
            Text(
              '카메라 촬영 또는 갤러리에서 선택',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageGrid() {
    return Column(
      children: [
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _selectedImages.length + 1,
            itemBuilder: (context, index) {
              if (index == _selectedImages.length) {
                return Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Container(
                    width: 100,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: InkWell(
                      onTap: _showImagePickerDialog,
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add, color: Colors.grey),
                          Text('추가', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  ),
                );
              }

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: FileImage(_selectedImages[index]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: InkWell(
                        onTap: () => _removeImage(index),
                        child: Container(
                          padding: const EdgeInsets.all(2),
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
                  ],
                ),
              );
            },
          ),
        ),
        if (_selectedImages.isNotEmpty) ...[
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _isAnalyzing ? null : _analyzeImages,
            icon: _isAnalyzing
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.psychology),
            label: Text(_isAnalyzing ? 'AI 분석 중...' : 'AI 분석 시작'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLocationSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '위치 정보',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (_currentPosition != null) ...[
              Text(
                '위도: ${_currentPosition!.latitude.toStringAsFixed(6)}',
                style: const TextStyle(fontSize: 14),
              ),
              Text(
                '경도: ${_currentPosition!.longitude.toStringAsFixed(6)}',
                style: const TextStyle(fontSize: 14),
              ),
              if (_currentAddress != null) ...[
                const SizedBox(height: 4),
                Text(
                  '주소: $_currentAddress',
                  style: const TextStyle(fontSize: 14, color: Colors.blue),
                ),
              ],
            ] else
              const Text('위치 정보를 가져올 수 없습니다'),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _isLoadingLocation ? null : _getCurrentLocation,
              icon: _isLoadingLocation
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.location_on),
              label: Text(_isLoadingLocation ? '위치 가져오는 중...' : '현재 위치 가져오기'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisResults() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'AI 분석 결과',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ..._analysisResults.map(
              (result) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${result.koreanName}: ${(result.confidence * 100).toStringAsFixed(1)}% 확신도',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _applyAnalysisToForm,
              icon: const Icon(Icons.auto_fix_high),
              label: const Text('분석 결과를 폼에 적용'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitReport,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
        child: Text(
          _isSubmitting ? '제출 중...' : '신고서 제출',
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  // 이미지 선택 다이얼로그
  void _showImagePickerDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('이미지 선택'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('카메라로 촬영'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('갤러리에서 선택'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  // 이미지 선택
  Future<void> _pickImage(ImageSource source) async {
    try {
      // 권한 체크
      Permission permission = source == ImageSource.camera
          ? Permission.camera
          : Permission.storage;

      final status = await permission.request();
      if (!status.isGranted) {
        _showSnackBar('권한이 필요합니다');
        return;
      }

      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImages.add(File(image.path));
        });
        _showSnackBar('이미지가 추가되었습니다');
      }
    } catch (e) {
      _showSnackBar('이미지 선택 실패: $e');
    }
  }

  // 이미지 제거
  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  // AI 분석
  Future<void> _analyzeImages() async {
    if (_selectedImages.isEmpty) return;

    setState(() {
      _isAnalyzing = true;
      _analysisResults.clear();
    });

    try {
      for (File image in _selectedImages) {
        final result = await RoboflowService.instance.detectObjects(image);
        if (result.hasDetections) {
          _analysisResults.addAll(result.detections);
        }
      }

      if (_analysisResults.isNotEmpty) {
        _showSnackBar('AI 분석이 완료되었습니다');
      } else {
        _showSnackBar('분석 결과가 없습니다');
      }
    } catch (e) {
      _showSnackBar('AI 분석 실패: $e');
    } finally {
      setState(() {
        _isAnalyzing = false;
      });
    }
  }

  // 분석 결과를 폼에 적용
  void _applyAnalysisToForm() {
    if (_analysisResults.isEmpty) return;

    // 가장 높은 확신도의 결과를 사용
    final bestResult = _analysisResults.reduce(
      (a, b) => a.confidence > b.confidence ? a : b,
    );

    // 제목 자동 생성
    if (_titleController.text.isEmpty) {
      _titleController.text = '${bestResult.koreanName} 발견 신고';
    }

    // 내용 자동 생성
    if (_contentController.text.isEmpty) {
      final analysisText = _analysisResults
          .map(
            (r) =>
                '${r.koreanName} (${(r.confidence * 100).toStringAsFixed(1)}%)',
          )
          .join(', ');

      _contentController.text =
          'AI 분석 결과:\n$analysisText\n\n위치: ${_currentAddress ?? '정보 없음'}';
    }

    // 카테고리 자동 선택
    _selectedCategory = _mapDetectionToCategory(bestResult.className);

    setState(() {});
    _showSnackBar('분석 결과가 폼에 적용되었습니다');
  }

  // 검출 결과를 카테고리로 매핑
  String _mapDetectionToCategory(String detection) {
    const Map<String, String> categoryMap = {
      'trash': '환경',
      'damage': '안전',
      'crack': '안전',
      'pothole': '안전',
      'construction': '진행상황',
      'maintenance': '유지보수',
    };

    return categoryMap[detection.toLowerCase()] ?? '기타';
  }

  // 현재 위치 가져오기
  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      // 위치 권한 체크
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final result = await Geolocator.requestPermission();
        if (result == LocationPermission.denied) {
          _showSnackBar('위치 권한이 필요합니다');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showSnackBar('설정에서 위치 권한을 허용해주세요');
        return;
      }

      // 위치 서비스 확인
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showSnackBar('위치 서비스를 활성화해주세요');
        return;
      }

      // 현재 위치 가져오기
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      setState(() {
        _currentPosition = position;
      });

      // 주소 변환 (Geocoding)
      await _getAddressFromPosition(position);

      _showSnackBar('위치 정보를 가져왔습니다');
    } catch (e) {
      _showSnackBar('위치 가져오기 실패: $e');
    } finally {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  // 좌표를 주소로 변환
  Future<void> _getAddressFromPosition(Position position) async {
    try {
      // 간단한 주소 표시 (실제로는 geocoding 패키지 사용)
      setState(() {
        _currentAddress =
            '위도 ${position.latitude.toStringAsFixed(4)}, '
            '경도 ${position.longitude.toStringAsFixed(4)}';
      });
    } catch (e) {
      debugPrint('주소 변환 실패: $e');
    }
  }

  // 신고서 제출
  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedImages.isEmpty) {
      _showSnackBar('이미지를 하나 이상 추가해주세요');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // 시뮬레이션 딜레이
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        _showSnackBar('신고서가 성공적으로 제출되었습니다!', isSuccess: true);
        Navigator.of(context).pop();
      }
    } catch (e) {
      _showSnackBar('제출 실패: $e');
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  // 스낵바 표시
  void _showSnackBar(String message, {bool isSuccess = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green : null,
        duration: Duration(seconds: isSuccess ? 3 : 2),
      ),
    );
  }
}
