import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/privacy_settings.dart';
import '../../../../core/enums/privacy_enums.dart';

class PrivacyProtectionManager {
  static const String _privacySettingsKey = 'privacy_settings';
  static const String _consentHistoryKey = 'consent_history';
  
  PrivacyProtectionManager(); // 매개변수 없는 생성자 추가
  
  Future<PrivacySettings> getPrivacySettings() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_privacySettingsKey);
    
    if (json != null) {
      return PrivacySettings.fromJson(Map<String, dynamic>.from(jsonDecode(json)));
    }
    
    return const PrivacySettings();
  }
  
  Future<void> updatePrivacySettings(PrivacySettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_privacySettingsKey, jsonEncode(settings.toJson()));
  }
  
  Future<void> updateConsent(ConsentType type, bool granted) async {
    final settings = await getPrivacySettings();
    final consents = Map<ConsentType, bool>.from(settings.consents ?? {});
    consents[type] = granted;
    
    final updatedSettings = settings.copyWith(
      consents: consents,
      lastUpdated: DateTime.now(),
    );
    
    await updatePrivacySettings(updatedSettings);
    await _recordConsentHistory(type, granted);
  }
  
  Future<void> _recordConsentHistory(ConsentType type, bool granted) async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList(_consentHistoryKey) ?? [];
    
    final entry = jsonEncode({
      'type': type.toString(),
      'granted': granted,
      'timestamp': DateTime.now().toIso8601String(),
    });
    
    history.add(entry);
    await prefs.setStringList(_consentHistoryKey, history);
  }
  
  Future<List<Map<String, dynamic>>> getConsentHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList(_consentHistoryKey) ?? [];
    
    return history.map((entry) {
      return Map<String, dynamic>.from(jsonDecode(entry));
    }).toList();
  }
  
  Future<DataSubjectRightResponse> exerciseDataSubjectRight({
    required DataSubjectRight right,
    required String userId,
  }) async {
    // Simulate exercising data subject rights
    await Future.delayed(const Duration(seconds: 2));
    
    return DataSubjectRightResponse(
      right: right,
      granted: true,
      timestamp: DateTime.now(),
      reference: 'DSR-${DateTime.now().millisecondsSinceEpoch}',
      details: 'Your request has been processed successfully',
    );
  }
  
  Future<void> clearAllPrivacyData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_privacySettingsKey);
    await prefs.remove(_consentHistoryKey);
  }
}