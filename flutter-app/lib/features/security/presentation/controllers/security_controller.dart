import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/models/security_state.dart';
import '../domain/models/security_event.dart';
import '../domain/models/privacy_settings.dart';
import '../data/services/data_encryption_service.dart';
import '../data/services/biometric_authentication_service.dart';
import '../data/services/app_integrity_verification.dart';
import '../data/services/privacy_protection_manager.dart';
import '../data/services/security_monitoring_service.dart';
import '../../../core/di/service_locator.dart';

part 'security_controller.g.dart';

@riverpod
class SecurityController extends _$SecurityController {
  late final DataEncryptionService _encryptionService;
  late final BiometricAuthenticationService _biometricService;
  late final AppIntegrityVerification _integrityVerification;
  late final PrivacyProtectionManager _privacyManager;
  late final SecurityMonitoringService _monitoringService;

  @override
  SecurityState build() {
    _initializeServices();
    return const SecurityState();
  }

  void _initializeServices() {
    _encryptionService = ref.read(dataEncryptionServiceProvider);
    _biometricService = ref.read(biometricAuthenticationServiceProvider);
    _integrityVerification = ref.read(appIntegrityVerificationProvider);
    _privacyManager = ref.read(privacyProtectionManagerProvider);
    _monitoringService = ref.read(securityMonitoringServiceProvider);
  }

  /// Initialize security system
  Future<void> initialize() async {
    try {
      state = state.copyWith(isDeviceSecure: false);

      // Initialize all security services
      await Future.wait([
        _encryptionService.initialize(),
        _biometricService.initialize(),
        _integrityVerification.initialize(),
        _privacyManager.initialize(),
        _monitoringService.initialize(),
      ]);

      // Perform initial security checks
      await _performInitialSecurityCheck();

      // Load privacy settings
      final privacySettings = _privacyManager.getPrivacySettings();
      
      state = state.copyWith(
        privacySettings: privacySettings,
        lastSecurityCheck: DateTime.now(),
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to initialize security system: ${e.toString()}',
        isDeviceSecure: false,
      );
      rethrow;
    }
  }

