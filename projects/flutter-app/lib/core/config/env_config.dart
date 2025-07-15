import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

enum Environment {
  development,
  staging,
  production
}

// 환경 변수 로딩 상태를 추적하는 클래스
class EnvLoadStatus {
  final bool isLoaded;
  final String? errorMessage;
  final DateTime? loadTime;
  
  const EnvLoadStatus({this.isLoaded = false, this.errorMessage, this.loadTime});
  
  EnvLoadStatus copyWith({
    bool? isLoaded,
    String? errorMessage,
    DateTime? loadTime,
  }) {
    return EnvLoadStatus(
      isLoaded: isLoaded ?? this.isLoaded,
      errorMessage: errorMessage ?? this.errorMessage,
      loadTime: loadTime ?? this.loadTime,
    );
  }
}

class EnvConfig {
  // 환경 변수 로드 상태
  static EnvLoadStatus _loadStatus = const EnvLoadStatus();
  static EnvLoadStatus get loadStatus => _loadStatus;
  
  // 환경 변수 서버 URL (flutter-env-service)
  static const String _envManagerUrl = 'http://10.0.2.2:8889';
  // 환경 변수 캐싱 시간 (분 단위)
  static const int _cacheMinutes = 5;
  final String appName;
  final Environment environment;
  final String mainApiBaseUrl;
  final String legacyApiBaseUrl;
  final String fileServerUrl;
  final String aiServerUrl;
  final String naverMapClientId;
  final bool enableAnalytics;
  final bool enableNetworkLogs;
  final bool enableCrashlytics;
  final Map<String, double> mapDefaultLocation;

  EnvConfig({
    required this.appName,
    required this.environment,
    required this.mainApiBaseUrl,
    required this.legacyApiBaseUrl,
    required this.fileServerUrl,
    required this.aiServerUrl,
    required this.naverMapClientId,
    required this.enableAnalytics,
    required this.enableNetworkLogs,
    required this.enableCrashlytics,
    required this.mapDefaultLocation,
  });
  
  // Development 환경 설정 (로컬 에뮬레이터 또는 디바이스 테스트용)
  factory EnvConfig.development() => EnvConfig(
    appName: 'JB Platform Dev',
    environment: Environment.development,
    mainApiBaseUrl: 'http://10.0.2.2:8080/api/v1',
    legacyApiBaseUrl: 'http://10.0.2.2:8080',
    fileServerUrl: 'http://10.0.2.2:12020',
    aiServerUrl: 'http://10.0.2.2:8086/api/v1',
    naverMapClientId: 'YOUR_NAVER_MAP_CLIENT_ID',
    enableAnalytics: false,
    enableNetworkLogs: true,
    enableCrashlytics: false,
    mapDefaultLocation: {
      'latitude': 35.8242238,
      'longitude': 127.1479532,
      'zoom': 15.0,
    },
  );

  // Staging 환경 설정 (테스트 서버 환경)
  factory EnvConfig.staging() => EnvConfig(
    appName: 'JB Platform Staging',
    environment: Environment.staging,
    mainApiBaseUrl: 'https://map.nodove.com:8080/api/v1',
    legacyApiBaseUrl: 'https://map.nodove.com:8080',
    fileServerUrl: 'https://map.nodove.com:12020',
    aiServerUrl: 'https://map.nodove.com:8086/api/v1',
    naverMapClientId: 'YOUR_NAVER_MAP_CLIENT_ID',
    enableAnalytics: true,
    enableNetworkLogs: true,
    enableCrashlytics: true,
    mapDefaultLocation: {
      'latitude': 35.8242238,
      'longitude': 127.1479532,
      'zoom': 15.0,
    },
  );

  // Production 환경 설정
  factory EnvConfig.production() => EnvConfig(
    appName: 'JB Platform',
    environment: Environment.production,
    mainApiBaseUrl: 'https://map.nodove.com:8080/api/v1',
    legacyApiBaseUrl: 'https://map.nodove.com:8080',
    fileServerUrl: 'https://map.nodove.com:12020',
    aiServerUrl: 'https://map.nodove.com:8086/api/v1',
    naverMapClientId: 'YOUR_NAVER_MAP_CLIENT_ID',
    enableAnalytics: true,
    enableNetworkLogs: false,
    enableCrashlytics: true,
    mapDefaultLocation: {
      'latitude': 35.8242238,
      'longitude': 127.1479532,
      'zoom': 15.0,
    },
  );

  static late EnvConfig _instance;
  
