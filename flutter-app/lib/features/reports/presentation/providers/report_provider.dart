import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import '../../domain/entities/report.dart';
import '../../domain/requests/report_create_request.dart';
import '../../../../core/network/api_client.dart';

class ReportProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  final ImagePicker _imagePicker = ImagePicker();

  // 기존 리스트 관련 상태
  List<Report> _reports = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 0;
  String _searchQuery = '';

  // 새로운 신고서 작성 관련 상태
  final List<File> _selectedImages = [];
  Position? _currentPosition;
  String _title = '';
  String _content = '';
  ReportCategory _category = ReportCategory.safety;
  bool _isCreating = false;
  String? _error;

  // 기존 Getter들
  List<Report> get reports => _reports;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;

  // 새로운 Getter들
  List<File> get selectedImages => List.unmodifiable(_selectedImages);
  Position? get currentPosition => _currentPosition;
  String get title => _title;
  String get content => _content;
  ReportCategory get category => _category;
  bool get isCreating => _isCreating;
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
        _selectedImages.add(File(pickedFile.path));
        _error = null;
        notifyListeners();
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

      for (var file in pickedFiles) {
        if (_selectedImages.length >= 5) break;
        _selectedImages.add(File(file.path));
      }
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = '갤러리 오류: $e';
      notifyListeners();
    }
  }

  void removeImage(int index) {
    if (index >= 0 && index < _selectedImages.length) {
      _selectedImages.removeAt(index);
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

      final report = ReportCreateRequest(
        title: _title,
        content: _content,
        category: _category,
        latitude: _currentPosition?.latitude,
        longitude: _currentPosition?.longitude,
        images: _selectedImages,
      );

      // API 호출 (multipart/form-data 처리)
      final response = await _apiClient.postMultipart(
          '/reports',
          {
            'title': report.title,
            'content': report.content,
            'category': report.category.name,
            'latitude': report.latitude?.toString(),
            'longitude': report.longitude?.toString(),
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

  // 폼 초기화
  void clearForm() {
    _selectedImages.clear();
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
