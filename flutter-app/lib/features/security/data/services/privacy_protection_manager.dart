import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../domain/models/privacy_settings.dart';
import '../domain/models/secure_data.dart';
import 'data_encryption_service.dart';

enum ConsentType {
  dataCollection,
  locationTracking,
  analytics,
  marketing,
  personalization,
  thirdPartySharing,
  cookies,
  biometrics,
}

enum DataSubjectRight {
  access,        // Article 15 GDPR
  rectification, // Article 16 GDPR  
  erasure,       // Article 17 GDPR (Right to be forgotten)
  restriction,   // Article 18 GDPR
  portability,   // Article 20 GDPR
  objection,     // Article 21 GDPR
}

class PrivacyProtectionManager {
  static const String _privacySettingsKey = 'privacy_settings_encrypted';
  static const String _consentHistoryKey = 'consent_history_encrypted';
  static const String _dataProcessingLogKey = 'data_processing_log';
  static const String _privacyPolicyVersionKey = 'privacy_policy_version';
  
  final FlutterSecureStorage _secureStorage;
  final DataEncryptionService _encryptionService;
  
  PrivacySettings? _currentSettings;
  List<ConsentRecord> _consentHistory = [];
  
  PrivacyProtectionManager(this._secureStorage, this._encryptionService);
  
  /// Initialize privacy protection manager
  Future<void> initialize() async {
    try {
      await _loadPrivacySettings();
      await _loadConsentHistory();
      await _checkPrivacyPolicyUpdates();
      debugPrint('Privacy protection manager initialized');
    } catch (e) {
      debugPrint('Failed to initialize privacy protection manager: $e');
      rethrow;
    }
  }
  
