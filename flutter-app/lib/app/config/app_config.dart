import 'dart:io';
import 'package:flutter/foundation.dart';

class AppConfig {
  static const String appName = 'Flutter Report App';
  static const String version = '1.0.0';

  // 개발 모드 설정
  static const bool isDevelopmentMode = kDebugMode;

  // API 설정
  static String get apiBaseUrl {
    if (kIsWeb) {
      return 'http://localhost:8080';
    }
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8080';
    }
    // For iOS, desktop, etc.
    return 'http://localhost:8080';
  }

  static const Duration apiTimeout = Duration(seconds: 30);

  // 테스트 계정 설정 (개발 모드에서만 사용)
  static const Map<String, String> testAccounts = {
    'admin@test.com': 'admin123',
    'user@test.com': 'user123',
    'tester@test.com': 'test123',
  };

  // OAuth2 설정
  static const String googleClientId = 'your-google-client-id';
  static const String kakaoAppKey = 'your-kakao-app-key';
  static const String naverClientId = '6gmofoay96';
  static const String naverClientSecret = '6WQ3He7rBpcsa02WtRY6A9ycU5MsClOvKkwZ601B';

  // 파일 업로드 설정
  static const int maxImageCount = 10;
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB

  // 오프라인 설정
  static const Duration autoSaveInterval = Duration(seconds: 30);
  static const int maxOfflineReports = 100;

  // 위치 설정
  static const double locationAccuracy = 10.0; // meters
  static const Duration locationTimeout = Duration(seconds: 10);
}
