import 'package:freezed_annotation/freezed_annotation.dart';
import 'app_notification.dart';
import 'notification_settings.dart';

part 'notification_state.freezed.dart';
part 'notification_state.g.dart';

@freezed
class NotificationState with _$NotificationState {
  const factory NotificationState({
    @Default([]) List<AppNotification> notifications,
    @Default(0) int unreadCount,
    @Default(false) bool isConnected,
    @Default(false) bool isLoading,
    @Default(false) bool isInitializing,
    NotificationSettings? settings,
    @Default(ConnectionStatus.disconnected) ConnectionStatus connectionStatus,
    @Default([]) List<AppNotification> recentNotifications,
    String? error,
    DateTime? lastSync,
    @Default(false) bool hasPendingNotifications,
    String? fcmToken,
  }) = _NotificationState;

  factory NotificationState.fromJson(Map<String, dynamic> json) =>
      _$NotificationStateFromJson(json);
}

@JsonEnum()
enum ConnectionStatus {
  @JsonValue('connected')
  connected,
  @JsonValue('connecting')
  connecting,
  @JsonValue('disconnected')
  disconnected,
  @JsonValue('reconnecting')
  reconnecting,
  @JsonValue('error')
  error,
}