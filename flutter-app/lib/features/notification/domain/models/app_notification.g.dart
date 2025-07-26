// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AppNotificationImpl _$$AppNotificationImplFromJson(
        Map<String, dynamic> json) =>
    _$AppNotificationImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      type: $enumDecode(_$NotificationTypeEnumMap, json['type']),
      priority: $enumDecode(_$NotificationPriorityEnumMap, json['priority']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      isRead: json['isRead'] as bool? ?? false,
      icon: json['icon'] as String?,
      imageUrl: json['imageUrl'] as String?,
      data: json['data'] as Map<String, dynamic>?,
      actions: (json['actions'] as List<dynamic>?)
          ?.map((e) => NotificationAction.fromJson(e as Map<String, dynamic>))
          .toList(),
      expiresAt: json['expiresAt'] == null
          ? null
          : DateTime.parse(json['expiresAt'] as String),
      readAt: json['readAt'] == null
          ? null
          : DateTime.parse(json['readAt'] as String),
      relatedId: json['relatedId'] as String?,
      relatedType: json['relatedType'] as String?,
      senderId: json['senderId'] as String?,
      senderName: json['senderName'] as String?,
      senderAvatar: json['senderAvatar'] as String?,
    );

Map<String, dynamic> _$$AppNotificationImplToJson(
        _$AppNotificationImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'body': instance.body,
      'type': _$NotificationTypeEnumMap[instance.type]!,
      'priority': _$NotificationPriorityEnumMap[instance.priority]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'isRead': instance.isRead,
      'icon': instance.icon,
      'imageUrl': instance.imageUrl,
      'data': instance.data,
      'actions': instance.actions,
      'expiresAt': instance.expiresAt?.toIso8601String(),
      'readAt': instance.readAt?.toIso8601String(),
      'relatedId': instance.relatedId,
      'relatedType': instance.relatedType,
      'senderId': instance.senderId,
      'senderName': instance.senderName,
      'senderAvatar': instance.senderAvatar,
    };

const _$NotificationTypeEnumMap = {
  NotificationType.reportStatus: 'report_status',
  NotificationType.comment: 'comment',
  NotificationType.system: 'system',
  NotificationType.announcement: 'announcement',
  NotificationType.reminder: 'reminder',
};

const _$NotificationPriorityEnumMap = {
  NotificationPriority.low: 'low',
  NotificationPriority.normal: 'normal',
  NotificationPriority.high: 'high',
  NotificationPriority.urgent: 'urgent',
};

_$NotificationFilterImpl _$$NotificationFilterImplFromJson(
        Map<String, dynamic> json) =>
    _$NotificationFilterImpl(
      showReadOnly: json['showReadOnly'] as bool? ?? false,
      showUnreadOnly: json['showUnreadOnly'] as bool? ?? false,
      type: $enumDecodeNullable(_$NotificationTypeEnumMap, json['type']),
      priority:
          $enumDecodeNullable(_$NotificationPriorityEnumMap, json['priority']),
      fromDate: json['fromDate'] == null
          ? null
          : DateTime.parse(json['fromDate'] as String),
      toDate: json['toDate'] == null
          ? null
          : DateTime.parse(json['toDate'] as String),
      limit: (json['limit'] as num?)?.toInt() ?? 20,
      offset: (json['offset'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$NotificationFilterImplToJson(
        _$NotificationFilterImpl instance) =>
    <String, dynamic>{
      'showReadOnly': instance.showReadOnly,
      'showUnreadOnly': instance.showUnreadOnly,
      'type': _$NotificationTypeEnumMap[instance.type],
      'priority': _$NotificationPriorityEnumMap[instance.priority],
      'fromDate': instance.fromDate?.toIso8601String(),
      'toDate': instance.toDate?.toIso8601String(),
      'limit': instance.limit,
      'offset': instance.offset,
    };
