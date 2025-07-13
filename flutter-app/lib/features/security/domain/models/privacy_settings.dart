import 'package:freezed_annotation/freezed_annotation.dart';

part 'privacy_settings.freezed.dart';
part 'privacy_settings.g.dart';

@freezed
class PrivacySettings with _$PrivacySettings {
  const factory PrivacySettings({
    @Default(false) bool allowDataCollection,
    @Default(false) bool allowLocationTracking,
    @Default(false) bool allowAnalytics,
    @Default(false) bool allowMarketing,
    @Default(DataRetentionPeriod.oneYear) DataRetentionPeriod retention,
    List<String>? consentedPurposes,
    DateTime? lastUpdated,
    @Default(false) bool allowPersonalization,
    @Default(false) bool allowThirdPartySharing,
    @Default(true) bool requireExplicitConsent,
  }) = _PrivacySettings;

  factory PrivacySettings.fromJson(Map<String, dynamic> json) =>
      _$PrivacySettingsFromJson(json);
}

@JsonEnum()
enum DataRetentionPeriod {
  @JsonValue('3_months')
  threeMonths,
  @JsonValue('6_months')
  sixMonths,
  @JsonValue('1_year')
  oneYear,
  @JsonValue('2_years')
  twoYears,
  @JsonValue('indefinite')
  indefinite,
}