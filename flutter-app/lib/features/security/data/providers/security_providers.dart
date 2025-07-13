import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../data/services/data_encryption_service.dart';
import '../data/services/biometric_authentication_service.dart';
import '../data/services/app_integrity_verification.dart';
import '../data/services/privacy_protection_manager.dart';
import '../data/services/security_monitoring_service.dart';

part 'security_providers.g.dart';

@riverpod
FlutterSecureStorage secureStorage(SecureStorageRef ref) {
  return const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );
}

@riverpod
LocalAuthentication localAuthentication(LocalAuthenticationRef ref) {
  return LocalAuthentication();
}

@riverpod
DeviceInfoPlugin deviceInfo(DeviceInfoRef ref) {
  return DeviceInfoPlugin();
}

@riverpod
DataEncryptionService dataEncryptionService(DataEncryptionServiceRef ref) {
  final secureStorage = ref.read(secureStorageProvider);
  return DataEncryptionService(secureStorage);
}

@riverpod
BiometricAuthenticationService biometricAuthenticationService(
  BiometricAuthenticationServiceRef ref,
) {
  final localAuth = ref.read(localAuthenticationProvider);
  final secureStorage = ref.read(secureStorageProvider);
  return BiometricAuthenticationService(localAuth, secureStorage);
}

@riverpod
AppIntegrityVerification appIntegrityVerification(
  AppIntegrityVerificationRef ref,
) {
  final deviceInfo = ref.read(deviceInfoProvider);
  return AppIntegrityVerification(deviceInfo);
}

@riverpod
PrivacyProtectionManager privacyProtectionManager(
  PrivacyProtectionManagerRef ref,
) {
  final secureStorage = ref.read(secureStorageProvider);
  final encryptionService = ref.read(dataEncryptionServiceProvider);
  return PrivacyProtectionManager(secureStorage, encryptionService);
}

@riverpod
SecurityMonitoringService securityMonitoringService(
  SecurityMonitoringServiceRef ref,
) {
  final secureStorage = ref.read(secureStorageProvider);
  final encryptionService = ref.read(dataEncryptionServiceProvider);
  final integrityVerification = ref.read(appIntegrityVerificationProvider);
  
  return SecurityMonitoringService(
    secureStorage,
    encryptionService,
    integrityVerification,
  );
}