import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_settings.freezed.dart';
part 'notification_settings.g.dart';

/// 알림 타입
enum NotificationType {
  @JsonValue('report_status')
  reportStatus,
  
  @JsonValue('comment')
  comment,
  
  @JsonValue('system')
  system,
  
  @JsonValue('announcement')
  announcement,
  
  @JsonValue('reminder')
  reminder,
}

/// 알림 우선순위
enum NotificationPriority {
  @JsonValue('low')
  low,
  
  @JsonValue('normal')
  normal,
  
  @JsonValue('high')
  high,
  
  @JsonValue('urgent')
  urgent,
}

/// 알림 설정
@freezed
class NotificationSettings with _$NotificationSettings {
  const factory NotificationSettings({
    // 기본 알림 설정
    @Default(true) bool enableNotifications,
    @Default(true) bool enablePushNotifications,
    @Default(true) bool enableInAppNotifications,
    @Default(true) bool enableEmailNotifications,
    
    // 소리 및 진동 설정
    @Default(true) bool enableSound,
    @Default(true) bool enableVibration,
    @Default(true) bool enableLedIndicator,
    
    // 타입별 알림 설정
    @Default(true) bool enableReportStatusNotifications,
    @Default(true) bool enableCommentNotifications,
    @Default(true) bool enableSystemNotifications,
    @Default(true) bool enableAnnouncementNotifications,
    @Default(false) bool enableReminderNotifications,
    
    // 시간 설정
    @Default('09:00') String quietHoursStart,
    @Default('22:00') String quietHoursEnd,
    @Default(false) bool enableQuietHours,
    
    // 고급 설정
    @Default(NotificationPriority.normal) NotificationPriority minimumPriority,
    @Default(100) int maxNotificationsPerDay,
    @Default(false) bool groupSimilarNotifications,
    
    // FCM 토큰
    String? fcmToken,
    
    // 마지막 업데이트 시간
    DateTime? lastUpdated,
  }) = _NotificationSettings;

  factory NotificationSettings.fromJson(Map<String, dynamic> json) =>
      _$NotificationSettingsFromJson(json);

  const NotificationSettings._();

  /// 특정 타입의 알림이 활성화되었는지 확인
  bool isTypeEnabled(NotificationType type) {
    if (!enableNotifications) return false;
    
    switch (type) {
      case NotificationType.reportStatus:
        return enableReportStatusNotifications;
      case NotificationType.comment:
        return enableCommentNotifications;
      case NotificationType.system:
        return enableSystemNotifications;
      case NotificationType.announcement:
        return enableAnnouncementNotifications;
      case NotificationType.reminder:
        return enableReminderNotifications;
    }
  }

  /// 현재 시간이 조용한 시간인지 확인
  bool get isQuietTime {
    if (!enableQuietHours) return false;
    
    final now = TimeOfDay.now();
    final start = _parseTimeOfDay(quietHoursStart);
    final end = _parseTimeOfDay(quietHoursEnd);
    
    if (start.hour < end.hour) {
      // 같은 날 (예: 09:00 - 22:00)
      return now.hour >= start.hour && now.hour < end.hour;
    } else {
      // 다음 날까지 (예: 22:00 - 09:00)
      return now.hour >= start.hour || now.hour < end.hour;
    }
  }

  TimeOfDay _parseTimeOfDay(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }
}

/// 알림 액션
@freezed
class NotificationAction with _$NotificationAction {
  const factory NotificationAction({
    required String id,
    required String title,
    String? icon,
    Map<String, dynamic>? data,
  }) = _NotificationAction;

  factory NotificationAction.fromJson(Map<String, dynamic> json) =>
      _$NotificationActionFromJson(json);
}

/// NotificationType 확장
extension NotificationTypeExtension on NotificationType {
  String get displayName {
    switch (this) {
      case NotificationType.reportStatus:
        return '리포트 상태 알림';
      case NotificationType.comment:
        return '댓글 알림';
      case NotificationType.system:
        return '시스템 알림';
      case NotificationType.announcement:
        return '공지사항 알림';
      case NotificationType.reminder:
        return '리마인더 알림';
    }
  }

  String get description {
    switch (this) {
      case NotificationType.reportStatus:
        return '내가 제출한 리포트의 상태가 변경될 때';
      case NotificationType.comment:
        return '내 리포트에 댓글이 달릴 때';
      case NotificationType.system:
        return '시스템 관련 중요한 알림';
      case NotificationType.announcement:
        return '앱 공지사항 및 업데이트';
      case NotificationType.reminder:
        return '할 일 및 일정 리마인더';
    }
  }
}

/// NotificationPriority 확장
extension NotificationPriorityExtension on NotificationPriority {
  String get displayName {
    switch (this) {
      case NotificationPriority.low:
        return '낮음';
      case NotificationPriority.normal:
        return '보통';
      case NotificationPriority.high:
        return '높음';
      case NotificationPriority.urgent:
        return '긴급';
    }
  }

  int get level {
    switch (this) {
      case NotificationPriority.low:
        return 1;
      case NotificationPriority.normal:
        return 2;
      case NotificationPriority.high:
        return 3;
      case NotificationPriority.urgent:
        return 4;
    }
  }
}

// TimeOfDay import 추가
class TimeOfDay {
  final int hour;
  final int minute;
  
  const TimeOfDay({required this.hour, required this.minute});
  
  static TimeOfDay now() {
    final now = DateTime.now();
    return TimeOfDay(hour: now.hour, minute: now.minute);
  }
}