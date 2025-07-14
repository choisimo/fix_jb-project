import 'package:freezed_annotation/freezed_annotation.dart';
import 'admin_user.dart';
import 'admin_dashboard_data.dart';
import 'report_assignment.dart';
// import '../../report/domain/models/report.dart';  // 임시 주석 처리

part 'admin_state.freezed.dart';
part 'admin_state.g.dart';

// 임시 Report 클래스
@JsonSerializable()
class Report {
  final String id;
  final String title;
  
  Report({required this.id, required this.title});
  
  factory Report.fromJson(Map<String, dynamic> json) => _$ReportFromJson(json);
  Map<String, dynamic> toJson() => _$ReportToJson(this);
}

@freezed
class AdminState with _$AdminState {
  const factory AdminState({
    AdminUser? currentAdmin,
    AdminDashboardData? dashboardData,
    @Default([]) List<Report> managedReports,
    @Default([]) List<AdminUser> teamMembers,
    @Default([]) List<ReportAssignment> assignments,
    @Default([]) List<RecentActivity> recentActivities,
    @Default(false) bool isLoading,
    @Default(false) bool isDashboardLoading,
    @Default(false) bool isReportsLoading,
    @Default(false) bool isUsersLoading,
    String? error,
    Map<String, dynamic>? filters,
    AdminViewMode? currentView,
    DateTime? lastDataRefresh,
    @Default(0) int totalPages,
    @Default(1) int currentPage,
    @Default(20) int pageSize,
    Map<String, dynamic>? statistics,
  }) = _AdminState;

  factory AdminState.fromJson(Map<String, dynamic> json) =>
      _$AdminStateFromJson(json);
}

@JsonEnum()
enum AdminViewMode {
  @JsonValue('dashboard')
  dashboard,
  @JsonValue('reports')
  reports,
  @JsonValue('users')
  users,
  @JsonValue('analytics')
  analytics,
  @JsonValue('settings')
  settings,
  @JsonValue('ai_management')
  aiManagement,
}