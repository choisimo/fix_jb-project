import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  // Private constructor
  AppConfig._();
  
  // Singleton instance
  static final AppConfig _instance = AppConfig._();
  static AppConfig get instance => _instance;
  
  // Initialize method
  static Future<void> initialize() async {
    await dotenv.load(fileName: ".env");
  }
  
  // Environment
  String get environment => dotenv.env['ENVIRONMENT'] ?? 'development';
  bool get isDevelopment => environment == 'development';
  bool get isStaging => environment == 'staging';
  bool get isProduction => environment == 'production';
  
  // API Configuration
  String get devBaseUrl => dotenv.env['DEV_BASE_URL'] ?? 'http://localhost:8080';
  String get stagingBaseUrl => dotenv.env['STAGING_BASE_URL'] ?? 'https://staging-api.jbreport.com';
  String get prodBaseUrl => dotenv.env['PROD_BASE_URL'] ?? 'https://api.jbreport.com';
  String get apiVersion => dotenv.env['API_VERSION'] ?? '/api/v1';
  
  // Dynamic base URL based on environment
  String get baseUrl {
    switch (environment) {
      case 'staging':
        return stagingBaseUrl;
      case 'production':
        return prodBaseUrl;
      default:
        return devBaseUrl;
    }
  }
  
  String get apiBaseUrl => '$baseUrl$apiVersion';
  
  // WebSocket Configuration
  String get wsProtocol => dotenv.env['WS_PROTOCOL'] ?? 'ws';
  String get wsBaseUrl => baseUrl.replaceFirst('http', wsProtocol);
  String get wsUrl => '$wsBaseUrl$apiVersion';
  
  // App Configuration
  String get appName => dotenv.env['APP_NAME'] ?? 'JB Report';
  String get appVersion => dotenv.env['APP_VERSION'] ?? '1.0.0';
  
  // Feature Flags
  bool get enableDebugMode => _getBool('ENABLE_DEBUG_MODE', true);
  bool get enableMockData => _getBool('ENABLE_MOCK_DATA', false);
  bool get enableLogging => _getBool('ENABLE_LOGGING', true);
  
  // Network Configuration
  int get connectionTimeout => _getInt('CONNECTION_TIMEOUT', 30);
  int get receiveTimeout => _getInt('RECEIVE_TIMEOUT', 30);
  int get sendTimeout => _getInt('SEND_TIMEOUT', 30);
  int get maxRetryAttempts => _getInt('MAX_RETRY_ATTEMPTS', 3);
  int get retryDelay => _getInt('RETRY_DELAY', 1);
  
  // File Upload Configuration
  int get maxFileSize => _getInt('MAX_FILE_SIZE', 10 * 1024 * 1024);
  int get defaultPageSize => _getInt('DEFAULT_PAGE_SIZE', 20);
  int get maxPageSize => _getInt('MAX_PAGE_SIZE', 100);
  
  // Social Login Configuration
  String get googleClientId => dotenv.env['GOOGLE_CLIENT_ID'] ?? '';
  String get kakaoClientId => dotenv.env['KAKAO_CLIENT_ID'] ?? '';
  
  // Push Notification Configuration
  bool get firebaseMessagingEnabled => _getBool('FIREBASE_MESSAGING_ENABLED', true);
  
  // Security Configuration
  bool get enableBiometricAuth => _getBool('ENABLE_BIOMETRIC_AUTH', true);
  bool get enableRootDetection => _getBool('ENABLE_ROOT_DETECTION', true);
  bool get enableDebugDetection => _getBool('ENABLE_DEBUG_DETECTION', true);
  
  // HTTP Headers
  static const String authorizationHeader = 'Authorization';
  static const String bearerPrefix = 'Bearer ';
  static const String contentTypeHeader = 'Content-Type';
  static const String applicationJson = 'application/json';
  static const String multipartFormData = 'multipart/form-data';
  
  // Helper methods
  bool _getBool(String key, bool defaultValue) {
    final value = dotenv.env[key];
    if (value == null) return defaultValue;
    return value.toLowerCase() == 'true';
  }
  
  int _getInt(String key, int defaultValue) {
    final value = dotenv.env[key];
    if (value == null) return defaultValue;
    return int.tryParse(value) ?? defaultValue;
  }
  
  double _getDouble(String key, double defaultValue) {
    final value = dotenv.env[key];
    if (value == null) return defaultValue;
    return double.tryParse(value) ?? defaultValue;
  }
  
  // Environment configuration getter
  Map<String, dynamic> get environmentConfig {
    return {
      'environment': environment,
      'baseUrl': baseUrl,
      'apiBaseUrl': apiBaseUrl,
      'wsUrl': wsUrl,
      'enableDebugMode': enableDebugMode,
      'enableMockData': enableMockData,
      'enableLogging': enableLogging,
    };
  }
}