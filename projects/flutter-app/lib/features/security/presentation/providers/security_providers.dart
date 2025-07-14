import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/data_encryption_service.dart';
import '../../data/services/biometric_authentication_service.dart';
import '../../data/services/app_integrity_verification.dart';
import '../../data/services/privacy_protection_manager.dart';
import '../../data/services/security_monitoring_service.dart';

final dataEncryptionServiceProvider = Provider<DataEncryptionService>((ref) {
  return DataEncryptionService();
});

final biometricAuthenticationServiceProvider = Provider<BiometricAuthenticationService>((ref) {
  return BiometricAuthenticationService();
});

final appIntegrityVerificationProvider = Provider<AppIntegrityVerification>((ref) {
  return AppIntegrityVerification();
});

final privacyProtectionManagerProvider = Provider<PrivacyProtectionManager>((ref) {
  return PrivacyProtectionManager();
});

final securityMonitoringServiceProvider = Provider<SecurityMonitoringService>((ref) {
  return SecurityMonitoringService();
});
