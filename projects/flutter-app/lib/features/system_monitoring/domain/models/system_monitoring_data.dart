import 'package:freezed_annotation/freezed_annotation.dart';

part 'system_monitoring_data.freezed.dart';
part 'system_monitoring_data.g.dart';

@freezed
class SystemMonitoringData with _$SystemMonitoringData {
  const factory SystemMonitoringData({
    required DateTime timestamp,
    required List<ServiceHealth> services,
    required List<EndpointHealth> endpoints,
    required List<ActivityData> activityData,
    required List<PerformanceData> performanceData,
    required List<DiskIOData> diskIOData,
    required List<NetworkData> networkData,
    required List<ResponseTimeData> responseTimeData,
    required List<ErrorRateData> errorRateData,
    required List<RequestVolumeData> requestVolumeData,
    required List<SystemAlert> alerts,
  }) = _SystemMonitoringData;
  
  factory SystemMonitoringData.fromJson(Map<String, dynamic> json) =>
      _$SystemMonitoringDataFromJson(json);
}

@freezed
class ServiceHealth with _$ServiceHealth {
  const factory ServiceHealth({
    required String name,
    required String status,
    required double responseTime,
    required double uptime,
  }) = _ServiceHealth;
  
  factory ServiceHealth.fromJson(Map<String, dynamic> json) =>
      _$ServiceHealthFromJson(json);
}

@freezed
class EndpointHealth with _$EndpointHealth {
  const factory EndpointHealth({
    required String path,
    required String method,
    required String status,
    required double avgResponseTime,
    required double successRate,
    required int requestCount,
    required int errorCount,
    required double p95ResponseTime,
    required double p99ResponseTime,
  }) = _EndpointHealth;
  
  factory EndpointHealth.fromJson(Map<String, dynamic> json) =>
      _$EndpointHealthFromJson(json);
}

@freezed
class ActivityData with _$ActivityData {
  const factory ActivityData({
    required DateTime timestamp,
    required double value,
  }) = _ActivityData;
  
  factory ActivityData.fromJson(Map<String, dynamic> json) =>
      _$ActivityDataFromJson(json);
}

@freezed
class PerformanceData with _$PerformanceData {
  const factory PerformanceData({
    required DateTime timestamp,
    required double cpu,
    required double memory,
  }) = _PerformanceData;
  
  factory PerformanceData.fromJson(Map<String, dynamic> json) =>
      _$PerformanceDataFromJson(json);
}

@freezed
class DiskIOData with _$DiskIOData {
  const factory DiskIOData({
    required DateTime timestamp,
    required double readMBps,
    required double writeMBps,
  }) = _DiskIOData;
  
  factory DiskIOData.fromJson(Map<String, dynamic> json) =>
      _$DiskIODataFromJson(json);
}

@freezed
class NetworkData with _$NetworkData {
  const factory NetworkData({
    required DateTime timestamp,
    required double inMbps,
    required double outMbps,
  }) = _NetworkData;
  
  factory NetworkData.fromJson(Map<String, dynamic> json) =>
      _$NetworkDataFromJson(json);
}

@freezed
class ResponseTimeData with _$ResponseTimeData {
  const factory ResponseTimeData({
    required DateTime timestamp,
    required double avgTime,
    required double p95Time,
    required double p99Time,
  }) = _ResponseTimeData;
  
  factory ResponseTimeData.fromJson(Map<String, dynamic> json) =>
      _$ResponseTimeDataFromJson(json);
}

@freezed
class ErrorRateData with _$ErrorRateData {
  const factory ErrorRateData({
    required DateTime timestamp,
    required double rate,
    required int count,
  }) = _ErrorRateData;
  
  factory ErrorRateData.fromJson(Map<String, dynamic> json) =>
      _$ErrorRateDataFromJson(json);
}

@freezed
class RequestVolumeData with _$RequestVolumeData {
  const factory RequestVolumeData({
    required DateTime timestamp,
    required int count,
  }) = _RequestVolumeData;
  
  factory RequestVolumeData.fromJson(Map<String, dynamic> json) =>
      _$RequestVolumeDataFromJson(json);
}

@freezed
class SystemAlert with _$SystemAlert {
  const factory SystemAlert({
    required String id,
    required String type,
    required String severity,
    required String message,
    required DateTime timestamp,
    Map<String, dynamic>? metadata,
  }) = _SystemAlert;
  
  factory SystemAlert.fromJson(Map<String, dynamic> json) =>
      _$SystemAlertFromJson(json);
}
