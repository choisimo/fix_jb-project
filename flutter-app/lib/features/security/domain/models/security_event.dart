import 'package:freezed_annotation/freezed_annotation.dart';

part 'security_event.freezed.dart';
part 'security_event.g.dart';

/// 보안 이벤트 타입
enum SecurityEventType {
  @JsonValue('login_attempt')
  loginAttempt,
  
  @JsonValue('login_success')
  loginSuccess,
  
  @JsonValue('login_failure')
  loginFailure,
  
  @JsonValue('logout')
  logout,
  
  @JsonValue('password_change')
  passwordChange,
  
  @JsonValue('biometric_auth')
  biometricAuth,
  
  @JsonValue('token_refresh')
  tokenRefresh,
  
  @JsonValue('data_access')
  dataAccess,
  
  @JsonValue('data_modification')
  dataModification,
  
  @JsonValue('permission_denied')
  permissionDenied,
  
  @JsonValue('suspicious_activity')
  suspiciousActivity,
  
  @JsonValue('security_breach')
  securityBreach,
}

/// 보안 위험 수준
enum SecurityLevel {
  @JsonValue('low')
  low,
  
  @JsonValue('medium')
  medium,
  
  @JsonValue('high')
  high,
  
  @JsonValue('critical')
  critical,
}

/// 보안 위협 수준 (앱 무결성 검증용)
enum SecurityThreatLevel {
  @JsonValue('none')
  none,
  
  @JsonValue('low')
  low,
  
  @JsonValue('medium')
  medium,
  
  @JsonValue('high')
  high,
  
  @JsonValue('critical')
  critical,
}

/// 보안 이벤트
@freezed
class SecurityEvent with _$SecurityEvent {
  const factory SecurityEvent({
    required String id,
    required SecurityEventType type,
    required SecurityLevel level,
    required DateTime timestamp,
    required String userId,
    
    String? description,
    String? ipAddress,
    String? userAgent,
    String? deviceId,
    String? sessionId,
    Map<String, dynamic>? metadata,
    
    // 위치 정보 (선택적)
    double? latitude,
    double? longitude,
    String? location,
    
    // 처리 상태
    @Default(false) bool isResolved,
    DateTime? resolvedAt,
    String? resolvedBy,
    String? resolution,
  }) = _SecurityEvent;

  factory SecurityEvent.fromJson(Map<String, dynamic> json) =>
      _$SecurityEventFromJson(json);

  const SecurityEvent._();

  /// 이벤트가 최근 것인지 확인 (1시간 이내)
  bool get isRecent {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    return difference.inHours < 1;
  }

  /// 이벤트가 중요한지 확인
  bool get isCritical {
    return level == SecurityLevel.critical || 
           level == SecurityLevel.high;
  }

  /// 상대적 시간 표시
  String get relativeTime {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}일 전';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }
}

/// 보안 상태
@freezed
class SecurityState with _$SecurityState {
  const factory SecurityState({
    @Default(SecurityThreatLevel.none) SecurityThreatLevel threatLevel,
    @Default(false) bool isDeviceSecure,
    @Default(false) bool isBiometricEnabled,
    @Default(false) bool isAppTampered,
    @Default(false) bool isDebuggingDetected,
    @Default(false) bool isRootedOrJailbroken,
    
    List<SecurityEvent>? recentEvents,
    DateTime? lastSecurityCheck,
    Map<String, dynamic>? deviceInfo,
  }) = _SecurityState;

  factory SecurityState.fromJson(Map<String, dynamic> json) =>
      _$SecurityStateFromJson(json);

  const SecurityState._();

  /// 전체적인 보안 상태가 안전한지 확인
  bool get isSecure {
    return threatLevel == SecurityThreatLevel.none &&
           isDeviceSecure &&
           !isAppTampered &&
           !isDebuggingDetected &&
           !isRootedOrJailbroken;
  }

  /// 보안 점수 (0-100)
  int get securityScore {
    int score = 100;
    
    // 위협 수준에 따른 감점
    switch (threatLevel) {
      case SecurityThreatLevel.low:
        score -= 10;
        break;
      case SecurityThreatLevel.medium:
        score -= 25;
        break;
      case SecurityThreatLevel.high:
        score -= 50;
        break;
      case SecurityThreatLevel.critical:
        score -= 75;
        break;
      case SecurityThreatLevel.none:
        break;
    }
    
    // 기타 보안 위험 요소들
    if (!isDeviceSecure) score -= 15;
    if (isAppTampered) score -= 30;
    if (isDebuggingDetected) score -= 20;
    if (isRootedOrJailbroken) score -= 40;
    
    return score.clamp(0, 100);
  }
}

/// SecurityEventType 확장
extension SecurityEventTypeExtension on SecurityEventType {
  String get displayName {
    switch (this) {
      case SecurityEventType.loginAttempt:
        return '로그인 시도';
      case SecurityEventType.loginSuccess:
        return '로그인 성공';
      case SecurityEventType.loginFailure:
        return '로그인 실패';
      case SecurityEventType.logout:
        return '로그아웃';
      case SecurityEventType.passwordChange:
        return '비밀번호 변경';
      case SecurityEventType.biometricAuth:
        return '생체 인증';
      case SecurityEventType.tokenRefresh:
        return '토큰 갱신';
      case SecurityEventType.dataAccess:
        return '데이터 접근';
      case SecurityEventType.dataModification:
        return '데이터 수정';
      case SecurityEventType.permissionDenied:
        return '권한 거부';
      case SecurityEventType.suspiciousActivity:
        return '의심스러운 활동';
      case SecurityEventType.securityBreach:
        return '보안 침해';
    }
  }

  SecurityLevel get defaultLevel {
    switch (this) {
      case SecurityEventType.loginSuccess:
      case SecurityEventType.logout:
      case SecurityEventType.tokenRefresh:
      case SecurityEventType.dataAccess:
        return SecurityLevel.low;
      case SecurityEventType.loginAttempt:
      case SecurityEventType.biometricAuth:
      case SecurityEventType.dataModification:
        return SecurityLevel.medium;
      case SecurityEventType.loginFailure:
      case SecurityEventType.passwordChange:
      case SecurityEventType.permissionDenied:
        return SecurityLevel.high;
      case SecurityEventType.suspiciousActivity:
      case SecurityEventType.securityBreach:
        return SecurityLevel.critical;
    }
  }
}

/// SecurityLevel 확장
extension SecurityLevelExtension on SecurityLevel {
  String get displayName {
    switch (this) {
      case SecurityLevel.low:
        return '낮음';
      case SecurityLevel.medium:
        return '보통';
      case SecurityLevel.high:
        return '높음';
      case SecurityLevel.critical:
        return '치명적';
    }
  }

  int get priority {
    switch (this) {
      case SecurityLevel.low:
        return 1;
      case SecurityLevel.medium:
        return 2;
      case SecurityLevel.high:
        return 3;
      case SecurityLevel.critical:
        return 4;
    }
  }
}