// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NotificationSettingsImpl _$$NotificationSettingsImplFromJson(
        Map<String, dynamic> json) =>
    _$NotificationSettingsImpl(
      enableNotifications: json['enableNotifications'] as bool? ?? true,
      enablePushNotifications: json['enablePushNotifications'] as bool? ?? true,
      enableInAppNotifications:
          json['enableInAppNotifications'] as bool? ?? true,
      enableEmailNotifications:
          json['enableEmailNotifications'] as bool? ?? true,
      enableSound: json['enableSound'] as bool? ?? true,
      enableVibration: json['enableVibration'] as bool? ?? true,
      enableLedIndicator: json['enableLedIndicator'] as bool? ?? true,
      enableReportStatusNotifications:
          json['enableReportStatusNotifications'] as bool? ?? true,
      enableCommentNotifications:
          json['enableCommentNotifications'] as bool? ?? true,
      enableSystemNotifications:
          json['enableSystemNotifications'] as bool? ?? true,
      enableAnnouncementNotifications:
          json['enableAnnouncementNotifications'] as bool? ?? true,
      enableReminderNotifications:
          json['enableReminderNotifications'] as bool? ?? false,
      quietHoursStart: json['quietHoursStart'] as String? ?? '09:00',
      quietHoursEnd: json['quietHoursEnd'] as String? ?? '22:00',
      enableQuietHours: json['enableQuietHours'] as bool? ?? false,
      minimumPriority: $enumDecodeNullable(
              _$NotificationPriorityEnumMap, json['minimumPriority']) ??
          NotificationPriority.normal,
      maxNotificationsPerDay:
          (json['maxNotificationsPerDay'] as num?)?.toInt() ?? 100,
      groupSimilarNotifications:
          json['groupSimilarNotifications'] as bool? ?? false,
      fcmToken: json['fcmToken'] as String?,
      lastUpdated: json['lastUpdated'] == null
          ? null
          : DateTime.parse(json['lastUpdated'] as String),
    );

Map<String, dynamic> _$$NotificationSettingsImplToJson(
        _$NotificationSettingsImpl instance) =>
    <String, dynamic>{
      'enableNotifications': instance.enableNotifications,
      'enablePushNotifications': instance.enablePushNotifications,
      'enableInAppNotifications': instance.enableInAppNotifications,
      'enableEmailNotifications': instance.enableEmailNotifications,
      'enableSound': instance.enableSound,
      'enableVibration': instance.enableVibration,
      'enableLedIndicator': instance.enableLedIndicator,
      'enableReportStatusNotifications':
          instance.enableReportStatusNotifications,
      'enableCommentNotifications': instance.enableCommentNotifications,
      'enableSystemNotifications': instance.enableSystemNotifications,
      'enableAnnouncementNotifications':
          instance.enableAnnouncementNotifications,
      'enableReminderNotifications': instance.enableReminderNotifications,
      'quietHoursStart': instance.quietHoursStart,
      'quietHoursEnd': instance.quietHoursEnd,
      'enableQuietHours': instance.enableQuietHours,
      'minimumPriority':
          _$NotificationPriorityEnumMap[instance.minimumPriority]!,
      'maxNotificationsPerDay': instance.maxNotificationsPerDay,
      'groupSimilarNotifications': instance.groupSimilarNotifications,
      'fcmToken': instance.fcmToken,
      'lastUpdated': instance.lastUpdated?.toIso8601String(),
    };

const _$NotificationPriorityEnumMap = {
  NotificationPriority.low: 'low',
  NotificationPriority.normal: 'normal',
  NotificationPriority.high: 'high',
  NotificationPriority.urgent: 'urgent',
};

_$NotificationActionImpl _$$NotificationActionImplFromJson(
        Map<String, dynamic> json) =>
    _$NotificationActionImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      icon: json['icon'] as String?,
      data: json['data'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$NotificationActionImplToJson(
        _$NotificationActionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'icon': instance.icon,
      'data': instance.data,
    };
