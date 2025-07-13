import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

enum BiometricType {
  none,
  fingerprint,
  face,
  iris,
  voice,
}

enum BiometricAuthResult {
  success,
  failed,
  cancelled,
  notAvailable,
  notEnrolled,
  lockedOut,
  permanentlyLockedOut,
  unknown,
}

class BiometricAuthenticationService {
  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _biometricSetupCompleteKey = 'biometric_setup_complete';
  static const String _failedAttemptsKey = 'biometric_failed_attempts';
  static const int _maxFailedAttempts = 5;
  
  final LocalAuthentication _localAuth;
  final FlutterSecureStorage _secureStorage;
  
  BiometricAuthenticationService(this._localAuth, this._secureStorage);
  
  /// Initialize biometric authentication service
  Future<void> initialize() async {
    try {
      await _checkBiometricSupport();
    } catch (e) {
      debugPrint('Failed to initialize biometric service: $e');
    }
  }
  
  /// Check if biometric authentication is available on device
  Future<bool> isAvailable() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } catch (e) {
      debugPrint('Error checking biometric availability: $e');
      return false;
    }
  }
  
  /// Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      return availableBiometrics.map((biometric) {
        switch (biometric) {
          case BiometricType.fingerprint:
            return BiometricType.fingerprint;
          case BiometricType.face:
            return BiometricType.face;
          case BiometricType.iris:
            return BiometricType.iris;
          case BiometricType.weak:
          case BiometricType.strong:
          default:
            return BiometricType.none;
        }
      }).where((type) => type != BiometricType.none).toList();
    } catch (e) {
      debugPrint('Error getting available biometrics: $e');
      return [];
    }
  }
  
  /// Check if device has enrolled biometrics
  Future<bool> hasEnrolledBiometrics() async {
    try {
      final available = await getAvailableBiometrics();
      return available.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking enrolled biometrics: $e');
      return false;
    }
  }
  
  /// Enable biometric authentication
  Future<bool> enableBiometric() async {
    try {
      // Check if biometrics are available
      if (!await isAvailable()) {
        debugPrint('Biometric authentication not available');
        return false;
      }
      
      // Check if biometrics are enrolled
      if (!await hasEnrolledBiometrics()) {
        debugPrint('No biometrics enrolled on device');
        return false;
      }
      
      // Perform initial authentication to confirm setup
      final result = await authenticateWithBiometric(
        reason: 'Enable biometric authentication for secure access',
        requireConfirmation: true,
      );
      
      if (result == BiometricAuthResult.success) {
        await _secureStorage.write(
          key: _biometricEnabledKey,
          value: 'true',
        );
        await _secureStorage.write(
          key: _biometricSetupCompleteKey,
          value: 'true',
        );
        await _clearFailedAttempts();
        return true;
      }
      
      return false;
    } catch (e) {
      debugPrint('Error enabling biometric authentication: $e');
      return false;
    }
  }
  
  /// Disable biometric authentication
  Future<bool> disableBiometric() async {
    try {
      await _secureStorage.delete(key: _biometricEnabledKey);
      await _clearFailedAttempts();
      return true;
    } catch (e) {
      debugPrint('Error disabling biometric authentication: $e');
      return false;
    }
  }
  
  /// Check if biometric authentication is enabled
  Future<bool> isBiometricEnabled() async {
    try {
      final enabled = await _secureStorage.read(key: _biometricEnabledKey);
      return enabled == 'true';
    } catch (e) {
      debugPrint('Error checking biometric enabled status: $e');
      return false;
    }
  }
  
  /// Authenticate using biometrics
  Future<BiometricAuthResult> authenticateWithBiometric({
    required String reason,
    bool requireConfirmation = false,
    bool stickyAuth = true,
  }) async {
    try {
      // Check if biometric is enabled
      if (!await isBiometricEnabled()) {
        return BiometricAuthResult.notAvailable;
      }
      
      // Check failed attempts
      final failedAttempts = await _getFailedAttempts();
      if (failedAttempts >= _maxFailedAttempts) {
        return BiometricAuthResult.permanentlyLockedOut;
      }
      
      // Perform authentication
      final bool didAuthenticate = await _localAuth.authenticate(
        localizedFallbackTitle: 'Use device passcode',
        authMessages: const [
          AndroidAuthMessages(
            signInTitle: 'Biometric Authentication',
            cancelButton: 'Cancel',
            deviceCredentialsRequiredTitle: 'Device Credential Required',
            deviceCredentialsSetupDescription: 'Please set up device credentials',
            goToSettingsButton: 'Go to Settings',
            goToSettingsDescription: 'Please set up biometric authentication in settings',
          ),
          IOSAuthMessages(
            cancelButton: 'Cancel',
            goToSettingsButton: 'Settings',
            goToSettingsDescription: 'Please set up biometric authentication in settings',
            lockOut: 'Biometric authentication is locked. Please use device passcode.',
          ),
        ],
        options: AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: stickyAuth,
          sensitiveTransaction: requireConfirmation,
        ),
      );
      
      if (didAuthenticate) {
        await _clearFailedAttempts();
        return BiometricAuthResult.success;
      } else {
        await _incrementFailedAttempts();
        return BiometricAuthResult.failed;
      }
    } on PlatformException catch (e) {
      return _handlePlatformException(e);
    } catch (e) {
      debugPrint('Unexpected error during biometric authentication: $e');
      return BiometricAuthResult.unknown;
    }
  }
  
  /// Authenticate for sensitive operations
  Future<BiometricAuthResult> authenticateForSensitiveOperation({
    required String operation,
  }) async {
    return authenticateWithBiometric(
      reason: 'Authenticate to perform $operation',
      requireConfirmation: true,
      stickyAuth: true,
    );
  }
  
  /// Get failed authentication attempts
  Future<int> getFailedAttempts() async {
    return await _getFailedAttempts();
  }
  
  /// Check if biometric authentication is locked out
  Future<bool> isLockedOut() async {
    final failedAttempts = await _getFailedAttempts();
    return failedAttempts >= _maxFailedAttempts;
  }
  
  /// Clear lockout (admin only)
  Future<void> clearLockout() async {
    await _clearFailedAttempts();
  }
  
  /// Get biometric authentication status summary
  Future<Map<String, dynamic>> getStatus() async {
    final isAvailable = await this.isAvailable();
    final hasEnrolled = await hasEnrolledBiometrics();
    final isEnabled = await isBiometricEnabled();
    final failedAttempts = await _getFailedAttempts();
    final isLockedOut = failedAttempts >= _maxFailedAttempts;
    final availableTypes = await getAvailableBiometrics();
    
    return {
      'available': isAvailable,
      'enrolled': hasEnrolled,
      'enabled': isEnabled,
      'locked_out': isLockedOut,
      'failed_attempts': failedAttempts,
      'max_attempts': _maxFailedAttempts,
      'available_types': availableTypes.map((type) => type.toString()).toList(),
    };
  }
  
  // Private helper methods
  
  Future<void> _checkBiometricSupport() async {
    final isAvailable = await this.isAvailable();
    final hasEnrolled = await hasEnrolledBiometrics();
    
    debugPrint('Biometric Support Status:');
    debugPrint('  Available: $isAvailable');
    debugPrint('  Enrolled: $hasEnrolled');
    
    if (isAvailable && hasEnrolled) {
      final types = await getAvailableBiometrics();
      debugPrint('  Available types: ${types.map((t) => t.toString()).join(', ')}');
    }
  }
  
  Future<int> _getFailedAttempts() async {
    try {
      final attempts = await _secureStorage.read(key: _failedAttemptsKey);
      return int.tryParse(attempts ?? '0') ?? 0;
    } catch (e) {
      debugPrint('Error getting failed attempts: $e');
      return 0;
    }
  }
  
  Future<void> _incrementFailedAttempts() async {
    try {
      final currentAttempts = await _getFailedAttempts();
      await _secureStorage.write(
        key: _failedAttemptsKey,
        value: (currentAttempts + 1).toString(),
      );
    } catch (e) {
      debugPrint('Error incrementing failed attempts: $e');
    }
  }
  
  Future<void> _clearFailedAttempts() async {
    try {
      await _secureStorage.delete(key: _failedAttemptsKey);
    } catch (e) {
      debugPrint('Error clearing failed attempts: $e');
    }
  }
  
  BiometricAuthResult _handlePlatformException(PlatformException e) {
    debugPrint('Biometric authentication platform exception: ${e.code} - ${e.message}');
    
    switch (e.code) {
      case auth_error.notAvailable:
        return BiometricAuthResult.notAvailable;
      case auth_error.notEnrolled:
        return BiometricAuthResult.notEnrolled;
      case auth_error.lockedOut:
      case auth_error.permanentlyLockedOut:
        return BiometricAuthResult.permanentlyLockedOut;
      case auth_error.biometricOnlyNotSupported:
        return BiometricAuthResult.notAvailable;
      case auth_error.passcodeNotSet:
        return BiometricAuthResult.notEnrolled;
      case auth_error.otherOperatingSystem:
        return BiometricAuthResult.notAvailable;
      default:
        if (e.code.contains('UserCancel') || e.code.contains('UserFallback')) {
          return BiometricAuthResult.cancelled;
        }
        return BiometricAuthResult.failed;
    }
  }
}