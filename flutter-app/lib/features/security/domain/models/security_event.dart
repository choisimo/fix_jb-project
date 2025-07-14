import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/enums/security_enums.dart';

part 'security_event.freezed.dart';
part 'security_event.g.dart';

@freezed
class SecurityEvent with _$SecurityEvent {
  const factory SecurityEvent({
    required String id,
    required SecurityEventType type,
    required SecurityLevel level,
    required DateTime timestamp,
    String? userId,
    String? description,
    Map<String, dynamic>? metadata,
    String? ipAddress,
    String? deviceId,
  }) = _SecurityEvent;
  
  factory SecurityEvent.fromJson(Map<String, dynamic> json) =>
      _$SecurityEventFromJson(json);
}

@freezed
class BiometricAuthResult with _$BiometricAuthResult {
  const factory BiometricAuthResult({
    required bool success,
    required String message,
    String? errorCode,
    DateTime? timestamp,
  }) = _BiometricAuthResult;
  
  factory BiometricAuthResult.fromJson(Map<String, dynamic> json) =>
      _$BiometricAuthResultFromJson(json);
}