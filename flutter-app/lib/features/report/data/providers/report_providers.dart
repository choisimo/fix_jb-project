import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/report_repository.dart';
import '../data/services/report_service.dart';
import '../domain/models/report_types.dart';

part 'report_providers.g.dart';

/// 리포트 서비스 Provider
@riverpod
ReportService reportService(ReportServiceRef ref) {
  return ReportService();
}

/// 리포트 리포지토리 Provider
@riverpod
ReportRepository reportRepository(ReportRepositoryRef ref) {
  final reportService = ref.watch(reportServiceProvider);
  return ReportRepository(reportService: reportService);
}

/// 리포트 목록 Provider
@riverpod
class ReportList extends _$ReportList {
  @override
  Future<List<Report>> build() async {
    final repository = ref.watch(reportRepositoryProvider);
    return repository.getReports();
  }

  /// 리포트 목록 새로고침
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    final repository = ref.read(reportRepositoryProvider);
    try {
      final reports = await repository.getReports();
      state = AsyncValue.data(reports);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// 새 리포트 추가
  Future<void> addReport(Report report) async {
    final repository = ref.read(reportRepositoryProvider);
    try {
      await repository.createReport(report);
      await refresh();
    } catch (error) {
      rethrow;
    }
  }

  /// 리포트 업데이트
  Future<void> updateReport(Report report) async {
    final repository = ref.read(reportRepositoryProvider);
    try {
      await repository.updateReport(report);
      await refresh();
    } catch (error) {
      rethrow;
    }
  }

  /// 리포트 삭제
  Future<void> deleteReport(String reportId) async {
    final repository = ref.read(reportRepositoryProvider);
    try {
      await repository.deleteReport(reportId);
      await refresh();
    } catch (error) {
      rethrow;
    }
  }
}

/// 내 리포트 목록 Provider
@riverpod
class MyReports extends _$MyReports {
  @override
  Future<List<Report>> build() async {
    final repository = ref.watch(reportRepositoryProvider);
    return repository.getMyReports();
  }

  /// 새로고침
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    final repository = ref.read(reportRepositoryProvider);
    try {
      final reports = await repository.getMyReports();
      state = AsyncValue.data(reports);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

/// 리포트 상세 Provider
@riverpod
class ReportDetail extends _$ReportDetail {
  @override
  Future<Report?> build(String reportId) async {
    final repository = ref.watch(reportRepositoryProvider);
    return repository.getReportById(reportId);
  }

  /// 상세 정보 새로고침
  Future<void> refresh(String reportId) async {
    state = const AsyncValue.loading();
    final repository = ref.read(reportRepositoryProvider);
    try {
      final report = await repository.getReportById(reportId);
      state = AsyncValue.data(report);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

/// 리포트 필터 Provider
@riverpod
class ReportFilter extends _$ReportFilter {
  @override
  ReportFilterData build() {
    return const ReportFilterData();
  }

  void updateType(ReportType? type) {
    state = state.copyWith(type: type);
  }

  void updateStatus(ReportStatus? status) {
    state = state.copyWith(status: status);
  }

  void updatePriority(Priority? priority) {
    state = state.copyWith(priority: priority);
  }

  void updateDateRange(DateTime? startDate, DateTime? endDate) {
    state = state.copyWith(startDate: startDate, endDate: endDate);
  }

  void reset() {
    state = const ReportFilterData();
  }
}

/// 리포트 필터 데이터
class ReportFilterData {
  final ReportType? type;
  final ReportStatus? status;
  final Priority? priority;
  final DateTime? startDate;
  final DateTime? endDate;

  const ReportFilterData({
    this.type,
    this.status,
    this.priority,
    this.startDate,
    this.endDate,
  });

  ReportFilterData copyWith({
    ReportType? type,
    ReportStatus? status,
    Priority? priority,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return ReportFilterData(
      type: type ?? this.type,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}

// 임시 Report 클래스
class Report {
  final String id;
  final String title;
  final String description;
  final ReportType type;
  final ReportStatus status;
  final Priority priority;
  final DateTime createdAt;

  Report({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.status,
    required this.priority,
    required this.createdAt,
  });
}