import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'dart:math';
import '../../../../core/managers/report_manager.dart';
import '../../../../shared/widgets/map/map_selector.dart';

class ReportCreatePageFinal extends StatefulWidget {
  const ReportCreatePageFinal({super.key});

  @override
  State<ReportCreatePageFinal> createState() => _ReportCreatePageFinalState();
}

class _ReportCreatePageFinalState extends State<ReportCreatePageFinal> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  // 이미지 관련 (시뮬레이션)
  final List<String> _selectedImages = [];
  int? _primaryImageIndex; // 대표 이미지 인덱스
  bool _isComplexSubject = false; // 복합적 주제 여부

  // 위치 관련
  NLatLng? _currentPosition;
  String? _currentAddress;
  bool _isLoadingLocation = false;

  // AI 분석 관련 (시뮬레이션)
  bool _isAnalyzing = false;
  List<Map<String, dynamic>> _analysisResults = [];

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

        // 이미지 추가 버튼 (이미지가 없는 경우)
        if (_selectedImages.isEmpty)
          Container(
            width: double.infinity,
            height: 150,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: InkWell(
              onTap: _simulateImagePicker,
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_photo_alternate, size: 48, color: Colors.grey),
                  SizedBox(height: 8),
                  Text('이미지 추가 (시뮬레이션)', style: TextStyle(color: Colors.grey)),
                  Text(
                    '탭하여 이미지 선택 시뮬레이션',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),

        // 이미지 정보 표시
        if (_selectedImages.isNotEmpty) ...[
          // 이미지 미리보기 그리드
          _buildImageGrid(),
          const SizedBox(height: 8),

          Row(
            children: [
              Icon(Icons.photo_library, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                '${_selectedImages.length}개 이미지 선택됨',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              if (_primaryImageIndex != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '대표: ${_primaryImageIndex! + 1}번',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              if (_selectedImages.length < 5)
                TextButton.icon(
                  onPressed: _simulateImagePicker,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('추가'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
        ],

        // AI 분석 버튼
        if (_selectedImages.isNotEmpty) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isAnalyzing ? null : _simulateAIAnalysis,
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
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
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
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoadingLocation ? null : _getCurrentLocation,
                    icon: _isLoadingLocation
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.location_on),
                    label: Text(_isLoadingLocation ? '위치 가져오는 중...' : '현재 위치'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showLocationPicker(),
                    icon: const Icon(Icons.map),
                    label: const Text('지도에서 선택'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            // 지도 미리보기 (위치가 선택된 경우)
            if (_currentPosition != null) ...[
              const SizedBox(height: 12),
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Stack(
                    children: [
                      // 지도 플레이스홀더 (실제 구현에서는 Google Maps 위젯)
                      Container(
                        color: Colors.grey[100],
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.map,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '지도 미리보기',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '위도: ${_currentPosition!.latitude.toStringAsFixed(4)}',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                '경도: ${_currentPosition!.longitude.toStringAsFixed(4)}',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // 중앙 마커
                      const Center(
                        child: Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 32,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
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
            Row(
              children: [
                const Icon(Icons.psychology, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  'AI 분석 결과',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '자동 적용됨',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildAnalysisResultsList(),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info, size: 16, color: Colors.blue),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      '분석 결과가 제목, 내용, 카테고리에 자동으로 반영되었습니다.',
                      style: TextStyle(fontSize: 12, color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Column(
      children: [
        // 복합적 주제 경고
        if (_isComplexSubject) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.admin_panel_settings,
                      color: Colors.orange.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '관리자 검토 필요',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '이미지에서 여러 종류의 문제가 감지되어 복합적인 주제로 분류됩니다. 관리자가 상세히 검토한 후 적절한 조치를 취할 예정입니다.',
                  style: TextStyle(fontSize: 12, color: Colors.orange.shade600),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // 제출 버튼
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _submitReport,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: _isComplexSubject ? Colors.orange : Colors.green,
              foregroundColor: Colors.white,
            ),
            child: Text(
              _isSubmitting
                  ? '제출 중...'
                  : _isComplexSubject
                  ? '관리자 검토용 제출'
                  : '신고서 제출',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  // 이미지 제거
  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);

      // 대표 이미지 처리
      if (_primaryImageIndex == index) {
        // 제거된 이미지가 대표 이미지인 경우
        if (_selectedImages.isNotEmpty) {
          // 첫 번째 이미지를 새로운 대표로 설정
          _primaryImageIndex = 0;
        } else {
          // 이미지가 모두 제거된 경우
          _primaryImageIndex = null;
          _isComplexSubject = false; // 복합성 상태 초기화
          _analysisResults.clear(); // 분석 결과 초기화
        }
      } else if (_primaryImageIndex != null && _primaryImageIndex! > index) {
        // 대표 이미지 인덱스 조정 (제거된 이미지보다 뒤에 있는 경우)
        _primaryImageIndex = _primaryImageIndex! - 1;
      }
    });

    // 이미지 제거 후 복합성 재검사
    if (_selectedImages.isNotEmpty && _analysisResults.isNotEmpty) {
      _checkComplexSubject();
    }

    _showSnackBar('이미지가 제거되었습니다');
  }

  // 대표 이미지 설정
  void _setPrimaryImage(int index) {
    if (index < 0 || index >= _selectedImages.length) return;

    setState(() {
      _primaryImageIndex = index;
    });

    _showSnackBar('${index + 1}번 이미지가 대표 이미지로 설정되었습니다', isSuccess: true);
  }

  // 이미지 선택 시뮬레이션
  void _simulateImagePicker() {
    if (_selectedImages.length >= 5) {
      _showSnackBar('최대 5개까지 이미지를 추가할 수 있습니다');
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('이미지 선택 (시뮬레이션)'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('실제 구현에서는 카메라 촬영 또는 갤러리에서 이미지를 선택할 수 있습니다.'),
            const SizedBox(height: 12),
            const Text('현재는 시뮬레이션 모드입니다.'),
            const SizedBox(height: 12),
            Text(
              '현재 ${_selectedImages.length}/5개 이미지 선택됨',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton.icon(
            onPressed: () {
              _addImageFromSource('camera');
            },
            icon: const Icon(Icons.camera_alt),
            label: const Text('카메라'),
          ),
          TextButton.icon(
            onPressed: () {
              _addImageFromSource('gallery');
            },
            icon: const Icon(Icons.photo_library),
            label: const Text('갤러리'),
          ),
        ],
      ),
    );
  }

  // 이미지 소스에서 추가
  void _addImageFromSource(String source) {
    Navigator.pop(context);

    setState(() {
      final imageName = source == 'camera'
          ? 'simulated_camera_${DateTime.now().millisecondsSinceEpoch}.jpg'
          : 'simulated_gallery_${DateTime.now().millisecondsSinceEpoch}.jpg';

      _selectedImages.add(imageName);

      // 첫 번째 이미지인 경우 자동으로 대표 이미지로 설정
      if (_selectedImages.length == 1) {
        _primaryImageIndex = 0;
      }
    });

    final sourceText = source == 'camera' ? '카메라로 촬영된' : '갤러리에서 선택된';
    _showSnackBar('$sourceText 이미지가 추가되었습니다 (시뮬레이션)', isSuccess: true);

    // 대표 이미지 안내 메시지 (첫 번째 이미지인 경우)
    if (_selectedImages.length == 1) {
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          _showSnackBar('첫 번째 이미지가 대표 이미지로 설정되었습니다');
        }
      });
    }
  }

  // AI 분석 시뮬레이션
  Future<void> _simulateAIAnalysis() async {
    if (_selectedImages.isEmpty) return;

    setState(() {
      _isAnalyzing = true;
      _analysisResults.clear();
    });

    try {
      // AI 분석 시뮬레이션 (실제로는 Roboflow API 호출)
      await Future.delayed(const Duration(seconds: 3));

      // 이미지별 분석 결과 시뮬레이션
      final List<Map<String, dynamic>> results = [];
      final detectionTypes = ['쓰레기', '손상된 도로', '안전 위험 요소', '공사 현장', '유지보수 필요'];

      for (int i = 0; i < _selectedImages.length; i++) {
        // 각 이미지마다 1-3개의 검출 결과 생성
        final numDetections = 1 + (i % 3);
        for (int j = 0; j < numDetections; j++) {
          results.add({
            'imageIndex': i,
            'name': detectionTypes[(i + j) % detectionTypes.length],
            'confidence': 85 + (i * 5) + (j * 2),
            'category': _mapDetectionToCategory(
              detectionTypes[(i + j) % detectionTypes.length],
            ),
          });
        }
      }

      setState(() {
        _analysisResults = results;
        _isAnalyzing = false;
      });

      // 복합적 주제 검사
      _checkComplexSubject();

      // 폼 자동 완성
      _applyAnalysisToForm();

      _showSnackBar('AI 분석이 완료되어 폼에 자동 적용되었습니다!', isSuccess: true);
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
      });
      _showSnackBar('AI 분석 중 오류가 발생했습니다: $e');
    }
  }

  // 복합적 주제 검사
  void _checkComplexSubject() {
    if (_analysisResults.isEmpty || _selectedImages.length <= 1) {
      setState(() {
        _isComplexSubject = false;
      });
      return;
    }

    // 1. 카테고리 다양성 검사
    final Set<String> categories = _analysisResults
        .map((result) => result['category'] as String)
        .toSet();

    // 2. 검출 유형 다양성 검사
    final Set<String> detectionTypes = _analysisResults
        .map((result) => result['name'] as String)
        .toSet();

    // 3. 이미지별 주요 검출 결과 분석
    final Map<int, String> primaryDetectionPerImage = {};
    for (final result in _analysisResults) {
      final imageIndex = result['imageIndex'] as int;
      final confidence = result['confidence'] as int;

      if (!primaryDetectionPerImage.containsKey(imageIndex) ||
          confidence >
              (_analysisResults
                      .where(
                        (r) =>
                            r['imageIndex'] == imageIndex &&
                            r['name'] == primaryDetectionPerImage[imageIndex],
                      )
                      .first['confidence']
                  as int)) {
        primaryDetectionPerImage[imageIndex] = result['name'] as String;
      }
    }

    // 복합성 판단 기준:
    // - 3개 이상의 서로 다른 카테고리가 감지되거나
    // - 4개 이상의 서로 다른 검출 유형이 감지되거나
    // - 이미지별 주요 검출 결과가 모두 다른 경우
    final bool isComplex =
        categories.length >= 3 ||
        detectionTypes.length >= 4 ||
        (primaryDetectionPerImage.values.toSet().length ==
                _selectedImages.length &&
            _selectedImages.length >= 3);

    setState(() {
      _isComplexSubject = isComplex;
    });

    if (isComplex) {
      _showSnackBar('복합적인 주제가 감지되어 관리자 검토가 필요합니다.', isSuccess: false);
    }
  }

  // 분석 결과를 폼에 적용
  void _applyAnalysisToForm() {
    if (_analysisResults.isEmpty) return;

    // 신뢰도가 가장 높은 결과를 기준으로 사용
    final bestResult = _analysisResults.reduce(
      (a, b) => (a['confidence'] as int) > (b['confidence'] as int) ? a : b,
    );

    // 제목 자동 생성
    if (_titleController.text.isEmpty) {
      if (_isComplexSubject) {
        _titleController.text = '복합적 주제 신고';
      } else {
        _titleController.text = '${bestResult['name']} 발견 신고';
      }
    }

    // 내용 자동 생성
    if (_contentController.text.isEmpty) {
      final StringBuffer contentBuffer = StringBuffer();

      if (_isComplexSubject) {
        contentBuffer.writeln('※ 복합적인 주제가 감지되어 관리자 검토가 필요합니다.\n');
      }

      contentBuffer.writeln('AI 분석 결과:');

      // 이미지별로 그룹화하여 표시
      final Map<int, List<Map<String, dynamic>>> resultsByImage = {};
      for (final result in _analysisResults) {
        final imageIndex = result['imageIndex'] as int;
        resultsByImage.putIfAbsent(imageIndex, () => []).add(result);
      }

      resultsByImage.forEach((imageIndex, results) {
        contentBuffer.writeln('이미지 ${imageIndex + 1}:');
        for (final result in results) {
          contentBuffer.writeln(
            '  - ${result['name']} (${result['confidence']}%)',
          );
        }
      });

      contentBuffer.writeln('\n위치: ${_currentAddress ?? '정보 없음'}');

      _contentController.text = contentBuffer.toString();
    }

    // 카테고리 선택 (복합적 주제가 아닌 경우에만 자동 선택)
    if (!_isComplexSubject) {
      _selectedCategory = _mapDetectionToCategory(bestResult['name']);
    } else {
      // 복합적 주제인 경우 '기타'로 설정
      _selectedCategory = '기타';
    }

    setState(() {});
  }

  // 검출 결과를 카테고리로 매핑
  String _mapDetectionToCategory(String detection) {
    const Map<String, String> categoryMap = {
      '쓰레기': '품질',
      '손상된 도로': '안전',
      '안전 위험 요소': '안전',
      '공사 현장': '진행상황',
      '유지보수 필요': '유지보수',
    };

    return categoryMap[detection] ?? '기타';
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
      );
      setState(() {
        _currentPosition = NLatLng(position.latitude, position.longitude);
      });

      setState(() {
        _currentAddress = '전주시 덕진구 백제대로 567 (예시 주소)';
      });

      _showSnackBar('위치 정보를 가져왔습니다');
    } catch (e) {
      _showSnackBar('위치 가져오기 실패: $e');
    } finally {
      setState(() {
        _isLoadingLocation = false;
      });
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
      // 실제 제출 로직 시뮬레이션
      await Future.delayed(const Duration(seconds: 2));

      // ReportManager를 사용하여 새로운 보고서 저장
      final reportManager = ReportManager();
      final now = DateTime.now();
      final newReport = {
        'id': reportManager.generateNextId(),
        'title': _titleController.text,
        'category': _selectedCategory,
        'status': _isComplexSubject ? '관리자 검토' : '대기',
        'date':
            '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}',
        'location': _currentAddress ?? '위치 정보 없음',
        'content': _contentController.text,
        'images': _selectedImages.length,
        'aiAnalysis': _analysisResults.isNotEmpty ? _analysisResults : null,
        'isComplexSubject': _isComplexSubject,
        'primaryImageIndex': _primaryImageIndex,
      };

      reportManager.addReport(newReport);

      if (mounted) {
        final message = _isComplexSubject
            ? '복합적 주제 신고서가 관리자 검토를 위해 제출되었습니다!'
            : '신고서가 성공적으로 제출되었습니다!';
        _showSnackBar(message, isSuccess: true);

        // 제출 성공 시 결과와 함께 이전 페이지로 돌아가기
        Navigator.of(context).pop(true); // true를 반환하여 제출 성공을 알림
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

  Widget _buildImageGrid() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1.0,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: _selectedImages.length,
        itemBuilder: (context, index) => _buildImageTile(index),
      ),
    );
  }

  Widget _buildImageTile(int index) {
    final bool isPrimary = _primaryImageIndex == index;
    final String imageName = _selectedImages[index];

    return Stack(
      children: [
        // 이미지 컨테이너
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isPrimary ? Colors.blue : Colors.grey[300]!,
              width: isPrimary ? 2 : 1,
            ),
            color: Colors.grey[100],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.image,
                  size: 32,
                  color: isPrimary ? Colors.blue : Colors.grey,
                ),
                const SizedBox(height: 4),
                Text(
                  '${index + 1}번',
                  style: TextStyle(
                    fontSize: 10,
                    color: isPrimary ? Colors.blue : Colors.grey[600],
                    fontWeight: isPrimary ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                if (imageName.contains('camera'))
                  Icon(Icons.camera_alt, size: 12, color: Colors.grey[500])
                else
                  Icon(Icons.photo_library, size: 12, color: Colors.grey[500]),
              ],
            ),
          ),
        ),

        // 대표 이미지 배지
        if (isPrimary)
          Positioned(
            top: 4,
            left: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '대표',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 8,
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
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.close, size: 12, color: Colors.white),
            ),
          ),
        ),

        // 탭 영역 (대표 이미지 설정)
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => _setPrimaryImage(index),
              child: Container(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnalysisResultsList() {
    if (_analysisResults.isEmpty) {
      return const SizedBox.shrink();
    }

    // 이미지별로 결과 그룹화
    final Map<int, List<Map<String, dynamic>>> resultsByImage = {};
    for (final result in _analysisResults) {
      final imageIndex = result['imageIndex'] as int;
      resultsByImage.putIfAbsent(imageIndex, () => []).add(result);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: resultsByImage.entries.map((entry) {
        final imageIndex = entry.key;
        final results = entry.value;
        final isPrimary = _primaryImageIndex == imageIndex;

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isPrimary ? Colors.blue.shade50 : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isPrimary ? Colors.blue.shade200 : Colors.grey.shade200,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.image,
                    size: 16,
                    color: isPrimary ? Colors.blue : Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '이미지 ${imageIndex + 1}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isPrimary ? Colors.blue : Colors.grey[700],
                    ),
                  ),
                  if (isPrimary) ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        '대표',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              ...results.map(
                (result) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${result['name']}: ${result['confidence']}% 확신도',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // 위치 선택 다이얼로그 표시
  void _showLocationPicker() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('위치 선택'),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  if (_currentPosition != null) {
                    _showSnackBar('현재 위치가 선택되었습니다', isSuccess: true);
                  }
                },
                child: const Text('완료', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
          body: _currentPosition != null
              ? MapSelector(
                  initialPosition: _currentPosition,
                  onLocationSelected: (NLatLng position, String address) {
                    setState(() {
                      _currentPosition = position;
                      _currentAddress = address;
                    });
                  },
                  height: double.infinity,
                )
              : const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('현재 위치를 먼저 가져와주세요'),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
