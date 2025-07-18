import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../domain/models/report.dart';
import '../../domain/services/report_service.dart';
import '../../../../core/providers/service_provider.dart';

// Report Service provider
final reportServiceProvider = Provider<ReportService>((ref) {
  final dio = ref.watch(dioProvider);
  return ReportService(dio);
});

// Report list provider
final reportListProvider = StateNotifierProvider<ReportListNotifier, AsyncValue<List<Report>>>((ref) {
  return ReportListNotifier(ref);
});

class ReportListNotifier extends StateNotifier<AsyncValue<List<Report>>> {
  final Ref _ref;
  String? _searchQuery;
  ReportType? _selectedType;
  ReportStatus? _selectedStatus;
  Priority? _selectedPriority;
  
  ReportListNotifier(this._ref) : super(const AsyncValue.loading()) {
    // Load reports when created
    refresh();
  }
  
  void setSearchQuery(String? query) {
    _searchQuery = query?.isNotEmpty == true ? query : null;
    refresh();
  }
  
  void setFilters({
    ReportType? type,
    ReportStatus? status,
    Priority? priority,
  }) {
    _selectedType = type;
    _selectedStatus = status;
    _selectedPriority = priority;
    refresh();
  }

  Future<void> addReport(Report report) async {
    // 목록에 추가
    state.whenData((reports) {
      state = AsyncValue.data([...reports, report]);
    });
    
    // Optionally sync with backend
    // final reportService = _ref.read(reportServiceProvider);
    // Try to sync new report if needed
  }

  Future<void> refresh() async {
    try {
      state = const AsyncValue.loading();
      final reportService = _ref.read(reportServiceProvider);
      
      // 백엔드에서 모든 리포트를 가져옵니다 (추후 서버 측 필터링 지원 시 파라미터 추가)
      final reports = await reportService.getReports();
      
      // 클라이언트 측에서 필터링 적용
      final filteredReports = _filterReports(reports);
      
      state = AsyncValue.data(filteredReports);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
  
  // 로컬 필터링 함수
  List<Report> _filterReports(List<Report> reports) {
    return reports.where((report) {
      // 타입 필터 적용
      if (_selectedType != null && report.type != _selectedType) {
        return false;
      }
      
      // 상태 필터 적용
      if (_selectedStatus != null && report.status != _selectedStatus) {
        return false;
      }
      
      // 우선순위 필터 적용
      if (_selectedPriority != null && report.priority != _selectedPriority) {
        return false;
      }
      
      // 검색어 적용
      if (_searchQuery != null) {
        final query = _searchQuery!.toLowerCase();
        return report.title.toLowerCase().contains(query) ||
               report.description.toLowerCase().contains(query);
      }
      
      return true;
    }).toList();
  }
}