  /// Enable biometric authentication
  Future<bool> enableBiometric() async {
    try {
      final result = await _biometricService.enableBiometric();
      
      if (result) {
        state = state.copyWith(
          isBiometricEnabled: true,
          error: null,
        );
        
        await _monitoringService.logSecurityEvent(
          SecurityEvent(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            type: SecurityEventType.loginAttempt,
            level: SecurityLevel.low,
            description: 'Biometric authentication enabled',
            timestamp: DateTime.now(),
          ),
        );
      }
      
      return result;
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to enable biometric authentication: ${e.toString()}',
      );
      return false;
    }
  }

  /// Disable biometric authentication
  Future<bool> disableBiometric() async {
    try {
      final result = await _biometricService.disableBiometric();
      
      if (result) {
        state = state.copyWith(
          isBiometricEnabled: false,
          error: null,
        );
        
        await _monitoringService.logSecurityEvent(
          SecurityEvent(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            type: SecurityEventType.loginAttempt,
            level: SecurityLevel.low,
            description: 'Biometric authentication disabled',
            timestamp: DateTime.now(),
          ),
        );
      }
      
      return result;
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to disable biometric authentication: ${e.toString()}',
      );
      return false;
    }
  }

  /// Authenticate with biometric
  Future<BiometricAuthResult> authenticateWithBiometric({
    required String reason,
  }) async {
    try {
      final result = await _biometricService.authenticateWithBiometric(
        reason: reason,
      );

      // Update failed attempts count
      if (result == BiometricAuthResult.failed) {
        final failedAttempts = state.failedAuthAttempts + 1;
        state = state.copyWith(
          failedAuthAttempts: failedAttempts,
          lastFailedAuth: DateTime.now(),
        );

        // Log failed authentication
        await _monitoringService.logSecurityEvent(
          SecurityEvent(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            type: SecurityEventType.authFailure,
            level: SecurityLevel.medium,
            description: 'Biometric authentication failed (attempt $failedAttempts)',
            timestamp: DateTime.now(),
          ),
        );
      } else if (result == BiometricAuthResult.success) {
        state = state.copyWith(
          failedAuthAttempts: 0,
          lastFailedAuth: null,
          error: null,
        );

        // Log successful authentication
        await _monitoringService.logSecurityEvent(
          SecurityEvent(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            type: SecurityEventType.loginAttempt,
            level: SecurityLevel.low,
            description: 'Biometric authentication successful',
            timestamp: DateTime.now(),
          ),
        );
      }

      return result;
    } catch (e) {
      state = state.copyWith(
        error: 'Biometric authentication error: ${e.toString()}',
      );
      return BiometricAuthResult.unknown;
    }
  }

  /// Perform security check
  Future<void> performSecurityCheck() async {
    try {
      state = state.copyWith(lastSecurityCheck: DateTime.now());

      // Perform integrity check
      final integrityResult = await _integrityVerification.performIntegrityCheck();
      
      final isDeviceSecure = integrityResult.status == IntegrityStatus.secure;
      final isRootDetected = integrityResult.checks['root_jailbreak']?.passed == false;
      final isDebugMode = integrityResult.checks['debug_mode']?.passed == false;
      final isTampered = integrityResult.checks['app_signature']?.passed == false;

      state = state.copyWith(
        isDeviceSecure: isDeviceSecure,
        isRootDetected: isRootDetected,
        isDebugMode: isDebugMode,
        isTampered: isTampered,
        currentLevel: _mapThreatLevelToSecurityLevel(integrityResult.threatLevel),
      );

      // Update recent events with integrity check result
      if (!isDeviceSecure) {
        await _monitoringService.logSecurityEvent(
          SecurityEvent(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            type: SecurityEventType.integrityBreach,
            level: _mapThreatLevelToSecurityLevel(integrityResult.threatLevel),
            description: 'Device integrity compromised: ${integrityResult.threatLevel}',
            timestamp: DateTime.now(),
            metadata: {
              'integrity_status': integrityResult.status.toString(),
              'threat_level': integrityResult.threatLevel.toString(),
            },
          ),
        );
      }

      // Load recent events
      await _loadRecentSecurityEvents();
    } catch (e) {
      state = state.copyWith(
        error: 'Security check failed: ${e.toString()}',
        isDeviceSecure: false,
      );
    }
  }

  /// Update privacy settings
  Future<bool> updatePrivacySettings(PrivacySettings settings) async {
    try {
      final result = await _privacyManager.updatePrivacySettings(settings);
      
      if (result) {
        state = state.copyWith(
          privacySettings: settings,
          error: null,
        );

        await _monitoringService.logSecurityEvent(
          SecurityEvent(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            type: SecurityEventType.dataAccess,
            level: SecurityLevel.low,
            description: 'Privacy settings updated',
            timestamp: DateTime.now(),
          ),
        );
      }
      
      return result;
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to update privacy settings: ${e.toString()}',
      );
      return false;
    }
  }

  /// Request consent for data processing
  Future<bool> requestConsent({
    required ConsentType type,
    required String purpose,
    required String description,
    bool required = false,
  }) async {
    try {
      final granted = await _privacyManager.requestConsent(
        type: type,
        purpose: purpose,
        description: description,
        required: required,
      );

      // Reload privacy settings to reflect consent
      final updatedSettings = _privacyManager.getPrivacySettings();
      state = state.copyWith(privacySettings: updatedSettings);

      return granted;
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to request consent: ${e.toString()}',
      );
      return false;
    }
  }

  /// Withdraw consent
  Future<bool> withdrawConsent(ConsentType type) async {
    try {
      final result = await _privacyManager.withdrawConsent(type);
      
      if (result) {
        // Reload privacy settings
        final updatedSettings = _privacyManager.getPrivacySettings();
        state = state.copyWith(privacySettings: updatedSettings);
      }
      
      return result;
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to withdraw consent: ${e.toString()}',
      );
      return false;
    }
  }

  /// Exercise data subject rights (GDPR)
  Future<DataSubjectRightResponse> exerciseDataSubjectRight({
    required DataSubjectRight right,
    String? specificData,
  }) async {
    try {
      final response = await _privacyManager.exerciseDataSubjectRight(
        right: right,
        specificData: specificData,
      );

      await _monitoringService.logSecurityEvent(
        SecurityEvent(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          type: SecurityEventType.dataAccess,
          level: SecurityLevel.medium,
          description: 'Data subject right exercised: ${right.toString()}',
          timestamp: DateTime.now(),
          metadata: {
            'right_type': right.toString(),
            'success': response.success,
          },
        ),
      );

      return response;
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to exercise data subject right: ${e.toString()}',
      );
      return DataSubjectRightResponse(
        success: false,
        message: 'Error: ${e.toString()}',
        timestamp: DateTime.now(),
      );
    }
  }

  /// Get security dashboard data
  Future<Map<String, dynamic>> getSecurityDashboard() async {
    try {
      return await _monitoringService.getSecurityDashboard();
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to load security dashboard: ${e.toString()}',
      );
      return {'error': e.toString()};
    }
  }

  /// Get security events
  List<SecurityEvent> getSecurityEvents({
    SecurityEventType? type,
    SecurityLevel? level,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) {
    return _monitoringService.getSecurityEvents(
      type: type,
      level: level,
      startDate: startDate,
      endDate: endDate,
      limit: limit,
    );
  }

  /// Get biometric authentication status
  Future<Map<String, dynamic>> getBiometricStatus() async {
    try {
      return await _biometricService.getStatus();
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  /// Get privacy transparency report
  Future<Map<String, dynamic>> getTransparencyReport() async {
    try {
      return await _privacyManager.getTransparencyReport();
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to generate transparency report: ${e.toString()}',
      );
      return {'error': e.toString()};
    }
  }

  /// Check if consent is valid for specific processing
  bool hasValidConsent(ConsentType type) {
    return _privacyManager.hasValidConsent(type);
  }

  /// Clear error state
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Reset failed authentication attempts
  Future<void> resetFailedAttempts() async {
    try {
      await _biometricService.clearLockout();
      state = state.copyWith(
        failedAuthAttempts: 0,
        lastFailedAuth: null,
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to reset failed attempts: ${e.toString()}',
      );
    }
  }

  // Private helper methods

  Future<void> _performInitialSecurityCheck() async {
    // Check biometric status
    final isBiometricEnabled = await _biometricService.isBiometricEnabled();
    
    // Perform integrity check
    await performSecurityCheck();
    
    state = state.copyWith(isBiometricEnabled: isBiometricEnabled);
  }

  Future<void> _loadRecentSecurityEvents() async {
    try {
      final recentEvents = _monitoringService.getSecurityEvents(
        startDate: DateTime.now().subtract(const Duration(hours: 24)),
        limit: 10,
      );
      
      state = state.copyWith(recentEvents: recentEvents);
    } catch (e) {
      // Don't update error state for this non-critical operation
      debugPrint('Failed to load recent security events: $e');
    }
  }

  SecurityLevel _mapThreatLevelToSecurityLevel(SecurityThreatLevel threatLevel) {
    switch (threatLevel) {
      case SecurityThreatLevel.none:
        return SecurityLevel.low;
      case SecurityThreatLevel.low:
        return SecurityLevel.low;
      case SecurityThreatLevel.medium:
        return SecurityLevel.medium;
      case SecurityThreatLevel.high:
        return SecurityLevel.high;
      case SecurityThreatLevel.critical:
        return SecurityLevel.critical;
      case SecurityThreatLevel.unknown:
      default:
        return SecurityLevel.medium;
    }
  }
}