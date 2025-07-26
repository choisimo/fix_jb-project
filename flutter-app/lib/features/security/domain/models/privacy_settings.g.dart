// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'privacy_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PrivacySettingsImpl _$$PrivacySettingsImplFromJson(
        Map<String, dynamic> json) =>
    _$PrivacySettingsImpl(
      allowDataCollection: json['allowDataCollection'] as bool? ?? false,
      allowLocationTracking: json['allowLocationTracking'] as bool? ?? false,
      allowAnalytics: json['allowAnalytics'] as bool? ?? false,
      allowMarketing: json['allowMarketing'] as bool? ?? false,
      retention: $enumDecodeNullable(
              _$DataRetentionPeriodEnumMap, json['retention']) ??
          DataRetentionPeriod.oneYear,
      consentedPurposes: (json['consentedPurposes'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      lastUpdated: json['lastUpdated'] == null
          ? null
          : DateTime.parse(json['lastUpdated'] as String),
      allowPersonalization: json['allowPersonalization'] as bool? ?? false,
      allowThirdPartySharing: json['allowThirdPartySharing'] as bool? ?? false,
      requireExplicitConsent: json['requireExplicitConsent'] as bool? ?? true,
    );

Map<String, dynamic> _$$PrivacySettingsImplToJson(
        _$PrivacySettingsImpl instance) =>
    <String, dynamic>{
      'allowDataCollection': instance.allowDataCollection,
      'allowLocationTracking': instance.allowLocationTracking,
      'allowAnalytics': instance.allowAnalytics,
      'allowMarketing': instance.allowMarketing,
      'retention': _$DataRetentionPeriodEnumMap[instance.retention]!,
      'consentedPurposes': instance.consentedPurposes,
      'lastUpdated': instance.lastUpdated?.toIso8601String(),
      'allowPersonalization': instance.allowPersonalization,
      'allowThirdPartySharing': instance.allowThirdPartySharing,
      'requireExplicitConsent': instance.requireExplicitConsent,
    };

const _$DataRetentionPeriodEnumMap = {
  DataRetentionPeriod.threeMonths: '3_months',
  DataRetentionPeriod.sixMonths: '6_months',
  DataRetentionPeriod.oneYear: '1_year',
  DataRetentionPeriod.twoYears: '2_years',
  DataRetentionPeriod.indefinite: 'indefinite',
};
