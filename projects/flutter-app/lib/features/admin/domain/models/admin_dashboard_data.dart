import 'package:freezed_annotation/freezed_annotation.dart';

part 'admin_dashboard_data.freezed.dart';
part 'admin_dashboard_data.g.dart';

@freezed
class AdminDashboardData with _$AdminDashboardData {
  const factory AdminDashboardData({
    required int totalReports,
    required int pendingReports,
    required int todayReports,
    required int thisWeekReports,
    required int thisMonthReports,
    required double completionRate,
    required double averageProcessingHours,
    required int urgentReports,
    required int activeAdmins,
    required List<ChartData> dailyTrend,
    required List<ChartData> categoryDistribution,
    required List<ChartData> statusDistribution,
    required List<ChartData> regionDistribution,
    required List<ProcessingTimeData> processingTimes,
    required List<AdminPerformanceData> teamPerformance,
    required DateTime lastUpdated,
    SystemHealthData? systemHealth,
    List<RecentActivity>? recentActivities,
  }) = _AdminDashboardData;

  factory AdminDashboardData.fromJson(Map<String, dynamic> json) =>
      _$AdminDashboardDataFromJson(json);
}

@freezed
class ChartData with _$ChartData {
  const factory ChartData({
    required String label,
    required double value,
    String? color,
    Map<String, dynamic>? metadata,
  }) = _ChartData;

  factory ChartData.fromJson(Map<String, dynamic> json) =>
      _$ChartDataFromJson(json);
}

@freezed
class ProcessingTimeData with _$ProcessingTimeData {
  const factory ProcessingTimeData({
    required String category,
    required double averageHours,
    required double targetHours,
    required int count,
    @Default(0.0) double efficiency,
  }) = _ProcessingTimeData;

  factory ProcessingTimeData.fromJson(Map<String, dynamic> json) =>
      _$ProcessingTimeDataFromJson(json);
}

@freezed
class AdminPerformanceData with _$AdminPerformanceData {
  const factory AdminPerformanceData({
    required String adminId,
    required String adminName,
    required int processedCount,
    required double averageTime,
    required double satisfactionScore,
    required int currentAssignments,
    @Default(100.0) double workloadPercentage,
  }) = _AdminPerformanceData;

  factory AdminPerformanceData.fromJson(Map<String, dynamic> json) =>
      _$AdminPerformanceDataFromJson(json);
}

@freezed
class SystemHealthData with _$SystemHealthData {
  const factory SystemHealthData({
    @Default(100.0) double cpuUsage,
    @Default(100.0) double memoryUsage,
    @Default(100.0) double diskUsage,
    @Default(0) int activeConnections,
    @Default(0.0) double responseTime,
    @Default(99.9) double uptime,
    @Default(SystemStatus.healthy) SystemStatus status,
    List<String>? alerts,
  }) = _SystemHealthData;

  factory SystemHealthData.fromJson(Map<String, dynamic> json) =>
      _$SystemHealthDataFromJson(json);
}

@freezed
class RecentActivity with _$RecentActivity {
  const factory RecentActivity({
    required String id,
    required String description,
    required String adminName,
    required DateTime timestamp,
    required ActivityType type,
    String? reportId,
    Map<String, dynamic>? metadata,
  }) = _RecentActivity;

  factory RecentActivity.fromJson(Map<String, dynamic> json) =>
      _$RecentActivityFromJson(json);
}

@JsonEnum()
enum SystemStatus {
  @JsonValue('healthy')
  healthy,
  @JsonValue('warning')
  warning,
  @JsonValue('critical')
  critical,
  @JsonValue('maintenance')
  maintenance,
}

@JsonEnum()
enum ActivityType {
  @JsonValue('report_assigned')
  reportAssigned,
  @JsonValue('report_completed')
  reportCompleted,
  @JsonValue('status_changed')
  statusChanged,
  @JsonValue('comment_added')
  commentAdded,
  @JsonValue('user_created')
  userCreated,
  @JsonValue('settings_updated')
  settingsUpdated,
  @JsonValue('login')
  login,
  @JsonValue('logout')
  logout,
}