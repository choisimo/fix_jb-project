import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/system_monitoring_data.dart';

final systemMonitoringProvider = StateNotifierProvider<SystemMonitoringNotifier, AsyncValue<SystemMonitoringData>>((ref) {
  return SystemMonitoringNotifier();
});

class SystemMonitoringNotifier extends StateNotifier<AsyncValue<SystemMonitoringData>> {
  SystemMonitoringNotifier() : super(const AsyncValue.loading()) {
    loadMonitoringData();
  }
  
  Future<void> loadMonitoringData() async {
    try {
      state = const AsyncValue.loading();
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      state = AsyncValue.data(SystemMonitoringData(
        timestamp: DateTime.now(),
        services: _generateServiceData(),
        endpoints: _generateEndpointData(),
        activityData: _generateActivityData(),
        performanceData: _generatePerformanceData(),
        diskIOData: _generateDiskIOData(),
        networkData: _generateNetworkData(),
        responseTimeData: _generateResponseTimeData(),
        errorRateData: _generateErrorRateData(),
        requestVolumeData: _generateRequestVolumeData(),
        alerts: [],
      ));
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
  
  void acknowledgeAlert(String alertId) {
    state.whenData((data) {
      final updatedAlerts = data.alerts
          .where((alert) => alert.id != alertId)
          .toList();
      state = AsyncValue.data(data.copyWith(alerts: updatedAlerts));
    });
  }
  
  void resolveAlert(String alertId) {
    acknowledgeAlert(alertId);
  }
  
  // 누락된 메서드들 추가
  void startMonitoring() {
    loadMonitoringData();
  }
  
  void stopMonitoring() {
    // 모니터링 중지 로직
  }
  
  void updateTimeRange(Duration range) {
    // 시간 범위 업데이트 로직
    loadMonitoringData();
  }
  
  void dismissAlert(String alertId) {
    acknowledgeAlert(alertId);
  }
  
  List<ServiceHealth> _generateServiceData() {
    return [
      ServiceHealth(
        name: 'Main API',
        status: 'healthy',
        responseTime: 120,
        uptime: 99.9,
      ),
      ServiceHealth(
        name: 'AI Analysis',
        status: 'healthy',
        responseTime: 450,
        uptime: 99.5,
      ),
      ServiceHealth(
        name: 'Database',
        status: 'healthy',
        responseTime: 15,
        uptime: 100.0,
      ),
    ];
  }
  
  List<EndpointHealth> _generateEndpointData() {
    return [
      EndpointHealth(
        path: '/api/v1/reports',
        method: 'GET',
        status: 'healthy',
        avgResponseTime: 150,
        successRate: 99.8,
        requestCount: 1250,
        errorCount: 3,
        p95ResponseTime: 350,
        p99ResponseTime: 500,
      ),
      EndpointHealth(
        path: '/api/v1/ai/analyze',
        method: 'POST',
        status: 'degraded',
        avgResponseTime: 850,
        successRate: 95.2,
        requestCount: 450,
        errorCount: 22,
        p95ResponseTime: 1500,
        p99ResponseTime: 2000,
      ),
    ];
  }
  
  List<ActivityData> _generateActivityData() {
    final now = DateTime.now();
    return List.generate(24, (index) {
      return ActivityData(
        timestamp: now.subtract(Duration(hours: 23 - index)),
        value: 50 + (index * 10 % 100).toDouble(),
      );
    });
  }
  
  List<PerformanceData> _generatePerformanceData() {
    final now = DateTime.now();
    return List.generate(60, (index) {
      return PerformanceData(
        timestamp: now.subtract(Duration(minutes: 59 - index)),
        cpu: 20 + (index * 2 % 60).toDouble(),
        memory: 40 + (index % 40).toDouble(),
      );
    });
  }
  
  List<DiskIOData> _generateDiskIOData() {
    final now = DateTime.now();
    return List.generate(30, (index) {
      return DiskIOData(
        timestamp: now.subtract(Duration(minutes: 29 - index)),
        readMBps: 10 + (index % 20).toDouble(),
        writeMBps: 5 + (index % 15).toDouble(),
      );
    });
  }
  
  List<NetworkData> _generateNetworkData() {
    final now = DateTime.now();
    return List.generate(30, (index) {
      return NetworkData(
        timestamp: now.subtract(Duration(minutes: 29 - index)),
        inMbps: 50 + (index * 5 % 100).toDouble(),
        outMbps: 30 + (index * 3 % 70).toDouble(),
      );
    });
  }
  
  List<ResponseTimeData> _generateResponseTimeData() {
    final now = DateTime.now();
    return List.generate(20, (index) {
      return ResponseTimeData(
        timestamp: now.subtract(Duration(minutes: 19 - index)),
        avgTime: 100 + (index * 10 % 200).toDouble(),
        p95Time: 200 + (index * 15 % 300).toDouble(),
        p99Time: 300 + (index * 20 % 400).toDouble(),
      );
    });
  }
  
  List<ErrorRateData> _generateErrorRateData() {
    final now = DateTime.now();
    return List.generate(20, (index) {
      return ErrorRateData(
        timestamp: now.subtract(Duration(minutes: 19 - index)),
        rate: (index % 5).toDouble(),
        count: index % 5,
      );
    });
  }
  
  List<RequestVolumeData> _generateRequestVolumeData() {
    final now = DateTime.now();
    return List.generate(20, (index) {
      return RequestVolumeData(
        timestamp: now.subtract(Duration(minutes: 19 - index)),
        count: 100 + (index * 20 % 300),
      );
    });
  }
}
