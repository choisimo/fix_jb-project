// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'security_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SecurityStateImpl _$$SecurityStateImplFromJson(Map<String, dynamic> json) =>
    _$SecurityStateImpl(
      isBiometricEnabled: json['isBiometricEnabled'] as bool? ?? false,
      currentLevel:
          $enumDecodeNullable(_$SecurityLevelEnumMap, json['currentLevel']) ??
              SecurityLevel.medium,
      recentEvents: (json['recentEvents'] as List<dynamic>?)
              ?.map((e) => SecurityEvent.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      privacySettings: json['privacySettings'] == null
          ? null
          : PrivacySettings.fromJson(
              json['privacySettings'] as Map<String, dynamic>),
      isDeviceSecure: json['isDeviceSecure'] as bool? ?? false,
      isRootDetected: json['isRootDetected'] as bool? ?? false,
      isDebugMode: json['isDebugMode'] as bool? ?? false,
      isTampered: json['isTampered'] as bool? ?? false,
      lastSecurityCheck: json['lastSecurityCheck'] == null
          ? null
          : DateTime.parse(json['lastSecurityCheck'] as String),
      error: json['error'] as String?,
      failedAuthAttempts: (json['failedAuthAttempts'] as num?)?.toInt() ?? 0,
      lastFailedAuth: json['lastFailedAuth'] == null
          ? null
          : DateTime.parse(json['lastFailedAuth'] as String),
    );

Map<String, dynamic> _$$SecurityStateImplToJson(_$SecurityStateImpl instance) =>
    <String, dynamic>{
      'isBiometricEnabled': instance.isBiometricEnabled,
      'currentLevel': _$SecurityLevelEnumMap[instance.currentLevel]!,
      'recentEvents': instance.recentEvents,
      'privacySettings': instance.privacySettings,
      'isDeviceSecure': instance.isDeviceSecure,
      'isRootDetected': instance.isRootDetected,
      'isDebugMode': instance.isDebugMode,
      'isTampered': instance.isTampered,
      'lastSecurityCheck': instance.lastSecurityCheck?.toIso8601String(),
      'error': instance.error,
      'failedAuthAttempts': instance.failedAuthAttempts,
      'lastFailedAuth': instance.lastFailedAuth?.toIso8601String(),
    };

const _$SecurityLevelEnumMap = {
  SecurityLevel.low: 'low',
  SecurityLevel.medium: 'medium',
  SecurityLevel.high: 'high',
  SecurityLevel.critical: 'critical',
};
