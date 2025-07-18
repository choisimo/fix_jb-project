class ApiConstants {
  // 개발/스테이징/프로덕션 환경별 베이스 URL
  static const String _devBaseUrl = 'http://10.0.2.2:8080'; // Main API Server (에뮬레이터용)
  static const String _devAiBaseUrl = 'http://10.0.2.2:8083'; // AI Analysis Server
  static const String _stagingBaseUrl = 'https://staging-api.jbreport.com';
  static const String _stagingAiBaseUrl = 'https://staging-ai.jbreport.com';
  static const String _prodBaseUrl = 'https://api.jbreport.com';
  static const String _prodAiBaseUrl = 'https://ai.jbreport.com';

  // 현재 환경 설정 (개발 모드에서는 개발 서버 사용)
  static const bool _isDevelopment = true; // 프로덕션 배포시 false로 변경
  static const bool _isStaging = false;

  // 베이스 URL 선택
  static String get baseUrl {
    if (_isDevelopment) return _devBaseUrl;
    if (_isStaging) return _stagingBaseUrl;
    return _prodBaseUrl;
  }

  // AI Analysis Server 베이스 URL 선택
  static String get aiBaseUrl {
    if (_isDevelopment) return _devAiBaseUrl;
    if (_isStaging) return _stagingAiBaseUrl;
    return _prodAiBaseUrl;
  }

  // API 버전
  static const String apiVersion = '/api';
  
  // 전체 API 베이스 URL
  static String get apiBaseUrl => '$baseUrl$apiVersion';
  
  // Reports용 특별 베이스 URL (서버가 /reports를 기대하므로)
  static String get reportsBaseUrl => baseUrl;

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
  static const String reportBase = '/../reports'; // /api를 우회하고 직접 /reports로 이동
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
  
  // === 웹훅 업로드 관련 (n8n) ===
  static const String webhookImageUploadEndpoint = '/api/v1/webhook/images';

  // === WebSocket 엔드포인트 ===
  static String get wsBaseUrl => baseUrl.replaceFirst('http', 'ws');
  static String get wsUrl => '$wsBaseUrl$apiVersion'; // 추가된 속성
  static const String wsNotifications = '/ws/notifications';
  static const String wsReportUpdates = '/ws/reports';
  
  // === HTTP 헤더 상수 ===
  static const String authorizationHeader = 'Authorization';
  static const String bearerPrefix = 'Bearer ';
  static const String contentTypeHeader = 'Content-Type';
  static const String applicationJson = 'application/json';
  static const String multipartFormData = 'multipart/form-data';

  // === 타임아웃 설정 ===
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // === 재시도 설정 ===
  static const int maxRetryAttempts = 3;
  static const Duration retryDelay = Duration(seconds: 1);

  // === 페이지네이션 ===
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // === 파일 업로드 제한 ===
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedImageFormats = ['jpg', 'jpeg', 'png', 'webp'];
  static const List<String> allowedVideoFormats = ['mp4', 'mov', 'avi'];

  // === 캐시 설정 ===
  static const Duration cacheTimeout = Duration(minutes: 5);
  static const String cacheKeyPrefix = 'jb_report_';

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