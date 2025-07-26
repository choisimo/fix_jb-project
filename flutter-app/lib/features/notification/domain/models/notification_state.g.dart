// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NotificationStateImpl _$$NotificationStateImplFromJson(
        Map<String, dynamic> json) =>
    _$NotificationStateImpl(
      notifications: (json['notifications'] as List<dynamic>?)
              ?.map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
      isConnected: json['isConnected'] as bool? ?? false,
      isLoading: json['isLoading'] as bool? ?? false,
      isInitializing: json['isInitializing'] as bool? ?? false,
      settings: json['settings'] == null
          ? null
          : NotificationSettings.fromJson(
              json['settings'] as Map<String, dynamic>),
      connectionStatus: $enumDecodeNullable(
              _$ConnectionStatusEnumMap, json['connectionStatus']) ??
          ConnectionStatus.disconnected,
      recentNotifications: (json['recentNotifications'] as List<dynamic>?)
              ?.map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      error: json['error'] as String?,
      lastSync: json['lastSync'] == null
          ? null
          : DateTime.parse(json['lastSync'] as String),
      hasPendingNotifications:
          json['hasPendingNotifications'] as bool? ?? false,
      fcmToken: json['fcmToken'] as String?,
    );

Map<String, dynamic> _$$NotificationStateImplToJson(
        _$NotificationStateImpl instance) =>
    <String, dynamic>{
      'notifications': instance.notifications,
      'unreadCount': instance.unreadCount,
      'isConnected': instance.isConnected,
      'isLoading': instance.isLoading,
      'isInitializing': instance.isInitializing,
      'settings': instance.settings,
      'connectionStatus': _$ConnectionStatusEnumMap[instance.connectionStatus]!,
      'recentNotifications': instance.recentNotifications,
      'error': instance.error,
      'lastSync': instance.lastSync?.toIso8601String(),
      'hasPendingNotifications': instance.hasPendingNotifications,
      'fcmToken': instance.fcmToken,
    };

const _$ConnectionStatusEnumMap = {
  ConnectionStatus.connected: 'connected',
  ConnectionStatus.connecting: 'connecting',
  ConnectionStatus.disconnected: 'disconnected',
  ConnectionStatus.reconnecting: 'reconnecting',
  ConnectionStatus.error: 'error',
};
