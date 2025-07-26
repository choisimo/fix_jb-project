// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_dashboard_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AdminDashboardDataImpl _$$AdminDashboardDataImplFromJson(
        Map<String, dynamic> json) =>
    _$AdminDashboardDataImpl(
      totalReports: (json['totalReports'] as num).toInt(),
      pendingReports: (json['pendingReports'] as num).toInt(),
      todayReports: (json['todayReports'] as num).toInt(),
      thisWeekReports: (json['thisWeekReports'] as num).toInt(),
      thisMonthReports: (json['thisMonthReports'] as num).toInt(),
      completionRate: (json['completionRate'] as num).toDouble(),
      averageProcessingHours:
          (json['averageProcessingHours'] as num).toDouble(),
      urgentReports: (json['urgentReports'] as num).toInt(),
      activeAdmins: (json['activeAdmins'] as num).toInt(),
      dailyTrend: (json['dailyTrend'] as List<dynamic>)
          .map((e) => ChartData.fromJson(e as Map<String, dynamic>))
          .toList(),
      categoryDistribution: (json['categoryDistribution'] as List<dynamic>)
          .map((e) => ChartData.fromJson(e as Map<String, dynamic>))
          .toList(),
      statusDistribution: (json['statusDistribution'] as List<dynamic>)
          .map((e) => ChartData.fromJson(e as Map<String, dynamic>))
          .toList(),
      regionDistribution: (json['regionDistribution'] as List<dynamic>)
          .map((e) => ChartData.fromJson(e as Map<String, dynamic>))
          .toList(),
      processingTimes: (json['processingTimes'] as List<dynamic>)
          .map((e) => ProcessingTimeData.fromJson(e as Map<String, dynamic>))
          .toList(),
      teamPerformance: (json['teamPerformance'] as List<dynamic>)
          .map((e) => AdminPerformanceData.fromJson(e as Map<String, dynamic>))
          .toList(),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      systemHealth: json['systemHealth'] == null
          ? null
          : SystemHealthData.fromJson(
              json['systemHealth'] as Map<String, dynamic>),
      recentActivities: (json['recentActivities'] as List<dynamic>?)
          ?.map((e) => RecentActivity.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$AdminDashboardDataImplToJson(
        _$AdminDashboardDataImpl instance) =>
    <String, dynamic>{
      'totalReports': instance.totalReports,
      'pendingReports': instance.pendingReports,
      'todayReports': instance.todayReports,
      'thisWeekReports': instance.thisWeekReports,
      'thisMonthReports': instance.thisMonthReports,
      'completionRate': instance.completionRate,
      'averageProcessingHours': instance.averageProcessingHours,
      'urgentReports': instance.urgentReports,
      'activeAdmins': instance.activeAdmins,
      'dailyTrend': instance.dailyTrend,
      'categoryDistribution': instance.categoryDistribution,
      'statusDistribution': instance.statusDistribution,
      'regionDistribution': instance.regionDistribution,
      'processingTimes': instance.processingTimes,
      'teamPerformance': instance.teamPerformance,
      'lastUpdated': instance.lastUpdated.toIso8601String(),
      'systemHealth': instance.systemHealth,
      'recentActivities': instance.recentActivities,
    };

_$ChartDataImpl _$$ChartDataImplFromJson(Map<String, dynamic> json) =>
    _$ChartDataImpl(
      label: json['label'] as String,
      value: (json['value'] as num).toDouble(),
      color: json['color'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$ChartDataImplToJson(_$ChartDataImpl instance) =>
    <String, dynamic>{
      'label': instance.label,
      'value': instance.value,
      'color': instance.color,
      'metadata': instance.metadata,
    };

_$ProcessingTimeDataImpl _$$ProcessingTimeDataImplFromJson(
        Map<String, dynamic> json) =>
    _$ProcessingTimeDataImpl(
      category: json['category'] as String,
      averageHours: (json['averageHours'] as num).toDouble(),
      targetHours: (json['targetHours'] as num).toDouble(),
      count: (json['count'] as num).toInt(),
      efficiency: (json['efficiency'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$$ProcessingTimeDataImplToJson(
        _$ProcessingTimeDataImpl instance) =>
    <String, dynamic>{
      'category': instance.category,
      'averageHours': instance.averageHours,
      'targetHours': instance.targetHours,
      'count': instance.count,
      'efficiency': instance.efficiency,
    };

_$AdminPerformanceDataImpl _$$AdminPerformanceDataImplFromJson(
        Map<String, dynamic> json) =>
    _$AdminPerformanceDataImpl(
      adminId: json['adminId'] as String,
      adminName: json['adminName'] as String,
      processedCount: (json['processedCount'] as num).toInt(),
      averageTime: (json['averageTime'] as num).toDouble(),
      satisfactionScore: (json['satisfactionScore'] as num).toDouble(),
      currentAssignments: (json['currentAssignments'] as num).toInt(),
      workloadPercentage:
          (json['workloadPercentage'] as num?)?.toDouble() ?? 100.0,
    );

Map<String, dynamic> _$$AdminPerformanceDataImplToJson(
        _$AdminPerformanceDataImpl instance) =>
    <String, dynamic>{
      'adminId': instance.adminId,
      'adminName': instance.adminName,
      'processedCount': instance.processedCount,
      'averageTime': instance.averageTime,
      'satisfactionScore': instance.satisfactionScore,
      'currentAssignments': instance.currentAssignments,
      'workloadPercentage': instance.workloadPercentage,
    };

_$SystemHealthDataImpl _$$SystemHealthDataImplFromJson(
        Map<String, dynamic> json) =>
    _$SystemHealthDataImpl(
      cpuUsage: (json['cpuUsage'] as num?)?.toDouble() ?? 100.0,
      memoryUsage: (json['memoryUsage'] as num?)?.toDouble() ?? 100.0,
      diskUsage: (json['diskUsage'] as num?)?.toDouble() ?? 100.0,
      activeConnections: (json['activeConnections'] as num?)?.toInt() ?? 0,
      responseTime: (json['responseTime'] as num?)?.toDouble() ?? 0.0,
      uptime: (json['uptime'] as num?)?.toDouble() ?? 99.9,
      status: $enumDecodeNullable(_$SystemStatusEnumMap, json['status']) ??
          SystemStatus.healthy,
      alerts:
          (json['alerts'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );

Map<String, dynamic> _$$SystemHealthDataImplToJson(
        _$SystemHealthDataImpl instance) =>
    <String, dynamic>{
      'cpuUsage': instance.cpuUsage,
      'memoryUsage': instance.memoryUsage,
      'diskUsage': instance.diskUsage,
      'activeConnections': instance.activeConnections,
      'responseTime': instance.responseTime,
      'uptime': instance.uptime,
      'status': _$SystemStatusEnumMap[instance.status]!,
      'alerts': instance.alerts,
    };

const _$SystemStatusEnumMap = {
  SystemStatus.healthy: 'healthy',
  SystemStatus.warning: 'warning',
  SystemStatus.critical: 'critical',
  SystemStatus.maintenance: 'maintenance',
};

_$RecentActivityImpl _$$RecentActivityImplFromJson(Map<String, dynamic> json) =>
    _$RecentActivityImpl(
      id: json['id'] as String,
      description: json['description'] as String,
      adminName: json['adminName'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      type: $enumDecode(_$ActivityTypeEnumMap, json['type']),
      reportId: json['reportId'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$RecentActivityImplToJson(
        _$RecentActivityImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'description': instance.description,
      'adminName': instance.adminName,
      'timestamp': instance.timestamp.toIso8601String(),
      'type': _$ActivityTypeEnumMap[instance.type]!,
      'reportId': instance.reportId,
      'metadata': instance.metadata,
    };

const _$ActivityTypeEnumMap = {
  ActivityType.reportAssigned: 'report_assigned',
  ActivityType.reportCompleted: 'report_completed',
  ActivityType.statusChanged: 'status_changed',
  ActivityType.commentAdded: 'comment_added',
  ActivityType.userCreated: 'user_created',
  ActivityType.settingsUpdated: 'settings_updated',
  ActivityType.login: 'login',
  ActivityType.logout: 'logout',
};
