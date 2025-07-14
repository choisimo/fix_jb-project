import '../../domain/models/report_types.dart';

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