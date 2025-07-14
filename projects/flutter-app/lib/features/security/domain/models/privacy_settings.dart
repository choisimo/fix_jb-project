import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/enums/privacy_enums.dart';

part 'privacy_settings.freezed.dart';
part 'privacy_settings.g.dart';

@freezed
class PrivacySettings with _$PrivacySettings {
  const factory PrivacySettings({
    @Default(true) bool dataCollection,
    @Default(true) bool analytics,
    @Default(false) bool marketing,
    @Default(true) bool crashReporting,
    @Default(false) bool locationTracking,
    Map<ConsentType, bool>? consents,
    DateTime? lastUpdated,
  }) = _PrivacySettings;
  
  factory PrivacySettings.fromJson(Map<String, dynamic> json) =>
      _$PrivacySettingsFromJson(json);
}

@freezed
class DataSubjectRightResponse with _$DataSubjectRightResponse {
  const factory DataSubjectRightResponse({
    required DataSubjectRight right,
    required bool granted,
    required DateTime timestamp,
    String? reference,
    String? details,
  }) = _DataSubjectRightResponse;
  
  factory DataSubjectRightResponse.fromJson(Map<String, dynamic> json) =>
      _$DataSubjectRightResponseFromJson(json);
}