import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/report_repository.dart';
import '../../domain/models/report.dart';
import '../../domain/models/report_models.dart';
import '../../domain/models/report_state.dart';

part 'report_list_controller.g.dart';

@riverpod
class ReportListController extends _$ReportListController {
  @override
  ReportListState build() {
    return const ReportListState();
  }

  Future<void> loadReports({
    ReportListRequest? request,
    bool refresh = false,
  }) async {
    final currentRequest = request ?? const ReportListRequest();
    
    if (refresh) {
      state = state.copyWith(
        status: ReportListStatus.loading,
        error: null,
      );
    }

    try {
      final repository = ref.read(reportRepositoryProvider);
      final response = await repository.getReports(currentRequest);
      
      state = state.copyWith(
        status: ReportListStatus.loaded,
        reports: response.reports,
        currentPage: response.currentPage,
        totalPages: response.totalPages,
        totalElements: response.totalElements,
        hasNext: response.hasNext,
        lastRequest: currentRequest,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        status: ReportListStatus.error,
        error: e.toString(),
      );
    }
  }

  Future<void> loadMoreReports() async {
    if (!state.canLoadMore || state.lastRequest == null) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      final repository = ref.read(reportRepositoryProvider);
      final nextPageRequest = state.lastRequest!.copyWith(
        page: state.currentPage + 1,
      );
      
      final response = await repository.getReports(nextPageRequest);
      
      state = state.copyWith(
        reports: [...state.reports, ...response.reports],
        currentPage: response.currentPage,
        totalPages: response.totalPages,
        totalElements: response.totalElements,
        hasNext: response.hasNext,
        isLoadingMore: false,
        lastRequest: nextPageRequest,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refreshReports() async {
    await loadReports(request: state.lastRequest, refresh: true);
  }

  Future<void> searchReports(String query) async {
    final request = (state.lastRequest ?? const ReportListRequest()).copyWith(
      search: query.isEmpty ? null : query,
      page: 0,
    );
    
    await loadReports(request: request, refresh: true);
  }

  Future<void> filterReports({
    ReportType? type,
    ReportStatus? status,
    Priority? priority,
    String? sortBy,
    String? sortDirection,
  }) async {
    final request = (state.lastRequest ?? const ReportListRequest()).copyWith(
      type: type,
      status: status,
      priority: priority,
      sortBy: sortBy,
      sortDirection: sortDirection ?? 'desc',
      page: 0,
    );
    
    await loadReports(request: request, refresh: true);
  }

  Future<void> clearFilters() async {
    const request = ReportListRequest();
    await loadReports(request: request, refresh: true);
  }

  Future<void> toggleLike(String reportId) async {
    try {
      final repository = ref.read(reportRepositoryProvider);
      final reportIndex = state.reports.indexWhere((r) => r.id == reportId);
      
      if (reportIndex == -1) return;
      
      final report = state.reports[reportIndex];
      final updatedReports = List<Report>.from(state.reports);
      
      if (report.isLiked) {
        await repository.unlikeReport(reportId);
        updatedReports[reportIndex] = report.copyWith(
          isLiked: false,
          likeCount: report.likeCount - 1,
        );
      } else {
        await repository.likeReport(reportId);
        updatedReports[reportIndex] = report.copyWith(
          isLiked: true,
          likeCount: report.likeCount + 1,
        );
      }
      
      state = state.copyWith(reports: updatedReports);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> toggleBookmark(String reportId) async {
    try {
      final repository = ref.read(reportRepositoryProvider);
      final reportIndex = state.reports.indexWhere((r) => r.id == reportId);
      
      if (reportIndex == -1) return;
      
      final report = state.reports[reportIndex];
      final updatedReports = List<Report>.from(state.reports);
      
      if (report.isBookmarked) {
        await repository.unbookmarkReport(reportId);
        updatedReports[reportIndex] = report.copyWith(isBookmarked: false);
      } else {
        await repository.bookmarkReport(reportId);
        updatedReports[reportIndex] = report.copyWith(isBookmarked: true);
      }
      
      state = state.copyWith(reports: updatedReports);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}