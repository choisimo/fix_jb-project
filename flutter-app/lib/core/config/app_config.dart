import 'package:flutter/foundation.dart';

class AppConfig {
  static const String appName = 'JB Platform';
  static const String appVersion = '1.0.0';
  
  // API Configuration
  static String get apiBaseUrl {
    if (kDebugMode) {
      return 'http://localhost:8080/api/v1';
    }
    return const String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'https://api.jbplatform.com/api/v1',
    );
  }
  
  static String get legacyApiBaseUrl {
    if (kDebugMode) {
      return 'http://localhost:8080';
    }
    return const String.fromEnvironment(
      'LEGACY_API_BASE_URL',
      defaultValue: 'https://api.jbplatform.com',
    );
  }
  
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
  
  // Logging
  static const bool enableLogging = !kReleaseMode;
  static const bool enableNetworkLogging = !kReleaseMode;
}