  // 초기화 메서드
  static Future<void> initialize(Environment env) async {
    // 기본값으로 초기화
    switch (env) {
      case Environment.development:
        _instance = EnvConfig.development();
        break;
      case Environment.staging:
        _instance = EnvConfig.staging();
        break;
      case Environment.production:
        _instance = EnvConfig.production();
        break;
    }
    
    // 기본값 설정 후 로그 출력
    if (kDebugMode) {
      print('🌍 Environment: ${_instance.environment.name} (로컬 기본값으로 초기화)');
      print('🔗 API URL: ${_instance.mainApiBaseUrl}');
      print('📁 File Server URL: ${_instance.fileServerUrl}');
      print('🤖 AI Server URL: ${_instance.aiServerUrl}');
    }
    
    // env-manager에서 환경 변수 불러오기 시도
    try {
      await _loadFromEnvManager(env);
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ env-manager에서 환경 변수 로드 실패: $e');
        print('⚠️ 기본 설정값으로 계속 진행합니다.');
      }
      _loadStatus = EnvLoadStatus(
        isLoaded: false, 
        errorMessage: e.toString(),
        loadTime: DateTime.now(),
      );
    }
  }
  
  // env-manager에서 환경 변수 불러오기
  static Future<void> _loadFromEnvManager(Environment env) async {
    // 캐시 유효 시간 확인
    if (_loadStatus.isLoaded && _loadStatus.loadTime != null) {
      final now = DateTime.now();
      final diff = now.difference(_loadStatus.loadTime!);
      
      // 캐시가 유효한 경우 스킵
      if (diff.inMinutes < _cacheMinutes) {
        if (kDebugMode) {
          print('✅ 환경 변수 캐시가 유효합니다. (마지막 로드: ${diff.inMinutes}분 전)');
        }
        return;
      }
    }
    
    if (kDebugMode) {
      print('🔄 env-manager에서 환경 변수 불러오는 중...');
    }
    
    try {
      final url = '$_envManagerUrl/api/env/${env.name}';
      final response = await http.get(Uri.parse(url))
          .timeout(const Duration(seconds: 5)); // 5초 타임아웃
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        
        if (data['status'] == 'success' && data['data'] != null) {
          final envData = data['data'] as Map<String, dynamic>;
          
          // 환경 변수로 인스턴스 업데이트
          _updateInstance(envData, env);
          
          _loadStatus = EnvLoadStatus(
            isLoaded: true,
            loadTime: DateTime.now(),
          );
          
          if (kDebugMode) {
            print('✅ env-manager에서 환경 변수를 성공적으로 불러왔습니다.');
            print('🌍 Environment: ${_instance.environment.name} (env-manager에서 로드)');
            print('🔗 API URL: ${_instance.mainApiBaseUrl}');
            print('📁 File Server URL: ${_instance.fileServerUrl}');
          }
        } else {
          throw '서버에서 유효한 응답을 받지 못했습니다: ${data['message'] ?? "알 수 없는 오류"}';
        }
      } else {
        throw '서버 응답 오류 (${response.statusCode}): ${response.body}';
      }
    } catch (e) {
      _loadStatus = EnvLoadStatus(
        isLoaded: false,
        errorMessage: e.toString(),
        loadTime: DateTime.now(),
      );
      rethrow;
    }
  }
  
  // 환경 변수로 인스턴스 업데이트
  static void _updateInstance(Map<String, dynamic> envData, Environment env) {
    // 맵 기본 위치 처리
    Map<String, double> mapLocation = _instance.mapDefaultLocation;
    if (envData['mapDefaultLocation'] != null) {
      final mapData = envData['mapDefaultLocation'] as Map<String, dynamic>;
      mapLocation = {
        'latitude': (mapData['latitude'] as num?)?.toDouble() ?? mapLocation['latitude']!,
        'longitude': (mapData['longitude'] as num?)?.toDouble() ?? mapLocation['longitude']!,
        'zoom': (mapData['zoom'] as num?)?.toDouble() ?? mapLocation['zoom']!,
      };
    }
    
    // 기존 인스턴스 유지하면서 값만 업데이트
    _instance = EnvConfig(
      appName: envData['appName'] ?? _instance.appName,
      environment: env,
      mainApiBaseUrl: envData['mainApiBaseUrl'] ?? _instance.mainApiBaseUrl,
      legacyApiBaseUrl: envData['legacyApiBaseUrl'] ?? _instance.legacyApiBaseUrl,
      fileServerUrl: envData['fileServerUrl'] ?? _instance.fileServerUrl,
      aiServerUrl: envData['aiServerUrl'] ?? _instance.aiServerUrl,
      naverMapClientId: envData['naverMapClientId'] ?? _instance.naverMapClientId,
      enableAnalytics: envData['enableAnalytics'] ?? _instance.enableAnalytics,
      enableNetworkLogs: envData['enableNetworkLogs'] ?? _instance.enableNetworkLogs,
      enableCrashlytics: envData['enableCrashlytics'] ?? _instance.enableCrashlytics,
      mapDefaultLocation: mapLocation,
    );
  }
  
  // 환경 변수 새로고침
  static Future<bool> refresh() async {
    try {
      await _loadFromEnvManager(_instance.environment);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ 환경 변수 새로고침 실패: $e');
      }
      return false;
    }
  }

  static EnvConfig get instance => _instance;

  bool get isProduction => environment == Environment.production;
  bool get isDevelopment => environment == Environment.development;
  bool get isStaging => environment == Environment.staging;
}
