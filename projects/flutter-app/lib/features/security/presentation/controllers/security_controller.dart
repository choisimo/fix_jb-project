import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/security_state.dart';
import '../../domain/models/security_event.dart' hide BiometricAuthResult; // BiometricAuthResult 충돌 해결
import '../../domain/models/privacy_settings.dart' hide DataSubjectRightResponse; // DataSubjectRightResponse 충돌 해결
import '../../../../core/enums/security_enums.dart';
import '../../../../core/enums/privacy_enums.dart';
import '../../data/services/data_encryption_service.dart';
import '../../data/services/biometric_authentication_service.dart';
import '../../data/services/app_integrity_verification.dart';
import '../../data/services/privacy_protection_manager.dart';
import '../../data/services/security_monitoring_service.dart';
import '../providers/security_providers.dart';
// BiometricAuthResult는 security_event.dart에서 가져옴
import '../../domain/models/security_event.dart' show BiometricAuthResult;
// DataSubjectRightResponse는 privacy_settings.dart에서 가져옴
import '../../domain/models/privacy_settings.dart' show DataSubjectRightResponse;

final securityControllerProvider = StateNotifierProvider<SecurityController, SecurityState>((ref) {
  final dataEncryption = ref.watch(dataEncryptionServiceProvider);
  final biometricAuth = ref.watch(biometricAuthenticationServiceProvider);
  final appIntegrity = ref.watch(appIntegrityVerificationProvider);
  final privacyManager = ref.watch(privacyProtectionManagerProvider);
  final monitoringService = ref.watch(securityMonitoringServiceProvider);
  
  return SecurityController(
    dataEncryption,
    biometricAuth,
    appIntegrity,
    privacyManager,
    monitoringService,
  );
});

class SecurityController extends StateNotifier<SecurityState> {
  final DataEncryptionService _dataEncryption;
  final BiometricAuthenticationService _biometricAuth;
  final AppIntegrityVerification _appIntegrity;
  final PrivacyProtectionManager _privacyManager;
  final SecurityMonitoringService _monitoringService;
  
  SecurityController(
    this._dataEncryption,
    this._biometricAuth,
    this._appIntegrity,
    this._privacyManager,
    this._monitoringService,
  ) : super(const SecurityState()) {
    _initialize();
  }
  
  Future<void> _initialize() async {
    await checkIntegrity();
    await _loadRecentEvents();
  }
  
  Future<void> _loadRecentEvents() async {
    final events = await _monitoringService.getRecentEvents(limit: 10);
    state = state.copyWith(recentEvents: events);
  }
  
  Future<void> checkIntegrity() async {
    final status = await _appIntegrity.verifyIntegrity();
    final threatLevel = _assessThreatLevel(status);
    
    state = state.copyWith(
      securityLevel: _mapThreatToSecurityLevel(threatLevel),
      threatLevel: threatLevel,
    );
    
    await _monitoringService.logEvent(
      SecurityEvent(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: SecurityEventType.dataAccess,
        level: SecurityLevel.normal,
        timestamp: DateTime.now(),
        description: 'Integrity check completed: $status',
      ),
    );
  }
  
  Future<BiometricAuthResult> authenticateWithBiometrics() async {
    final result = await _biometricAuth.authenticate();
    
    await _monitoringService.logEvent(
      SecurityEvent(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: SecurityEventType.biometricAuth,
        level: result.success ? SecurityLevel.normal : SecurityLevel.high,
        timestamp: DateTime.now(),
        description: result.message,
      ),
    );
    
    if (result.success) {
      state = state.copyWith(
        isAuthenticated: true,
        biometricEnabled: true,
      );
    }
    
    return result;
  }
  
  Future<String> encryptSensitiveData(String data) async {
    return await _dataEncryption.encryptData(data);
  }
  
  Future<String> decryptSensitiveData(String encryptedData) async {
    return await _dataEncryption.decryptData(encryptedData);
  }
  
  Future<PrivacySettings> getPrivacySettings() async {
    return await _privacyManager.getPrivacySettings();
  }
  
  Future<void> updatePrivacySettings(PrivacySettings settings) async {
    await _privacyManager.updatePrivacySettings(settings);
    
    await _monitoringService.logEvent(
      SecurityEvent(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: SecurityEventType.privacyUpdate,
        level: SecurityLevel.normal,
        timestamp: DateTime.now(),
        description: 'Privacy settings updated',
      ),
    );
  }
  
  Future<void> updateConsent(ConsentType type, bool granted) async {
    await _privacyManager.updateConsent(type, granted);
  }
  
  Future<DataSubjectRightResponse> exerciseDataSubjectRight(DataSubjectRight right) async {
    final response = await _privacyManager.exerciseDataSubjectRight(
      right: right,
      userId: 'current_user', // TODO: Get actual user ID
    );
    
    await _monitoringService.logEvent(
      SecurityEvent(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: SecurityEventType.dataAccess,
        level: SecurityLevel.high,
        timestamp: DateTime.now(),
        description: 'Data subject right exercised: ${right.name}',
      ),
    );
    
    return response;
  }
  
  SecurityThreatLevel _assessThreatLevel(IntegrityStatus status) {
    switch (status) {
      case IntegrityStatus.verified:
        return SecurityThreatLevel.none;
      case IntegrityStatus.checking:
        return SecurityThreatLevel.low;
      case IntegrityStatus.unverified:
        return SecurityThreatLevel.medium;
      case IntegrityStatus.compromised:
        return SecurityThreatLevel.critical;
    }
  }
  
  SecurityLevel _mapThreatToSecurityLevel(SecurityThreatLevel threat) {
    switch (threat) {
      case SecurityThreatLevel.none:
        return SecurityLevel.normal;
      case SecurityThreatLevel.low:
        return SecurityLevel.normal;
      case SecurityThreatLevel.medium:
        return SecurityLevel.high;
      case SecurityThreatLevel.high:
        return SecurityLevel.critical;
      case SecurityThreatLevel.critical:
        return SecurityLevel.critical;
    }
  }
  
  @override
  void dispose() {
    _monitoringService.dispose();
    super.dispose();
  }
}