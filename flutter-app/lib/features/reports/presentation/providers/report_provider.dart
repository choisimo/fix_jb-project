import 'package:flutter/foundation.dart';
import '../../domain/entities/report.dart';
import '../../../../core/network/api_client.dart';

class ReportProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  
  List<Report> _reports = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 0;
  String _searchQuery = '';

  List<Report> get reports => _reports;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;

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

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
