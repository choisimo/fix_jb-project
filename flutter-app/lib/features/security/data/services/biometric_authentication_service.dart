import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import '../../domain/models/security_event.dart';

class BiometricAuthenticationService {
  final LocalAuthentication _localAuth = LocalAuthentication();
  
  BiometricAuthenticationService(); // 매개변수 없는 생성자 추가
  
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
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      return isDeviceSupported && canCheckBiometrics;
    } catch (e) {
      debugPrint('Error checking biometric availability: $e');
      return false;
    }
  }
  
  /// Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      debugPrint('Error getting available biometrics: $e');
      return [];
    }
  }
  
  /// Authenticate using biometrics
  Future<BiometricAuthResult> authenticate({
    String reason = 'Please authenticate to access this feature',
  }) async {
    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
      
      return BiometricAuthResult(
        success: authenticated,
        message: authenticated ? 'Authentication successful' : 'Authentication failed',
        timestamp: DateTime.now(),
      );
    } catch (e) {
      return BiometricAuthResult(
        success: false,
        message: 'Authentication error: ${e.toString()}',
        errorCode: 'AUTH_ERROR',
        timestamp: DateTime.now(),
      );
    }
  }
  
  Future<void> stopAuthentication() async {
    await _localAuth.stopAuthentication();
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
}