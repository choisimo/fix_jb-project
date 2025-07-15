import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class EnvironmentConfig {
  static const String _envManagerUrl = 'http://localhost:8888';
  static Map<String, dynamic>? _config;
  
  // 환경변수 로드
  static Future<void> initialize({String environment = 'development'}) async {
    try {
      final dio = Dio();
      final response = await dio.get('$_envManagerUrl/api/env/$environment');
      
      if (response.statusCode == 200 && response.data['status'] == 'success') {
        _config = response.data['data'];
        debugPrint('환경설정 로드 완료: $environment');
      } else {
        throw Exception('환경설정 로드 실패: ${response.data['message']}');
      }
    } catch (e) {
      debugPrint('환경설정 로드 오류: $e');
      _setFallbackConfig(environment);
    }
  }
  
  // 폴백 설정
  static void _setFallbackConfig(String environment) {
    switch (environment) {
      case 'development':
        _config = {
          "appName": "JB Platform Dev",
          "mainApiBaseUrl": "http://10.0.2.2:8080/api/v1",
          "legacyApiBaseUrl": "http://10.0.2.2:8080",
          "fileServerUrl": "http://10.0.2.2:12020",
          "aiServerUrl": "http://10.0.2.2:8086/api/v1",
          "naverMapClientId": "YOUR_NAVER_MAP_CLIENT_ID",
          "enableAnalytics": false,
          "enableNetworkLogs": true,
          "enableCrashlytics": false,
          "mapDefaultLocation": {
            "latitude": 35.8242238,
            "longitude": 127.1479532,
            "zoom": 15
          }
        };
        break;
      default:
        _config = {};
    }
  }
  
  // 설정값 조회
  static T getValue<T>(String key, T defaultValue) {
    if (_config == null) {
      debugPrint('환경설정이 로드되지 않았습니다. 기본값 사용: $key');
      return defaultValue;
    }
    
    final keys = key.split('.');
    dynamic value = _config;
    
    for (final k in keys) {
      if (value is Map<String, dynamic> && value.containsKey(k)) {
        value = value[k];
      } else {
        return defaultValue;
      }
    }
    
    return value is T ? value : defaultValue;
  }
  
  // 자주 사용하는 설정값들
  static String get appName => getValue('appName', 'JB Platform');
  static String get mainApiBaseUrl => getValue('mainApiBaseUrl', 'http://localhost:8080/api/v1');
  static String get naverMapClientId => getValue('naverMapClientId', '');
  static bool get enableAnalytics => getValue('enableAnalytics', false);
  static bool get enableNetworkLogs => getValue('enableNetworkLogs', true);
  
  // 지도 기본 위치
  static double get mapDefaultLatitude => getValue('mapDefaultLocation.latitude', 35.8242238);
  static double get mapDefaultLongitude => getValue('mapDefaultLocation.longitude', 127.1479532);
  static double get mapDefaultZoom => getValue('mapDefaultLocation.zoom', 15.0);
}