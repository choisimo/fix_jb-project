import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

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

  // 위치 관련
  Position? _currentPosition;
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
        Container(
          width: double.infinity,
          height: 150,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: InkWell(
            onTap: _simulateImagePicker,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.add_photo_alternate,
                  size: 48,
                  color: Colors.grey,
                ),
                const SizedBox(height: 8),
                Text(
                  _selectedImages.isEmpty
                      ? '이미지 추가 (시뮬레이션)'
                      : '${_selectedImages.length}개 이미지 선택됨',
                  style: const TextStyle(color: Colors.grey),
                ),
                const Text(
                  '탭하여 이미지 선택 시뮬레이션',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
        if (_selectedImages.isNotEmpty) ...[
          const SizedBox(height: 12),
          ElevatedButton.icon(
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
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${result['name']}: ${result['confidence']}% 확신도',
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

  // 이미지 선택 시뮬레이션
  void _simulateImagePicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('이미지 선택 (시뮬레이션)'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('실제 구현에서는 카메라 촬영 또는 갤러리에서 이미지를 선택할 수 있습니다.'),
            SizedBox(height: 8),
            Text('현재는 시뮬레이션 모드입니다.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _selectedImages.add(
                  'simulated_image_${_selectedImages.length + 1}.jpg',
                );
              });
              _showSnackBar('이미지가 추가되었습니다 (시뮬레이션)');
            },
            child: const Text('추가'),
          ),
        ],
      ),
    );
  }

  // AI 분석 시뮬레이션
  Future<void> _simulateAIAnalysis() async {
    setState(() {
      _isAnalyzing = true;
      _analysisResults.clear();
    });

    // 시뮬레이션 딜레이
    await Future.delayed(const Duration(seconds: 3));

    // 시뮬레이션 결과
    final simulatedResults = [
      {'name': '쓰레기', 'confidence': 87},
      {'name': '손상된 도로', 'confidence': 73},
      {'name': '안전 위험 요소', 'confidence': 65},
    ];

    setState(() {
      _analysisResults = simulatedResults;
      _isAnalyzing = false;
    });

    _showSnackBar('AI 분석이 완료되었습니다 (시뮬레이션)');
  }

  // 분석 결과를 폼에 적용
  void _applyAnalysisToForm() {
    if (_analysisResults.isEmpty) return;

    final bestResult = _analysisResults.first;

    // 제목 자동 생성
    if (_titleController.text.isEmpty) {
      _titleController.text = '${bestResult['name']} 발견 신고';
    }

    // 내용 자동 생성
    if (_contentController.text.isEmpty) {
      final analysisText = _analysisResults
          .map((r) => '${r['name']} (${r['confidence']}%)')
          .join(', ');

      _contentController.text =
          'AI 분석 결과:\n$analysisText\n\n위치: ${_currentAddress ?? '정보 없음'}';
    }

    // 카테고리 자동 선택
    _selectedCategory = _mapDetectionToCategory(bestResult['name']);

    setState(() {});
    _showSnackBar('분석 결과가 폼에 적용되었습니다');
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
        timeLimit: const Duration(seconds: 10),
      );

      setState(() {
        _currentPosition = position;
        // 시뮬레이션 주소
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
