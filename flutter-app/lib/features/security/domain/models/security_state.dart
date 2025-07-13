import 'package:freezed_annotation/freezed_annotation.dart';
import 'security_event.dart';
import 'privacy_settings.dart';

part 'security_state.freezed.dart';
part 'security_state.g.dart';

@freezed
class SecurityState with _$SecurityState {
  const factory SecurityState({
    @Default(false) bool isBiometricEnabled,
    @Default(SecurityLevel.medium) SecurityLevel currentLevel,
    @Default([]) List<SecurityEvent> recentEvents,
    PrivacySettings? privacySettings,
    @Default(false) bool isDeviceSecure,
    @Default(false) bool isRootDetected,
    @Default(false) bool isDebugMode,
    @Default(false) bool isTampered,
    DateTime? lastSecurityCheck,
    String? error,
    @Default(0) int failedAuthAttempts,
    DateTime? lastFailedAuth,
  }) = _SecurityState;

  factory SecurityState.fromJson(Map<String, dynamic> json) =>
      _$SecurityStateFromJson(json);
}