  /// Request user consent for specific data processing
  Future<bool> requestConsent({
    required ConsentType type,
    required String purpose,
    required String description,
    bool required = false,
  }) async {
    try {
      final consent = ConsentRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: type,
        purpose: purpose,
        description: description,
        granted: false, // Will be updated based on user response
        timestamp: DateTime.now(),
        required: required,
        ipAddress: await _getCurrentIpAddress(),
        userAgent: await _getUserAgent(),
      );
      
      // In a real implementation, this would show a consent dialog
      // For now, we'll simulate user consent based on current settings
      final granted = await _simulateUserConsent(type);
      
      final updatedConsent = consent.copyWith(granted: granted);
      _consentHistory.add(updatedConsent);
      await _saveConsentHistory();
      
      // Update privacy settings based on consent
      await _updateSettingsFromConsent(type, granted);
      
      // Log the consent decision
      await _logDataProcessing(
        'consent_request',
        {
          'type': type.toString(),
          'purpose': purpose,
          'granted': granted,
          'required': required,
        },
      );
      
      return granted;
    } catch (e) {
      debugPrint('Error requesting consent: $e');
      return false;
    }
  }
  
  /// Withdraw consent for specific data processing
  Future<bool> withdrawConsent(ConsentType type) async {
    try {
      final withdrawal = ConsentRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: type,
        purpose: 'consent_withdrawal',
        description: 'User withdrew consent for ${type.toString()}',
        granted: false,
        timestamp: DateTime.now(),
        required: false,
        ipAddress: await _getCurrentIpAddress(),
        userAgent: await _getUserAgent(),
      );
      
      _consentHistory.add(withdrawal);
      await _saveConsentHistory();
      
      // Update privacy settings
      await _updateSettingsFromConsent(type, false);
      
      await _logDataProcessing(
        'consent_withdrawal',
        {
          'type': type.toString(),
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      
      return true;
    } catch (e) {
      debugPrint('Error withdrawing consent: $e');
      return false;
    }
  }
  
  /// Get current privacy settings
  PrivacySettings? getPrivacySettings() {
    return _currentSettings;
  }
  
  /// Update privacy settings
  Future<bool> updatePrivacySettings(PrivacySettings settings) async {
    try {
      _currentSettings = settings.copyWith(lastUpdated: DateTime.now());
      await _savePrivacySettings();
      
      await _logDataProcessing(
        'privacy_settings_update',
        {
          'settings': _currentSettings!.toJson(),
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      
      return true;
    } catch (e) {
      debugPrint('Error updating privacy settings: $e');
      return false;
    }
  }
  
  /// Exercise data subject rights (GDPR)
  Future<DataSubjectRightResponse> exerciseDataSubjectRight({
    required DataSubjectRight right,
    String? specificData,
  }) async {
    try {
      switch (right) {
        case DataSubjectRight.access:
          return await _handleAccessRequest();
        case DataSubjectRight.rectification:
          return await _handleRectificationRequest(specificData);
        case DataSubjectRight.erasure:
          return await _handleErasureRequest();
        case DataSubjectRight.restriction:
          return await _handleRestrictionRequest();
        case DataSubjectRight.portability:
          return await _handlePortabilityRequest();
        case DataSubjectRight.objection:
          return await _handleObjectionRequest();
      }
    } catch (e) {
      debugPrint('Error exercising data subject right: $e');
      return DataSubjectRightResponse(
        success: false,
        message: 'Failed to process request: ${e.toString()}',
        timestamp: DateTime.now(),
      );
    }
  }
  
  /// Get data processing transparency report
  Future<Map<String, dynamic>> getTransparencyReport() async {
    try {
      final consentSummary = _getConsentSummary();
      final dataCategories = await _getDataCategoriesCollected();
      final thirdParties = await _getThirdPartySharing();
      final retentionPeriods = await _getDataRetentionPeriods();
      
      return {
        'user_consent': consentSummary,
        'data_categories': dataCategories,
        'third_party_sharing': thirdParties,
        'retention_periods': retentionPeriods,
        'legal_basis': _getLegalBasisForProcessing(),
        'privacy_policy_version': await _getPrivacyPolicyVersion(),
        'last_updated': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      debugPrint('Error generating transparency report: $e');
      return {'error': e.toString()};
    }
  }
  
  /// Check if consent is valid for specific processing
  bool hasValidConsent(ConsentType type) {
    if (_currentSettings == null) return false;
    
    switch (type) {
      case ConsentType.dataCollection:
        return _currentSettings!.allowDataCollection;
      case ConsentType.locationTracking:
        return _currentSettings!.allowLocationTracking;
      case ConsentType.analytics:
        return _currentSettings!.allowAnalytics;
      case ConsentType.marketing:
        return _currentSettings!.allowMarketing;
      case ConsentType.personalization:
        return _currentSettings!.allowPersonalization;
      case ConsentType.thirdPartySharing:
        return _currentSettings!.allowThirdPartySharing;
      default:
        return false;
    }
  }
  
  /// Anonymize user data
  Future<Map<String, dynamic>> anonymizeData(Map<String, dynamic> data) async {
    try {
      final anonymized = Map<String, dynamic>.from(data);
      
      // Remove direct identifiers
      final identifiers = ['email', 'phone', 'name', 'address', 'ssn', 'id'];
      for (final identifier in identifiers) {
        anonymized.remove(identifier);
      }
      
      // Hash indirect identifiers
      final indirectIdentifiers = ['device_id', 'user_id', 'session_id'];
      for (final identifier in indirectIdentifiers) {
        if (anonymized.containsKey(identifier)) {
          anonymized[identifier] = _hashValue(anonymized[identifier].toString());
        }
      }
      
      // Generalize location data
      if (anonymized.containsKey('location')) {
        anonymized['location'] = _generalizeLocation(anonymized['location']);
      }
      
      // Remove timestamps precision (round to hour)
      if (anonymized.containsKey('timestamp')) {
        final timestamp = DateTime.parse(anonymized['timestamp']);
        final rounded = DateTime(timestamp.year, timestamp.month, timestamp.day, timestamp.hour);
        anonymized['timestamp'] = rounded.toIso8601String();
      }
      
      await _logDataProcessing(
        'data_anonymization',
        {
          'original_fields': data.keys.toList(),
          'anonymized_fields': anonymized.keys.toList(),
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      
      return anonymized;
    } catch (e) {
      debugPrint('Error anonymizing data: $e');
      rethrow;
    }
  }
  
  /// Get consent history
  List<ConsentRecord> getConsentHistory() {
    return List.unmodifiable(_consentHistory);
  }
  
  /// Check if privacy policy needs user acknowledgment
  Future<bool> needsPrivacyPolicyAcknowledgment() async {
    try {
      final currentVersion = await _getPrivacyPolicyVersion();
      final acknowledgedVersion = await _secureStorage.read(key: 'acknowledged_privacy_policy_version');
      
      return currentVersion != acknowledgedVersion;
    } catch (e) {
      debugPrint('Error checking privacy policy acknowledgment: $e');
      return true; // Default to requiring acknowledgment
    }
  }
  
  /// Acknowledge privacy policy
  Future<void> acknowledgePrivacyPolicy(String version) async {
    try {
      await _secureStorage.write(key: 'acknowledged_privacy_policy_version', value: version);
      
      await _logDataProcessing(
        'privacy_policy_acknowledgment',
        {
          'version': version,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      debugPrint('Error acknowledging privacy policy: $e');
    }
  }
  
  // Private helper methods
  
  Future<void> _loadPrivacySettings() async {
    try {
      final encryptedData = await _secureStorage.read(key: _privacySettingsKey);
      if (encryptedData != null) {
        final secureData = SecureData.fromJson(jsonDecode(encryptedData));
        final decryptedJson = await _encryptionService.decryptData(secureData);
        final settingsMap = jsonDecode(decryptedJson) as Map<String, dynamic>;
        _currentSettings = PrivacySettings.fromJson(settingsMap);
      } else {
        // Create default privacy settings
        _currentSettings = const PrivacySettings();
        await _savePrivacySettings();
      }
    } catch (e) {
      debugPrint('Error loading privacy settings: $e');
      _currentSettings = const PrivacySettings();
    }
  }
  
  Future<void> _savePrivacySettings() async {
    try {
      if (_currentSettings != null) {
        final jsonString = jsonEncode(_currentSettings!.toJson());
        final secureData = await _encryptionService.encryptData(jsonString);
        final encryptedJson = jsonEncode(secureData.toJson());
        await _secureStorage.write(key: _privacySettingsKey, value: encryptedJson);
      }
    } catch (e) {
      debugPrint('Error saving privacy settings: $e');
    }
  }
  
  Future<void> _loadConsentHistory() async {
    try {
      final encryptedData = await _secureStorage.read(key: _consentHistoryKey);
      if (encryptedData != null) {
        final secureData = SecureData.fromJson(jsonDecode(encryptedData));
        final decryptedJson = await _encryptionService.decryptData(secureData);
        final historyList = jsonDecode(decryptedJson) as List<dynamic>;
        _consentHistory = historyList
            .map((item) => ConsentRecord.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('Error loading consent history: $e');
      _consentHistory = [];
    }
  }
  
  Future<void> _saveConsentHistory() async {
    try {
      final historyJson = _consentHistory.map((record) => record.toJson()).toList();
      final jsonString = jsonEncode(historyJson);
      final secureData = await _encryptionService.encryptData(jsonString);
      final encryptedJson = jsonEncode(secureData.toJson());
      await _secureStorage.write(key: _consentHistoryKey, value: encryptedJson);
    } catch (e) {
      debugPrint('Error saving consent history: $e');
    }
  }
  
  Future<bool> _simulateUserConsent(ConsentType type) async {
    // In a real implementation, this would show a dialog to the user
    // For now, we'll use default consent based on type
    switch (type) {
      case ConsentType.dataCollection:
      case ConsentType.analytics:
        return true; // Essential for app function
      case ConsentType.locationTracking:
      case ConsentType.personalization:
        return true; // Useful features
      case ConsentType.marketing:
      case ConsentType.thirdPartySharing:
        return false; // Non-essential, default to false
      default:
        return false;
    }
  }
  
  Future<void> _updateSettingsFromConsent(ConsentType type, bool granted) async {
    if (_currentSettings == null) return;
    
    PrivacySettings updatedSettings;
    
    switch (type) {
      case ConsentType.dataCollection:
        updatedSettings = _currentSettings!.copyWith(allowDataCollection: granted);
        break;
      case ConsentType.locationTracking:
        updatedSettings = _currentSettings!.copyWith(allowLocationTracking: granted);
        break;
      case ConsentType.analytics:
        updatedSettings = _currentSettings!.copyWith(allowAnalytics: granted);
        break;
      case ConsentType.marketing:
        updatedSettings = _currentSettings!.copyWith(allowMarketing: granted);
        break;
      case ConsentType.personalization:
        updatedSettings = _currentSettings!.copyWith(allowPersonalization: granted);
        break;
      case ConsentType.thirdPartySharing:
        updatedSettings = _currentSettings!.copyWith(allowThirdPartySharing: granted);
        break;
      default:
        return;
    }
    
    _currentSettings = updatedSettings;
    await _savePrivacySettings();
  }
  
  Future<DataSubjectRightResponse> _handleAccessRequest() async {
    // Compile all user data
    final userData = {
      'privacy_settings': _currentSettings?.toJson(),
      'consent_history': _consentHistory.map((c) => c.toJson()).toList(),
      'data_processing_log': await _getDataProcessingLog(),
    };
    
    return DataSubjectRightResponse(
      success: true,
      message: 'Data access request completed',
      data: userData,
      timestamp: DateTime.now(),
    );
  }
  
  Future<DataSubjectRightResponse> _handleErasureRequest() async {
    // Delete all user data
    await _secureStorage.delete(key: _privacySettingsKey);
    await _secureStorage.delete(key: _consentHistoryKey);
    await _secureStorage.delete(key: _dataProcessingLogKey);
    
    _currentSettings = const PrivacySettings();
    _consentHistory = [];
    
    return DataSubjectRightResponse(
      success: true,
      message: 'All user data has been erased',
      timestamp: DateTime.now(),
    );
  }
  
  Future<DataSubjectRightResponse> _handleRectificationRequest(String? specificData) async {
    // In a real implementation, this would allow users to correct their data
    return DataSubjectRightResponse(
      success: true,
      message: 'Data rectification request received. Please contact support for manual processing.',
      timestamp: DateTime.now(),
    );
  }
  
  Future<DataSubjectRightResponse> _handleRestrictionRequest() async {
    // Restrict data processing
    if (_currentSettings != null) {
      final restrictedSettings = _currentSettings!.copyWith(
        allowDataCollection: false,
        allowLocationTracking: false,
        allowAnalytics: false,
        allowMarketing: false,
        allowPersonalization: false,
        allowThirdPartySharing: false,
      );
      await updatePrivacySettings(restrictedSettings);
    }
    
    return DataSubjectRightResponse(
      success: true,
      message: 'Data processing has been restricted',
      timestamp: DateTime.now(),
    );
  }
  
  Future<DataSubjectRightResponse> _handlePortabilityRequest() async {
    // Export user data in portable format
    final userData = await _handleAccessRequest();
    
    return DataSubjectRightResponse(
      success: true,
      message: 'Data portability request completed. Data is provided in JSON format.',
      data: userData.data,
      timestamp: DateTime.now(),
    );
  }
  
  Future<DataSubjectRightResponse> _handleObjectionRequest() async {
    // Handle objection to data processing
    await _handleRestrictionRequest(); // Similar to restriction
    
    return DataSubjectRightResponse(
      success: true,
      message: 'Objection to data processing has been processed',
      timestamp: DateTime.now(),
    );
  }
  
  Map<String, dynamic> _getConsentSummary() {
    final summary = <String, dynamic>{};
    
    for (final type in ConsentType.values) {
      final consents = _consentHistory.where((c) => c.type == type).toList();
      final latestConsent = consents.isNotEmpty ? consents.last : null;
      
      summary[type.toString()] = {
        'granted': latestConsent?.granted ?? false,
        'timestamp': latestConsent?.timestamp.toIso8601String(),
        'total_requests': consents.length,
      };
    }
    
    return summary;
  }
  
  String _hashValue(String value) {
    // Simple hash for anonymization (in production, use a proper hashing algorithm)
    return value.hashCode.abs().toString();
  }
  
  Map<String, dynamic> _generalizeLocation(dynamic location) {
    // Generalize location to city level instead of exact coordinates
    if (location is Map<String, dynamic>) {
      return {
        'country': location['country'] ?? 'Unknown',
        'state': location['state'] ?? 'Unknown',
        'city': location['city'] ?? 'Unknown',
        // Remove exact coordinates
      };
    }
    return {'generalized': true};
  }
  
  Future<void> _logDataProcessing(String action, Map<String, dynamic> details) async {
    try {
      final log = {
        'action': action,
        'details': details,
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      // In a real implementation, this would be sent to a secure logging service
      debugPrint('Data processing log: ${jsonEncode(log)}');
    } catch (e) {
      debugPrint('Error logging data processing: $e');
    }
  }
  
  Future<String> _getCurrentIpAddress() async {
    // In a real implementation, this would get the actual IP address
    return '127.0.0.1';
  }
  
  Future<String> _getUserAgent() async {
    // In a real implementation, this would get the actual user agent
    return 'JB Report App 1.0.0';
  }
  
  Future<void> _checkPrivacyPolicyUpdates() async {
    // Check if privacy policy has been updated
    // In a real implementation, this would check against a server
  }
  
  Future<String> _getPrivacyPolicyVersion() async {
    return await _secureStorage.read(key: _privacyPolicyVersionKey) ?? '1.0.0';
  }
  
  Future<Map<String, dynamic>> _getDataCategoriesCollected() async {
    return {
      'personal_identifiers': ['email', 'phone'],
      'location_data': ['gps_coordinates', 'address'],
      'technical_data': ['device_id', 'app_version'],
      'usage_data': ['app_interactions', 'feature_usage'],
    };
  }
  
  Future<Map<String, dynamic>> _getThirdPartySharing() async {
    return {
      'analytics_providers': ['Google Analytics'],
      'cloud_services': ['AWS', 'Firebase'],
      'payment_processors': [],
      'advertising_networks': [],
    };
  }
  
  Future<Map<String, dynamic>> _getDataRetentionPeriods() async {
    return {
      'user_account_data': '2 years after account deletion',
      'location_data': '1 year',
      'analytics_data': '2 years',
      'log_data': '6 months',
    };
  }
  
  List<String> _getLegalBasisForProcessing() {
    return [
      'Consent (GDPR Article 6.1.a)',
      'Contract performance (GDPR Article 6.1.b)',
      'Legal obligation (GDPR Article 6.1.c)',
      'Legitimate interest (GDPR Article 6.1.f)',
    ];
  }
  
  Future<List<Map<String, dynamic>>> _getDataProcessingLog() async {
    // In a real implementation, this would retrieve actual processing logs
    return [];
  }
}

// Supporting data classes

class ConsentRecord {
  final String id;
  final ConsentType type;
  final String purpose;
  final String description;
  final bool granted;
  final DateTime timestamp;
  final bool required;
  final String? ipAddress;
  final String? userAgent;
  
  ConsentRecord({
    required this.id,
    required this.type,
    required this.purpose,
    required this.description,
    required this.granted,
    required this.timestamp,
    required this.required,
    this.ipAddress,
    this.userAgent,
  });
  
  ConsentRecord copyWith({
    String? id,
    ConsentType? type,
    String? purpose,
    String? description,
    bool? granted,
    DateTime? timestamp,
    bool? required,
    String? ipAddress,
    String? userAgent,
  }) {
    return ConsentRecord(
      id: id ?? this.id,
      type: type ?? this.type,
      purpose: purpose ?? this.purpose,
      description: description ?? this.description,
      granted: granted ?? this.granted,
      timestamp: timestamp ?? this.timestamp,
      required: required ?? this.required,
      ipAddress: ipAddress ?? this.ipAddress,
      userAgent: userAgent ?? this.userAgent,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString(),
      'purpose': purpose,
      'description': description,
      'granted': granted,
      'timestamp': timestamp.toIso8601String(),
      'required': required,
      'ip_address': ipAddress,
      'user_agent': userAgent,
    };
  }
  
  factory ConsentRecord.fromJson(Map<String, dynamic> json) {
    return ConsentRecord(
      id: json['id'],
      type: ConsentType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => ConsentType.dataCollection,
      ),
      purpose: json['purpose'],
      description: json['description'],
      granted: json['granted'],
      timestamp: DateTime.parse(json['timestamp']),
      required: json['required'],
      ipAddress: json['ip_address'],
      userAgent: json['user_agent'],
    );
  }
}

class DataSubjectRightResponse {
  final bool success;
  final String message;
  final Map<String, dynamic>? data;
  final DateTime timestamp;
  
  DataSubjectRightResponse({
    required this.success,
    required this.message,
    this.data,
    required this.timestamp,
  });
}