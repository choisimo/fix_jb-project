import '../config/app_config.dart';

class ApiConstants {
  // Get configuration from AppConfig
  static AppConfig get _config => AppConfig.instance;

  // 베이스 URL (환경변수에서 동적으로 가져옴)
  static String get baseUrl => _config.baseUrl;
  
  // API 버전
  static String get apiVersion => _config.apiVersion;
  
  // 전체 API 베이스 URL
  static String get apiBaseUrl => _config.apiBaseUrl;

  // === 인증 관련 엔드포인트 ===
  static const String authBase = '/auth';
  static const String loginEndpoint = '$authBase/login';
  static const String registerEndpoint = '$authBase/register';
  static const String refreshTokenEndpoint = '$authBase/refresh';
  static const String logoutEndpoint = '$authBase/logout';
  static const String googleLoginEndpoint = '$authBase/google';
  static const String kakaoLoginEndpoint = '$authBase/kakao';
  static const String verifyEmailEndpoint = '$authBase/verify-email';
  static const String resetPasswordEndpoint = '$authBase/reset-password';

  // === 사용자 관련 엔드포인트 ===
  static const String userBase = '/users';
  static const String userProfileEndpoint = '$userBase/profile';
  static const String updateProfileEndpoint = '$userBase/profile';
  static const String changePasswordEndpoint = '$userBase/change-password';
  static const String deleteAccountEndpoint = '$userBase/delete';

  // === 리포트 관련 엔드포인트 ===
  static const String reportBase = '/reports';
  static const String createReportEndpoint = reportBase;
  static const String getReportsEndpoint = reportBase;
  static const String getReportByIdEndpoint = '$reportBase/{id}';
  static const String updateReportEndpoint = '$reportBase/{id}';
  static const String deleteReportEndpoint = '$reportBase/{id}';
  static const String uploadReportImageEndpoint = '$reportBase/{id}/images';
  static const String getReportStatusEndpoint = '$reportBase/{id}/status';

  // === 알림 관련 엔드포인트 ===
  static const String notificationBase = '/notifications';
  static const String getNotificationsEndpoint = notificationBase;
  static const String markAsReadEndpoint = '$notificationBase/{id}/read';
  static const String markAllAsReadEndpoint = '$notificationBase/read-all';
  static const String getUnreadCountEndpoint = '$notificationBase/unread-count';
  static const String updateNotificationSettingsEndpoint = '$notificationBase/settings';

  // === 관리자 관련 엔드포인트 ===
  static const String adminBase = '/admin';
  static const String adminDashboardEndpoint = '$adminBase/dashboard';
  static const String adminUsersEndpoint = '$adminBase/users';
  static const String adminReportsEndpoint = '$adminBase/reports';
  static const String adminStatsEndpoint = '$adminBase/statistics';

  // === 파일 업로드 관련 ===
  static const String fileBase = '/files';
  static const String uploadFileEndpoint = '$fileBase/upload';
  static const String getFileEndpoint = '$fileBase/{id}';
  static const String deleteFileEndpoint = '$fileBase/{id}';

  // === WebSocket 엔드포인트 ===
  static String get wsBaseUrl => _config.wsBaseUrl;
  static String get wsUrl => _config.wsUrl;
  static const String wsNotifications = '/ws/notifications';
  static const String wsReportUpdates = '/ws/reports';
  
  // === HTTP 헤더 상수 ===
  static const String authorizationHeader = AppConfig.authorizationHeader;
  static const String bearerPrefix = AppConfig.bearerPrefix;
  static const String contentTypeHeader = AppConfig.contentTypeHeader;
  static const String applicationJson = AppConfig.applicationJson;
  static const String multipartFormData = AppConfig.multipartFormData;

  // === 타임아웃 설정 (환경변수에서 가져옴) ===
  static Duration get connectionTimeout => Duration(seconds: _config.connectionTimeout);
  static Duration get receiveTimeout => Duration(seconds: _config.receiveTimeout);
  static Duration get sendTimeout => Duration(seconds: _config.sendTimeout);

  // === 재시도 설정 (환경변수에서 가져옴) ===
  static int get maxRetryAttempts => _config.maxRetryAttempts;
  static Duration get retryDelay => Duration(seconds: _config.retryDelay);

  // === 페이지네이션 (환경변수에서 가져옴) ===
  static int get defaultPageSize => _config.defaultPageSize;
  static int get maxPageSize => _config.maxPageSize;

  // === 파일 업로드 제한 (환경변수에서 가져옴) ===
  static int get maxFileSize => _config.maxFileSize;

  // === 파일 포맷 제한 ===
  static const List<String> allowedImageFormats = ['jpg', 'jpeg', 'png', 'webp'];
  static const List<String> allowedVideoFormats = ['mp4', 'mov', 'avi'];

  // === 캐시 설정 ===
  static const Duration cacheTimeout = Duration(minutes: 5);
  static const String cacheKeyPrefix = 'jb_report_';

  // === 환경 확인 헬퍼 ===
  static bool get _isDevelopment => _config.environment == 'development';
  static bool get _isStaging => _config.environment == 'staging';

  // === 환경별 설정 ===
  static Map<String, dynamic> get environmentConfig {
    return {
      'isDevelopment': _isDevelopment,
      'isStaging': _isStaging,
      'isProduction': !_isDevelopment && !_isStaging,
      'baseUrl': baseUrl,
      'apiBaseUrl': apiBaseUrl,
      'wsBaseUrl': wsBaseUrl,
      'logLevel': _isDevelopment ? 'debug' : 'error',
      'enableCrashlytics': !_isDevelopment,
      'enableAnalytics': !_isDevelopment,
    };
  }

  // === 헬퍼 메서드 ===
  
  /// ID가 포함된 엔드포인트 URL 생성
  static String buildUrlWithId(String endpoint, String id) {
    return endpoint.replaceAll('{id}', id);
  }

  /// 쿼리 파라미터가 포함된 URL 생성
  static String buildUrlWithQuery(String endpoint, Map<String, dynamic> queryParams) {
    if (queryParams.isEmpty) return endpoint;
    
    final query = queryParams.entries
        .where((entry) => entry.value != null)
        .map((entry) => '${entry.key}=${Uri.encodeComponent(entry.value.toString())}')
        .join('&');
    
    return query.isEmpty ? endpoint : '$endpoint?$query';
  }

  /// Authorization 헤더 생성
  static Map<String, String> buildAuthHeaders(String token) {
    return {
      authorizationHeader: '$bearerPrefix$token',
      contentTypeHeader: applicationJson,
    };
  }

  /// 멀티파트 업로드 헤더 생성
  static Map<String, String> buildMultipartHeaders(String token) {
    return {
      authorizationHeader: '$bearerPrefix$token',
      // Content-Type은 dio에서 자동으로 설정됨
    };
  }
}