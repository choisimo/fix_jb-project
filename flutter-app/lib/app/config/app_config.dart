class AppConfig {
  static const String appName = 'Flutter Report App';
  static const String version = '1.0.0';
  
  // API 설정
  static const String apiBaseUrl = 'http://localhost:8080/api';
  static const Duration apiTimeout = Duration(seconds: 30);
  
  // OAuth2 설정
  static const String googleClientId = 'your-google-client-id';
  static const String kakaoAppKey = 'your-kakao-app-key';
  static const String naverClientId = 'your-naver-client-id';
  
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
