import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/enums/security_enums.dart';
import 'security_event.dart';

part 'security_state.freezed.dart';
part 'security_state.g.dart';

@freezed
class SecurityState with _$SecurityState {
  const factory SecurityState({
    @Default(false) bool isAuthenticated,
    @Default(false) bool biometricEnabled,
    @Default(SecurityLevel.normal) SecurityLevel securityLevel,
    @Default(SecurityThreatLevel.low) SecurityThreatLevel threatLevel,
    DateTime? lastSecurityCheck,
    @Default([]) List<SecurityEvent> recentEvents,
  }) = _SecurityState;
  
  factory SecurityState.fromJson(Map<String, dynamic> json) =>
      _$SecurityStateFromJson(json);
}