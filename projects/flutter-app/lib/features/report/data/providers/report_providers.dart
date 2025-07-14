import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/report.dart';

// Report providers
final reportListProvider = StateNotifierProvider<ReportListNotifier, AsyncValue<List<Report>>>((ref) {
  return ReportListNotifier();
});

class ReportListNotifier extends StateNotifier<AsyncValue<List<Report>>> {
  ReportListNotifier() : super(const AsyncValue.data([]));

  Future<void> addReport(Report report) async {
    // 목록에 추가
    state.whenData((reports) {
      state = AsyncValue.data([...reports, report]);
    });
  }

  Future<void> refresh() async {
    // 리포트 목록 새로고침
    state = const AsyncValue.data([]);
  }
}