// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Report _$ReportFromJson(Map<String, dynamic> json) => Report(
      id: json['id'] as String,
      title: json['title'] as String,
    );

Map<String, dynamic> _$ReportToJson(Report instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
    };

_$AdminStateImpl _$$AdminStateImplFromJson(Map<String, dynamic> json) =>
    _$AdminStateImpl(
      currentAdmin: json['currentAdmin'] == null
          ? null
          : AdminUser.fromJson(json['currentAdmin'] as Map<String, dynamic>),
      dashboardData: json['dashboardData'] == null
          ? null
          : AdminDashboardData.fromJson(
              json['dashboardData'] as Map<String, dynamic>),
      managedReports: (json['managedReports'] as List<dynamic>?)
              ?.map((e) => Report.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      teamMembers: (json['teamMembers'] as List<dynamic>?)
              ?.map((e) => AdminUser.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      assignments: (json['assignments'] as List<dynamic>?)
              ?.map((e) => ReportAssignment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      recentActivities: (json['recentActivities'] as List<dynamic>?)
              ?.map((e) => RecentActivity.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      isLoading: json['isLoading'] as bool? ?? false,
      isDashboardLoading: json['isDashboardLoading'] as bool? ?? false,
      isReportsLoading: json['isReportsLoading'] as bool? ?? false,
      isUsersLoading: json['isUsersLoading'] as bool? ?? false,
      error: json['error'] as String?,
      filters: json['filters'] as Map<String, dynamic>?,
      currentView:
          $enumDecodeNullable(_$AdminViewModeEnumMap, json['currentView']),
      lastDataRefresh: json['lastDataRefresh'] == null
          ? null
          : DateTime.parse(json['lastDataRefresh'] as String),
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 0,
      currentPage: (json['currentPage'] as num?)?.toInt() ?? 1,
      pageSize: (json['pageSize'] as num?)?.toInt() ?? 20,
      statistics: json['statistics'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$AdminStateImplToJson(_$AdminStateImpl instance) =>
    <String, dynamic>{
      'currentAdmin': instance.currentAdmin,
      'dashboardData': instance.dashboardData,
      'managedReports': instance.managedReports,
      'teamMembers': instance.teamMembers,
      'assignments': instance.assignments,
      'recentActivities': instance.recentActivities,
      'isLoading': instance.isLoading,
      'isDashboardLoading': instance.isDashboardLoading,
      'isReportsLoading': instance.isReportsLoading,
      'isUsersLoading': instance.isUsersLoading,
      'error': instance.error,
      'filters': instance.filters,
      'currentView': _$AdminViewModeEnumMap[instance.currentView],
      'lastDataRefresh': instance.lastDataRefresh?.toIso8601String(),
      'totalPages': instance.totalPages,
      'currentPage': instance.currentPage,
      'pageSize': instance.pageSize,
      'statistics': instance.statistics,
    };

const _$AdminViewModeEnumMap = {
  AdminViewMode.dashboard: 'dashboard',
  AdminViewMode.reports: 'reports',
  AdminViewMode.users: 'users',
  AdminViewMode.analytics: 'analytics',
  AdminViewMode.settings: 'settings',
  AdminViewMode.aiManagement: 'ai_management',
};
