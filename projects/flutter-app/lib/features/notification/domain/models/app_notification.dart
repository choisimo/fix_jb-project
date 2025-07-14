import 'package:freezed_annotation/freezed_annotation.dart';
import 'notification_settings.dart';

part 'app_notification.freezed.dart';
part 'app_notification.g.dart';

/// 앱 알림 모델
@freezed
class AppNotification with _$AppNotification {
  const factory AppNotification({
    required String id,
    required String title,
    required String body,
    required NotificationType type,
    required NotificationPriority priority,
    required DateTime createdAt,
    
    @Default(false) bool isRead,
    String? icon,
    String? imageUrl,
    Map<String, dynamic>? data,
    List<NotificationAction>? actions,
    DateTime? expiresAt,
    DateTime? readAt,
    
    // 관련 리소스 ID (리포트 ID, 댓글 ID 등)
    String? relatedId,
    String? relatedType,
    
    // 발신자 정보
    String? senderId,
    String? senderName,
    String? senderAvatar,
  }) = _AppNotification;

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      _$AppNotificationFromJson(json);

  const AppNotification._();

  /// 알림이 만료되었는지 확인
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// 알림이 최근 것인지 확인 (24시간 이내)
  bool get isRecent {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    return difference.inHours < 24;
  }

  /// 상대적 시간 표시 (예: "5분 전", "2시간 전")
  String get relativeTime {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

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

/// 알림 상태
enum NotificationStatus {
  unread,
  read,
  archived,
  deleted,
}

/// 알림 필터
@freezed
class NotificationFilter with _$NotificationFilter {
  const factory NotificationFilter({
    @Default(false) bool showReadOnly,
    @Default(false) bool showUnreadOnly,
    NotificationType? type,
    NotificationPriority? priority,
    DateTime? fromDate,
    DateTime? toDate,
    @Default(20) int limit,
    @Default(0) int offset,
  }) = _NotificationFilter;

  factory NotificationFilter.fromJson(Map<String, dynamic> json) =>
      _$NotificationFilterFromJson(json);
}