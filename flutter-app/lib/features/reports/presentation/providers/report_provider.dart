import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import '../../domain/entities/report.dart';
import '../../domain/requests/report_create_request.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/ai/hybrid_analysis_manager.dart';

class ReportProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  final ImagePicker _imagePicker = ImagePicker();
  final HybridAnalysisManager _analysisManager = HybridAnalysisManager.instance;

  // 기존 리스트 관련 상태
  List<Report> _reports = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 0;
  String _searchQuery = '';

  // 새로운 신고서 작성 관련 상태
  final List<File> _selectedImages = [];
  final Map<String, HybridAnalysisResult> _analysisResults = {};
  Position? _currentPosition;
  String _title = '';
  String _content = '';
  ReportCategory _category = ReportCategory.safety;
  bool _isCreating = false;
  bool _isAnalyzing = false;
  String? _error;

  // 기존 Getter들
  List<Report> get reports => _reports;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;

  // 새로운 Getter들
  List<File> get selectedImages => List.unmodifiable(_selectedImages);
  Map<String, HybridAnalysisResult> get analysisResults => Map.unmodifiable(_analysisResults);
  Position? get currentPosition => _currentPosition;
  String get title => _title;
  String get content => _content;
  ReportCategory get category => _category;
  bool get isCreating => _isCreating;
  bool get isAnalyzing => _isAnalyzing;
  String? get error => _error;
  bool get canSubmit => _title.isNotEmpty && _content.isNotEmpty;

  // 위치 정보 문자열
  String get locationText {
    if (_currentPosition == null) return '위치 정보 없음';
    return '위도: ${_currentPosition!.latitude.toStringAsFixed(6)}\n'
        '경도: ${_currentPosition!.longitude.toStringAsFixed(6)}';
  }

  Future<void> loadReports() async {
    if (_isLoading) return;

    _setLoading(true);
    _currentPage = 0;

    try {
      final response = await _apiClient.get('/reports', queryParameters: {
        'page': _currentPage,
        'size': 20,
        'search': _searchQuery,
      });

      if (response.statusCode == 200) {
        final data = response.data;
        _reports = (data['content'] as List)
            .map((json) => Report.fromJson(json))
            .toList();
        _hasMore = !data['last'];
      }
    } catch (e) {
      debugPrint('Load reports error: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadMoreReports() async {
    if (_isLoading || !_hasMore) return;

    _setLoading(true);
    _currentPage++;

    try {
      final response = await _apiClient.get('/reports', queryParameters: {
        'page': _currentPage,
        'size': 20,
        'search': _searchQuery,
      });

      if (response.statusCode == 200) {
        final data = response.data;
        final newReports = (data['content'] as List)
            .map((json) => Report.fromJson(json))
            .toList();
        _reports.addAll(newReports);
        _hasMore = !data['last'];
      }
    } catch (e) {
      debugPrint('Load more reports error: $e');
      _currentPage--; // 실패 시 페이지 번호 되돌리기
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshReports() async {
    _currentPage = 0;
    _hasMore = true;
    await loadReports();
  }

  void searchReports(String query) {
    _searchQuery = query;
    loadReports();
  }

  Future<Report?> getReport(String id) async {
    try {
      final response = await _apiClient.get('/reports/$id');
      if (response.statusCode == 200) {
        return Report.fromJson(response.data);
      }
    } catch (e) {
      debugPrint('Get report error: $e');
    }
    return null;
  }

  Future<bool> createReport(Map<String, dynamic> reportData) async {
    try {
      final response = await _apiClient.post('/reports', data: reportData);
      if (response.statusCode == 201) {
        await refreshReports(); // 목록 새로고침
        return true;
      }
    } catch (e) {
      debugPrint('Create report error: $e');
    }
    return false;
  }

  Future<bool> updateReport(String id, Map<String, dynamic> reportData) async {
    try {
      final response = await _apiClient.put('/reports/$id', data: reportData);
      if (response.statusCode == 200) {
        await refreshReports(); // 목록 새로고침
        return true;
      }
    } catch (e) {
      debugPrint('Update report error: $e');
    }
    return false;
  }

  Future<bool> deleteReport(String id) async {
    try {
      final response = await _apiClient.delete('/reports/$id');
      if (response.statusCode == 204) {
        _reports.removeWhere((report) => report.id == id);
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Delete report error: $e');
    }
    return false;
  }

  // 이미지 관련 메서드
  Future<void> pickImageFromCamera() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null && _selectedImages.length < 5) {
        final imageFile = File(pickedFile.path);
        _selectedImages.add(imageFile);
        _error = null;
        notifyListeners();

        // 자동 이미지 분석 수행
        await _analyzeImage(imageFile);
      }
    } catch (e) {
      _error = '카메라 오류: $e';
      notifyListeners();
    }
  }

  Future<void> pickImageFromGallery() async {
    try {
      final pickedFiles = await _imagePicker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      final newImages = <File>[];
      for (var file in pickedFiles) {
        if (_selectedImages.length >= 5) break;
        final imageFile = File(file.path);
        _selectedImages.add(imageFile);
        newImages.add(imageFile);
      }
      
      _error = null;
      notifyListeners();

      // 새로 추가된 이미지들 자동 분석
      for (final imageFile in newImages) {
        await _analyzeImage(imageFile);
      }
    } catch (e) {
      _error = '갤러리 오류: $e';
      notifyListeners();
    }
  }

  /// 이미지 자동 분석 수행
  Future<void> _analyzeImage(File imageFile) async {
    try {
      debugPrint('🔍 이미지 자동 분석 시작: ${imageFile.path}');
      
      _isAnalyzing = true;
      notifyListeners();

      // 하이브리드 분석 수행 (빠른 모드)
      final result = await _analysisManager.analyzeImage(
        imageFile,
        mode: AnalysisMode.comprehensive,
        enableOCR: true,
        enableObjectDetection: true,
        enableAIAgent: true,
      );

      _analysisResults[imageFile.path] = result;
      
      debugPrint('✅ 이미지 분석 완료: ${result.summary}');

      // AI 분석 결과를 기반으로 자동 텍스트 보완
      _autoCompleteFromAnalysis(result);

    } catch (e) {
      debugPrint('❌ 이미지 분석 오류: $e');
      _error = '이미지 분석 오류: $e';
    } finally {
      _isAnalyzing = false;
      notifyListeners();
    }
  }

  /// 분석 결과를 기반으로 제목과 내용 자동 보완
  void _autoCompleteFromAnalysis(HybridAnalysisResult result) {
    if (!result.isSuccessful) return;

    final suggestions = <String>[];

    // OCR 텍스트에서 주요 정보 추출
    if (result.ocrResult?.hasText == true) {
      final extractedInfo = result.ocrResult!.extractedInfo;
      
      if (extractedInfo.primaryAddress.isNotEmpty) {
        suggestions.add('위치: ${extractedInfo.primaryAddress}');
      }
      
      if (extractedInfo.keywords.isNotEmpty) {
        suggestions.add('키워드: ${extractedInfo.keywords.join(', ')}');
      }
    }

    // 객체 감지 결과 추가
    if (result.detectionResult?.hasDetections == true) {
      final detections = result.detectionResult!.detections
          .map((d) => d.name)
          .take(3)
          .join(', ');
      suggestions.add('감지된 객체: $detections');
    }

    // AI 분석 결과 추가
    if (result.aiAnalysisResult?.isSuccessful == true) {
      final analysis = result.aiAnalysisResult!.analysis;
      
      // 제목이 비어있으면 AI 요약을 기반으로 제안
      if (_title.isEmpty && analysis.summary.isNotEmpty) {
        final titleSuggestion = _generateTitleFromSummary(analysis.summary);
        if (titleSuggestion.isNotEmpty) {
          _title = titleSuggestion;
        }
      }
      
      // 내용에 AI 분석 결과 추가
      if (suggestions.isNotEmpty) {
        final autoContent = '''
분석 결과:
${suggestions.join('\n')}

위험도: ${analysis.riskLevelText} (${analysis.riskLevel}/5)
긴급도: ${analysis.urgencyText}
담당 부서: ${analysis.responsibleDepartment}

추천 조치사항:
${analysis.recommendations.map((r) => '• $r').join('\n')}

${_content.isNotEmpty ? '\n추가 내용:\n$_content' : ''}
        '''.trim();
        
        _content = autoContent;
      }

      // 카테고리 자동 설정
      _autoSetCategoryFromAnalysis(analysis);
    }

    notifyListeners();
  }

  /// AI 요약에서 제목 생성
  String _generateTitleFromSummary(String summary) {
    final words = summary.split(' ').take(8).join(' ');
    if (words.length > 50) {
      return '${words.substring(0, 47)}...';
    }
    return words;
  }

  /// AI 분석 결과를 기반으로 카테고리 자동 설정
  void _autoSetCategoryFromAnalysis(AIAnalysis analysis) {
    final summary = analysis.summary.toLowerCase();
    final recommendations = analysis.recommendations.join(' ').toLowerCase();
    
    if (summary.contains('도로') || summary.contains('포트홀') || 
        summary.contains('교통') || recommendations.contains('도로')) {
      _category = ReportCategory.safety;
    } else if (summary.contains('건설') || summary.contains('공사') ||
               recommendations.contains('건설')) {
      _category = ReportCategory.progress;
    } else if (summary.contains('품질') || summary.contains('불량') ||
               analysis.riskLevel >= 3) {
      _category = ReportCategory.quality;
    } else if (summary.contains('유지') || summary.contains('보수') ||
               recommendations.contains('점검')) {
      _category = ReportCategory.maintenance;
    }
  }

  /// 특정 이미지 수동 재분석
  Future<void> reanalyzeImage(String imagePath) async {
    final imageFile = File(imagePath);
    if (await imageFile.exists()) {
      await _analyzeImage(imageFile);
    }
  }

  /// 모든 이미지 배치 분석
  Future<void> analyzeAllImages() async {
    if (_selectedImages.isEmpty) return;

    try {
      _isAnalyzing = true;
      notifyListeners();

      final results = await _analysisManager.analyzeBatch(
        _selectedImages,
        maxConcurrency: 2,
        mode: AnalysisMode.comprehensive,
      );

      for (final result in results) {
        _analysisResults[result.imagePath] = result;
      }

      // 가장 신뢰도 높은 결과로 텍스트 보완
      final bestResult = results
          .where((r) => r.isSuccessful)
          .reduce((a, b) => 
              (a.aiAnalysisResult?.confidence ?? 0) > 
              (b.aiAnalysisResult?.confidence ?? 0) ? a : b);
      
      _autoCompleteFromAnalysis(bestResult);

    } catch (e) {
      _error = '배치 분석 오류: $e';
    } finally {
      _isAnalyzing = false;
      notifyListeners();
    }
  }

  void removeImage(int index) {
    if (index >= 0 && index < _selectedImages.length) {
      final removedImagePath = _selectedImages[index].path;
      _selectedImages.removeAt(index);
      
      // 해당 이미지의 분석 결과도 제거
      _analysisResults.remove(removedImagePath);
      
      notifyListeners();
    }
  }

  // 위치 관련 메서드
  Future<void> getCurrentLocation() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('위치 서비스가 비활성화되어 있습니다.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('위치 권한이 거부되었습니다.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('위치 권한이 영구적으로 거부되었습니다.\n설정에서 권한을 허용해주세요.');
      }

      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 폼 업데이트 메서드
  void updateTitle(String title) {
    _title = title.trim();
    notifyListeners();
  }

  void updateContent(String content) {
    _content = content.trim();
    notifyListeners();
  }

  void updateCategory(ReportCategory category) {
    _category = category;
    notifyListeners();
  }

  // 제출 메서드
  Future<bool> submitReport() async {
    if (!canSubmit) return false;

    try {
      _isCreating = true;
      _error = null;
      notifyListeners();

      // 분석 결과를 포함한 보고서 데이터 구성
      final analysisData = _buildAnalysisData();

      final report = ReportCreateRequest(
        title: _title,
        content: _content,
        category: _category,
        latitude: _currentPosition?.latitude,
        longitude: _currentPosition?.longitude,
        images: _selectedImages,
      );

      // API 호출 (multipart/form-data 처리) - 분석 결과 포함
      final response = await _apiClient.postMultipart(
          '/reports',
          {
            'title': report.title,
            'content': report.content,
            'category': report.category.name,
            'latitude': report.latitude?.toString(),
            'longitude': report.longitude?.toString(),
            'analysisData': analysisData, // 분석 결과 추가
          },
          _selectedImages);

      if (response.statusCode == 201) {
        // 성공 시 폼 초기화
        clearForm();
        // 리스트 새로고침
        await refreshReports();
        return true;
      } else {
        _error = '서버 오류가 발생했습니다. (${response.statusCode})';
        return false;
      }
    } catch (e) {
      _error = '제출 실패: $e';
      return false;
    } finally {
      _isCreating = false;
      notifyListeners();
    }
  }

  /// 분석 결과 데이터 구성
  String _buildAnalysisData() {
    if (_analysisResults.isEmpty) return '';

    final analysisDataList = <Map<String, dynamic>>[];
    
    for (final entry in _analysisResults.entries) {
      final result = entry.value;
      if (result.isSuccessful) {
        analysisDataList.add(result.toJson());
      }
    }

    // JSON 문자열로 직렬화
    try {
      return analysisDataList.toString(); // 간단한 문자열 변환
    } catch (e) {
      debugPrint('분석 데이터 직렬화 오류: $e');
      return '';
    }
  }

  // 폼 초기화
  void clearForm() {
    _selectedImages.clear();
    _analysisResults.clear();
    _currentPosition = null;
    _title = '';
    _content = '';
    _category = ReportCategory.safety;
    _error = null;
    notifyListeners();
  }

  // 임시 저장 기능 (오프라인 지원)
  Future<void> saveDraft() async {
    // TODO: 로컬 스토리지에 임시 저장
    // SharedPreferences나 Hive를 사용하여 구현
  }

  // 임시 저장된 데이터 불러오기
  Future<void> loadDraft() async {
    // TODO: 로컬 스토리지에서 임시 저장된 데이터 불러오기
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
