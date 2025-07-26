// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'security_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SecurityEventImpl _$$SecurityEventImplFromJson(Map<String, dynamic> json) =>
    _$SecurityEventImpl(
      id: json['id'] as String,
      type: $enumDecode(_$SecurityEventTypeEnumMap, json['type']),
      level: $enumDecode(_$SecurityLevelEnumMap, json['level']),
      timestamp: DateTime.parse(json['timestamp'] as String),
      userId: json['userId'] as String,
      description: json['description'] as String?,
      ipAddress: json['ipAddress'] as String?,
      userAgent: json['userAgent'] as String?,
      deviceId: json['deviceId'] as String?,
      sessionId: json['sessionId'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      location: json['location'] as String?,
      isResolved: json['isResolved'] as bool? ?? false,
      resolvedAt: json['resolvedAt'] == null
          ? null
          : DateTime.parse(json['resolvedAt'] as String),
      resolvedBy: json['resolvedBy'] as String?,
      resolution: json['resolution'] as String?,
    );

Map<String, dynamic> _$$SecurityEventImplToJson(_$SecurityEventImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$SecurityEventTypeEnumMap[instance.type]!,
      'level': _$SecurityLevelEnumMap[instance.level]!,
      'timestamp': instance.timestamp.toIso8601String(),
      'userId': instance.userId,
      'description': instance.description,
      'ipAddress': instance.ipAddress,
      'userAgent': instance.userAgent,
      'deviceId': instance.deviceId,
      'sessionId': instance.sessionId,
      'metadata': instance.metadata,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'location': instance.location,
      'isResolved': instance.isResolved,
      'resolvedAt': instance.resolvedAt?.toIso8601String(),
      'resolvedBy': instance.resolvedBy,
      'resolution': instance.resolution,
    };

const _$SecurityEventTypeEnumMap = {
  SecurityEventType.loginAttempt: 'login_attempt',
  SecurityEventType.loginSuccess: 'login_success',
  SecurityEventType.loginFailure: 'login_failure',
  SecurityEventType.logout: 'logout',
  SecurityEventType.passwordChange: 'password_change',
  SecurityEventType.biometricAuth: 'biometric_auth',
  SecurityEventType.tokenRefresh: 'token_refresh',
  SecurityEventType.dataAccess: 'data_access',
  SecurityEventType.dataModification: 'data_modification',
  SecurityEventType.permissionDenied: 'permission_denied',
  SecurityEventType.suspiciousActivity: 'suspicious_activity',
  SecurityEventType.securityBreach: 'security_breach',
};

const _$SecurityLevelEnumMap = {
  SecurityLevel.low: 'low',
  SecurityLevel.medium: 'medium',
  SecurityLevel.high: 'high',
  SecurityLevel.critical: 'critical',
};

_$SecurityStateImpl _$$SecurityStateImplFromJson(Map<String, dynamic> json) =>
    _$SecurityStateImpl(
      threatLevel: $enumDecodeNullable(
              _$SecurityThreatLevelEnumMap, json['threatLevel']) ??
          SecurityThreatLevel.none,
      isDeviceSecure: json['isDeviceSecure'] as bool? ?? false,
      isBiometricEnabled: json['isBiometricEnabled'] as bool? ?? false,
      isAppTampered: json['isAppTampered'] as bool? ?? false,
      isDebuggingDetected: json['isDebuggingDetected'] as bool? ?? false,
      isRootedOrJailbroken: json['isRootedOrJailbroken'] as bool? ?? false,
      recentEvents: (json['recentEvents'] as List<dynamic>?)
          ?.map((e) => SecurityEvent.fromJson(e as Map<String, dynamic>))
          .toList(),
      lastSecurityCheck: json['lastSecurityCheck'] == null
          ? null
          : DateTime.parse(json['lastSecurityCheck'] as String),
      deviceInfo: json['deviceInfo'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$SecurityStateImplToJson(_$SecurityStateImpl instance) =>
    <String, dynamic>{
      'threatLevel': _$SecurityThreatLevelEnumMap[instance.threatLevel]!,
      'isDeviceSecure': instance.isDeviceSecure,
      'isBiometricEnabled': instance.isBiometricEnabled,
      'isAppTampered': instance.isAppTampered,
      'isDebuggingDetected': instance.isDebuggingDetected,
      'isRootedOrJailbroken': instance.isRootedOrJailbroken,
      'recentEvents': instance.recentEvents,
      'lastSecurityCheck': instance.lastSecurityCheck?.toIso8601String(),
      'deviceInfo': instance.deviceInfo,
    };

const _$SecurityThreatLevelEnumMap = {
  SecurityThreatLevel.none: 'none',
  SecurityThreatLevel.low: 'low',
  SecurityThreatLevel.medium: 'medium',
  SecurityThreatLevel.high: 'high',
  SecurityThreatLevel.critical: 'critical',
};
