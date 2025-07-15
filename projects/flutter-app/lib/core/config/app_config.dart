import 'package:flutter/foundation.dart';
import 'env_config.dart';

class AppConfig {
  static const String appName = 'JB Platform';
  static const String appVersion = '1.0.0';
  
  // API Configuration - 환경별 설정 사용
  static String get apiBaseUrl => EnvConfig.instance.mainApiBaseUrl;
  
  static String get legacyApiBaseUrl => EnvConfig.instance.legacyApiBaseUrl;
  
  // File Server Configuration - 환경별 설정 사용
  static String get fileServerUrl => EnvConfig.instance.fileServerUrl;
  
  // AI Analysis Server Configuration - 환경별 설정 사용
  static String get aiServerUrl => EnvConfig.instance.aiServerUrl;
  
  // Feature Flags
  static const bool useNewApiVersion = bool.fromEnvironment(
    'USE_NEW_API_VERSION',
    defaultValue: true,
  );
  
  static const bool enableAnalytics = bool.fromEnvironment(
    'ENABLE_ANALYTICS',
    defaultValue: true,
  );
  
  static const bool enableCrashlytics = bool.fromEnvironment(
    'ENABLE_CRASHLYTICS',
    defaultValue: true,
  );
  
  // Security
  static const Duration tokenRefreshThreshold = Duration(minutes: 5);
  static const Duration sessionTimeout = Duration(hours: 24);
  
  // Network
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const int maxRetryAttempts = 3;
  
  // Cache
  static const Duration cacheValidDuration = Duration(hours: 1);
  static const int maxCacheSize = 50 * 1024 * 1024; // 50MB
  
  // Logging - 환경별 설정 사용
  static bool get enableLogging => !EnvConfig.instance.isProduction;
  static bool get enableNetworkLogging => EnvConfig.instance.enableNetworkLogs;
}
