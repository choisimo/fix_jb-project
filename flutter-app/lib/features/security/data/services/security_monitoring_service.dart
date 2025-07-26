import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../domain/models/security_event.dart';
import 'app_integrity_verification.dart';
import 'data_encryption_service.dart';

enum ThreatType {
  bruteForce,
  accountTakeover,
  dataExfiltration,
  apiAbuse,
  suspiciousActivity,
  malwareDetection,
  networkAnomaly,
  privilegeEscalation,
}

enum ResponseAction {
  log,
  alert,
  block,
  restrict,
  escalate,
  quarantine,
}

class SecurityMonitoringService {
  static const String _securityEventsKey = 'security_events_encrypted';
  static const String _threatConfigKey = 'threat_config';
  static const String _monitoringStateKey = 'monitoring_state';
  
  static const int _maxStoredEvents = 1000;
  static const Duration _alertCooldown = Duration(minutes: 5);
  static const Duration _monitoringInterval = Duration(seconds: 30);
  
  final FlutterSecureStorage _secureStorage;
  final DataEncryptionService _encryptionService;
  final AppIntegrityVerification _integrityVerification;
  
  List<SecurityEvent> _securityEvents = [];
  Map<String, ThreatDetectionRule> _threatRules = {};
  bool _isMonitoring = false;
  Timer? _monitoringTimer;
  DateTime? _lastAlertTime;
  
  // Behavior analysis variables
  final Map<String, List<DateTime>> _actionHistory = {};
  final Map<String, double> _riskScores = {};
  
  SecurityMonitoringService(
    this._secureStorage,
    this._encryptionService,
    this._integrityVerification,
  );
  
  /// Initialize security monitoring service
  Future<void> initialize() async {
    try {
      await _loadSecurityEvents();
      await _loadThreatConfiguration();
      await _setupDefaultThreatRules();
      await startMonitoring();
      
      debugPrint('Security monitoring service initialized');
    } catch (e) {
      debugPrint('Failed to initialize security monitoring: $e');
      rethrow;
    }
  }
  
  /// Start continuous security monitoring
  Future<void> startMonitoring() async {
    if (_isMonitoring) return;
    
    _isMonitoring = true;
    _monitoringTimer = Timer.periodic(_monitoringInterval, (_) async {
      await _performPeriodicCheck();
    });
    
    await _logSecurityEvent(
      SecurityEvent(
        id: _generateEventId(),
        type: SecurityEventType.dataAccess,
        level: SecurityLevel.low,
        description: 'Security monitoring started',
        timestamp: DateTime.now(),
      ),
    );
  }
  
  /// Stop security monitoring
  Future<void> stopMonitoring() async {
    _isMonitoring = false;
    _monitoringTimer?.cancel();
    _monitoringTimer = null;
    
    await _logSecurityEvent(
      SecurityEvent(
        id: _generateEventId(),
        type: SecurityEventType.dataAccess,
        level: SecurityLevel.low,
        description: 'Security monitoring stopped',
        timestamp: DateTime.now(),
      ),
    );
  }
  
  /// Log a security event
  Future<void> logSecurityEvent(SecurityEvent event) async {
    await _logSecurityEvent(event);
  }
  
  /// Detect and handle authentication anomalies
  Future<void> detectAuthenticationAnomaly({
    required String userId,
    required String action,
    String? deviceId,
    String? ipAddress,
  }) async {
    try {
      final now = DateTime.now();
      final actionKey = '${userId}_$action';
      
      // Track action history
      _actionHistory[actionKey] ??= [];
      _actionHistory[actionKey]!.add(now);
      
      // Remove old entries (older than 1 hour)
      _actionHistory[actionKey]!.removeWhere(
        (time) => now.difference(time) > const Duration(hours: 1),
      );
      
      // Check for brute force attacks
      await _checkBruteForceAttempt(userId, action, _actionHistory[actionKey]!);
      
      // Check for unusual time patterns
      await _checkUnusualTimePattern(userId, action, now);
      
      // Check for device/location anomalies
      await _checkDeviceLocationAnomaly(userId, deviceId, ipAddress);
      
      // Update risk score
      await _updateUserRiskScore(userId, action);
      
    } catch (e) {
      debugPrint('Error detecting authentication anomaly: $e');
    }
  }
  
  /// Detect API abuse patterns
  Future<void> detectApiAbuse({
    required String endpoint,
    required String userId,
    int? responseCode,
    Duration? responseTime,
  }) async {
    try {
      final now = DateTime.now();
      final apiKey = '${userId}_$endpoint';
      
      // Track API calls
      _actionHistory[apiKey] ??= [];
      _actionHistory[apiKey]!.add(now);
      
      // Remove old entries (older than 1 hour)
      _actionHistory[apiKey]!.removeWhere(
        (time) => now.difference(time) > const Duration(hours: 1),
      );
      
      // Check rate limiting
      if (_actionHistory[apiKey]!.length > 100) { // 100 calls per hour limit
        await _handleThreatDetection(
          ThreatType.apiAbuse,
          'API rate limit exceeded for endpoint $endpoint',
          SecurityLevel.high,
          {
            'user_id': userId,
            'endpoint': endpoint,
            'call_count': _actionHistory[apiKey]!.length,
          },
        );
      }
      
      // Check for error patterns
      if (responseCode != null && responseCode >= 400) {
        await _checkErrorPatterns(userId, endpoint, responseCode);
      }
      
    } catch (e) {
      debugPrint('Error detecting API abuse: $e');
    }
  }
  
  /// Detect suspicious user behavior
  Future<void> detectSuspiciousBehavior({
    required String userId,
    required String action,
    Map<String, dynamic>? context,
  }) async {
    try {
      // Analyze behavior patterns
      final riskScore = await _calculateBehaviorRiskScore(userId, action, context);
      
      if (riskScore > 0.8) { // High risk threshold
        await _handleThreatDetection(
          ThreatType.suspiciousActivity,
          'Suspicious behavior detected for user $userId',
          SecurityLevel.high,
          {
            'user_id': userId,
            'action': action,
            'risk_score': riskScore,
            'context': context,
          },
        );
      } else if (riskScore > 0.6) { // Medium risk threshold
        await _handleThreatDetection(
          ThreatType.suspiciousActivity,
          'Unusual behavior detected for user $userId',
          SecurityLevel.medium,
          {
            'user_id': userId,
            'action': action,
            'risk_score': riskScore,
            'context': context,
          },
        );
      }
      
    } catch (e) {
      debugPrint('Error detecting suspicious behavior: $e');
    }
  }
  
  /// Get security dashboard data
  Future<Map<String, dynamic>> getSecurityDashboard() async {
    try {
      final now = DateTime.now();
      final last24Hours = now.subtract(const Duration(hours: 24));
      final last7Days = now.subtract(const Duration(days: 7));
      
      final recentEvents = _securityEvents
          .where((event) => event.timestamp.isAfter(last24Hours))
          .toList();
      
      final weeklyEvents = _securityEvents
          .where((event) => event.timestamp.isAfter(last7Days))
          .toList();
      
      return {
        'monitoring_status': _isMonitoring ? 'active' : 'inactive',
        'total_events': _securityEvents.length,
        'events_24h': recentEvents.length,
        'events_7d': weeklyEvents.length,
        'threat_level': _calculateOverallThreatLevel(),
        'top_threats': _getTopThreats(recentEvents),
        'risk_users': _getHighRiskUsers(),
        'system_health': await _getSystemHealthStatus(),
        'last_integrity_check': await _getLastIntegrityCheck(),
      };
    } catch (e) {
      debugPrint('Error generating security dashboard: $e');
      return {'error': e.toString()};
    }
  }
  
  /// Get filtered security events
  List<SecurityEvent> getSecurityEvents({
    SecurityEventType? type,
    SecurityLevel? level,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) {
    var events = List<SecurityEvent>.from(_securityEvents);
    
    if (type != null) {
      events = events.where((e) => e.type == type).toList();
    }
    
    if (level != null) {
      events = events.where((e) => e.level == level).toList();
    }
    
    if (startDate != null) {
      events = events.where((e) => e.timestamp.isAfter(startDate)).toList();
    }
    
    if (endDate != null) {
      events = events.where((e) => e.timestamp.isBefore(endDate)).toList();
    }
    
    // Sort by timestamp (newest first)
    events.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    if (limit != null && events.length > limit) {
      events = events.take(limit).toList();
    }
    
    return events;
  }
  
  /// Update threat detection rules
  Future<void> updateThreatRule(String ruleId, ThreatDetectionRule rule) async {
    _threatRules[ruleId] = rule;
    await _saveThreatConfiguration();
  }
  
  /// Get current threat statistics
  Map<String, int> getThreatStatistics() {
    final stats = <String, int>{};
    
    for (final type in SecurityEventType.values) {
      stats[type.toString()] = _securityEvents
          .where((event) => event.type == type)
          .length;
    }
    
    return stats;
  }
  
  // Private helper methods
  
  Future<void> _performPeriodicCheck() async {
    try {
      // Perform integrity check
      final integrityResult = await _integrityVerification.performIntegrityCheck();
      
      if (integrityResult.status == IntegrityStatus.compromised) {
        await _handleThreatDetection(
          ThreatType.malwareDetection,
          'App integrity compromised: ${integrityResult.threatLevel}',
          SecurityLevel.critical,
          {
            'integrity_status': integrityResult.status.toString(),
            'threat_level': integrityResult.threatLevel.toString(),
            'failed_checks': integrityResult.checks.entries
                .where((entry) => !entry.value.passed)
                .map((entry) => entry.key)
                .toList(),
          },
        );
      }
      
      // Clean up old events
      await _cleanupOldEvents();
      
      // Update risk scores
      await _updateRiskScores();
      
    } catch (e) {
      debugPrint('Error in periodic security check: $e');
    }
  }
  
  Future<void> _logSecurityEvent(SecurityEvent event) async {
    try {
      _securityEvents.add(event);
      
      // Limit the number of stored events
      if (_securityEvents.length > _maxStoredEvents) {
        _securityEvents = _securityEvents
            .skip(_securityEvents.length - _maxStoredEvents)
            .toList();
      }
      
      await _saveSecurityEvents();
      
      // Handle the event based on its severity
      await _processSecurityEvent(event);
      
    } catch (e) {
      debugPrint('Error logging security event: $e');
    }
  }
  
  Future<void> _processSecurityEvent(SecurityEvent event) async {
    switch (event.level) {
      case SecurityLevel.critical:
        await _handleCriticalEvent(event);
        break;
      case SecurityLevel.high:
        await _handleHighEvent(event);
        break;
      case SecurityLevel.medium:
        await _handleMediumEvent(event);
        break;
      case SecurityLevel.low:
        // Just log, no action needed
        break;
    }
  }
  
  Future<void> _handleCriticalEvent(SecurityEvent event) async {
    // Immediate response for critical events
    await _sendSecurityAlert(event);
    
    // Auto-lockdown if configured
    if (_threatRules['auto_lockdown']?.enabled == true) {
      await _triggerEmergencyLockdown(event);
    }
  }
  
  Future<void> _handleHighEvent(SecurityEvent event) async {
    await _sendSecurityAlert(event);
    
    // Additional monitoring for high-risk events
    if (event.userId != null) {
      await _increaseUserMonitoring(event.userId!);
    }
  }
  
  Future<void> _handleMediumEvent(SecurityEvent event) async {
    // Send alert if not in cooldown period
    if (_shouldSendAlert()) {
      await _sendSecurityAlert(event);
    }
  }
  
  Future<void> _checkBruteForceAttempt(
    String userId,
    String action,
    List<DateTime> attempts,
  ) async {
    const maxAttempts = 5;
    const timeWindow = Duration(minutes: 15);
    
    final now = DateTime.now();
    final recentAttempts = attempts
        .where((time) => now.difference(time) < timeWindow)
        .length;
    
    if (recentAttempts >= maxAttempts) {
      await _handleThreatDetection(
        ThreatType.bruteForce,
        'Brute force attack detected for user $userId',
        SecurityLevel.high,
        {
          'user_id': userId,
          'action': action,
          'attempt_count': recentAttempts,
          'time_window': timeWindow.inMinutes,
        },
      );
    }
  }
  
  Future<void> _checkUnusualTimePattern(
    String userId,
    String action,
    DateTime timestamp,
  ) async {
    // Check if action occurs at unusual time (e.g., 3 AM)
    final hour = timestamp.hour;
    
    if (hour >= 2 && hour <= 5) { // 2 AM - 5 AM is unusual
      await _handleThreatDetection(
        ThreatType.suspiciousActivity,
        'Unusual time activity detected for user $userId',
        SecurityLevel.medium,
        {
          'user_id': userId,
          'action': action,
          'hour': hour,
          'timestamp': timestamp.toIso8601String(),
        },
      );
    }
  }
  
  Future<void> _checkDeviceLocationAnomaly(
    String userId,
    String? deviceId,
    String? ipAddress,
  ) async {
    // In a real implementation, this would check against known devices/locations
    // For now, we'll implement a simple check
    
    if (deviceId != null && !_isKnownDevice(userId, deviceId)) {
      await _handleThreatDetection(
        ThreatType.accountTakeover,
        'New device detected for user $userId',
        SecurityLevel.medium,
        {
          'user_id': userId,
          'device_id': deviceId,
          'ip_address': ipAddress,
        },
      );
    }
  }
  
  Future<void> _checkErrorPatterns(
    String userId,
    String endpoint,
    int responseCode,
  ) async {
    final errorKey = '${userId}_${endpoint}_error';
    
    _actionHistory[errorKey] ??= [];
    _actionHistory[errorKey]!.add(DateTime.now());
    
    // Remove old entries
    _actionHistory[errorKey]!.removeWhere(
      (time) => DateTime.now().difference(time) > const Duration(hours: 1),
    );
    
    // Check for excessive errors
    if (_actionHistory[errorKey]!.length > 10) { // 10 errors per hour
      await _handleThreatDetection(
        ThreatType.apiAbuse,
        'Excessive API errors for user $userId on endpoint $endpoint',
        SecurityLevel.medium,
        {
          'user_id': userId,
          'endpoint': endpoint,
          'response_code': responseCode,
          'error_count': _actionHistory[errorKey]!.length,
        },
      );
    }
  }
  
  Future<double> _calculateBehaviorRiskScore(
    String userId,
    String action,
    Map<String, dynamic>? context,
  ) async {
    double riskScore = 0.0;
    
    // Check action frequency
    final actionKey = '${userId}_$action';
    final actionCount = _actionHistory[actionKey]?.length ?? 0;
    
    if (actionCount > 50) { // High frequency
      riskScore += 0.3;
    } else if (actionCount > 20) { // Medium frequency
      riskScore += 0.1;
    }
    
    // Check time of day
    final hour = DateTime.now().hour;
    if (hour >= 2 && hour <= 5) { // Unusual hours
      riskScore += 0.2;
    }
    
    // Check context for suspicious patterns
    if (context != null) {
      if (context.containsKey('geolocation_changed')) {
        riskScore += 0.3;
      }
      if (context.containsKey('new_device')) {
        riskScore += 0.2;
      }
      if (context.containsKey('vpn_detected')) {
        riskScore += 0.1;
      }
    }
    
    // Historical risk score
    final historicalRisk = _riskScores[userId] ?? 0.0;
    riskScore = (riskScore + historicalRisk) / 2; // Average with historical
    
    return riskScore.clamp(0.0, 1.0);
  }
  
  Future<void> _updateUserRiskScore(String userId, String action) async {
    final currentScore = _riskScores[userId] ?? 0.0;
    final newScore = await _calculateBehaviorRiskScore(userId, action, null);
    
    // Exponential moving average
    _riskScores[userId] = (currentScore * 0.7) + (newScore * 0.3);
  }
  
  Future<void> _handleThreatDetection(
    ThreatType threatType,
    String description,
    SecurityLevel level,
    Map<String, dynamic> metadata,
  ) async {
    final event = SecurityEvent(
      id: _generateEventId(),
      type: _mapThreatTypeToEventType(threatType),
      level: level,
      description: description,
      timestamp: DateTime.now(),
      userId: metadata['user_id'],
      deviceId: metadata['device_id'],
      ipAddress: metadata['ip_address'],
      metadata: metadata,
    );
    
    await _logSecurityEvent(event);
  }
  
  SecurityEventType _mapThreatTypeToEventType(ThreatType threatType) {
    switch (threatType) {
      case ThreatType.bruteForce:
      case ThreatType.accountTakeover:
        return SecurityEventType.authFailure;
      case ThreatType.dataExfiltration:
      case ThreatType.privilegeEscalation:
        return SecurityEventType.dataAccess;
      case ThreatType.apiAbuse:
      case ThreatType.networkAnomaly:
        return SecurityEventType.privacyViolation;
      case ThreatType.malwareDetection:
        return SecurityEventType.integrityBreach;
      case ThreatType.suspiciousActivity:
      default:
        return SecurityEventType.dataAccess;
    }
  }
  
  String _calculateOverallThreatLevel() {
    final now = DateTime.now();
    final last24Hours = now.subtract(const Duration(hours: 24));
    
    final recentEvents = _securityEvents
        .where((event) => event.timestamp.isAfter(last24Hours))
        .toList();
    
    final criticalCount = recentEvents
        .where((event) => event.level == SecurityLevel.critical)
        .length;
    
    final highCount = recentEvents
        .where((event) => event.level == SecurityLevel.high)
        .length;
    
    if (criticalCount > 0) return 'Critical';
    if (highCount > 5) return 'High';
    if (highCount > 0) return 'Medium';
    return 'Low';
  }
  
  List<Map<String, dynamic>> _getTopThreats(List<SecurityEvent> events) {
    final threatCounts = <SecurityEventType, int>{};
    
    for (final event in events) {
      threatCounts[event.type] = (threatCounts[event.type] ?? 0) + 1;
    }
    
    final sortedThreats = threatCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sortedThreats
        .take(5)
        .map((entry) => {
              'type': entry.key.toString(),
              'count': entry.value,
            })
        .toList();
  }
  
  List<Map<String, dynamic>> _getHighRiskUsers() {
    final highRiskUsers = <Map<String, dynamic>>[];
    
    _riskScores.forEach((userId, score) {
      if (score > 0.7) {
        highRiskUsers.add({
          'user_id': userId,
          'risk_score': score,
          'last_activity': _getLastUserActivity(userId),
        });
      }
    });
    
    highRiskUsers.sort((a, b) => b['risk_score'].compareTo(a['risk_score']));
    return highRiskUsers.take(10).toList();
  }
  
  Future<Map<String, dynamic>> _getSystemHealthStatus() async {
    return {
      'monitoring_active': _isMonitoring,
      'events_processed': _securityEvents.length,
      'threat_rules_active': _threatRules.length,
      'last_check': DateTime.now().toIso8601String(),
    };
  }
  
  Future<String?> _getLastIntegrityCheck() async {
    final lastCheck = _securityEvents
        .where((event) => event.description.contains('integrity'))
        .map((event) => event.timestamp)
        .fold<DateTime?>(null, (latest, current) =>
            latest == null || current.isAfter(latest) ? current : latest);
    
    return lastCheck?.toIso8601String();
  }
  
  String? _getLastUserActivity(String userId) {
    final userEvents = _securityEvents
        .where((event) => event.userId == userId)
        .map((event) => event.timestamp)
        .fold<DateTime?>(null, (latest, current) =>
            latest == null || current.isAfter(latest) ? current : latest);
    
    return userEvents?.toIso8601String();
  }
  
  bool _isKnownDevice(String userId, String deviceId) {
    // In a real implementation, this would check against a database of known devices
    // For now, we'll simulate some known devices
    return Random().nextBool();
  }
  
  bool _shouldSendAlert() {
    if (_lastAlertTime == null) return true;
    return DateTime.now().difference(_lastAlertTime!) > _alertCooldown;
  }
  
  Future<void> _sendSecurityAlert(SecurityEvent event) async {
    _lastAlertTime = DateTime.now();
    
    // In a real implementation, this would send alerts via push notifications,
    // email, SMS, or webhook to security team
    debugPrint('SECURITY ALERT: ${event.description}');
  }
  
  Future<void> _triggerEmergencyLockdown(SecurityEvent event) async {
    // Emergency lockdown procedures
    debugPrint('EMERGENCY LOCKDOWN TRIGGERED: ${event.description}');
    
    // Log the lockdown event
    await _logSecurityEvent(
      SecurityEvent(
        id: _generateEventId(),
        type: SecurityEventType.integrityBreach,
        level: SecurityLevel.critical,
        description: 'Emergency lockdown triggered due to: ${event.description}',
        timestamp: DateTime.now(),
        metadata: {'trigger_event_id': event.id},
      ),
    );
  }
  
  Future<void> _increaseUserMonitoring(String userId) async {
    // Increase monitoring frequency for specific user
    debugPrint('Increased monitoring for user: $userId');
  }
  
  Future<void> _cleanupOldEvents() async {
    final cutoffDate = DateTime.now().subtract(const Duration(days: 30));
    _securityEvents.removeWhere(
      (event) => event.timestamp.isBefore(cutoffDate),
    );
    await _saveSecurityEvents();
  }
  
  Future<void> _updateRiskScores() async {
    // Decay risk scores over time
    final now = DateTime.now();
    _riskScores.updateAll((userId, score) {
      const decay = 0.95; // 5% decay per monitoring cycle
      return score * decay;
    });
    
    // Remove very low risk scores
    _riskScores.removeWhere((userId, score) => score < 0.01);
  }
  
  Future<void> _loadSecurityEvents() async {
    try {
      final encryptedData = await _secureStorage.read(key: _securityEventsKey);
      if (encryptedData != null) {
        final secureData = SecureData.fromJson(jsonDecode(encryptedData));
        final decryptedJson = await _encryptionService.decryptData(secureData);
        final eventsList = jsonDecode(decryptedJson) as List<dynamic>;
        _securityEvents = eventsList
            .map((item) => SecurityEvent.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('Error loading security events: $e');
      _securityEvents = [];
    }
  }
  
  Future<void> _saveSecurityEvents() async {
    try {
      final eventsJson = _securityEvents.map((event) => event.toJson()).toList();
      final jsonString = jsonEncode(eventsJson);
      final secureData = await _encryptionService.encryptData(jsonString);
      final encryptedJson = jsonEncode(secureData.toJson());
      await _secureStorage.write(key: _securityEventsKey, value: encryptedJson);
    } catch (e) {
      debugPrint('Error saving security events: $e');
    }
  }
  
  Future<void> _loadThreatConfiguration() async {
    try {
      final configJson = await _secureStorage.read(key: _threatConfigKey);
      if (configJson != null) {
        final config = jsonDecode(configJson) as Map<String, dynamic>;
        _threatRules = config.map((key, value) =>
            MapEntry(key, ThreatDetectionRule.fromJson(value)));
      }
    } catch (e) {
      debugPrint('Error loading threat configuration: $e');
    }
  }
  
  Future<void> _saveThreatConfiguration() async {
    try {
      final config = _threatRules.map((key, rule) =>
          MapEntry(key, rule.toJson()));
      final configJson = jsonEncode(config);
      await _secureStorage.write(key: _threatConfigKey, value: configJson);
    } catch (e) {
      debugPrint('Error saving threat configuration: $e');
    }
  }
  
  Future<void> _setupDefaultThreatRules() async {
    if (_threatRules.isEmpty) {
      _threatRules = {
        'brute_force': ThreatDetectionRule(
          id: 'brute_force',
          name: 'Brute Force Detection',
          enabled: true,
          threshold: 5,
          timeWindow: const Duration(minutes: 15),
          actions: [ResponseAction.alert, ResponseAction.block],
        ),
        'api_abuse': ThreatDetectionRule(
          id: 'api_abuse',
          name: 'API Abuse Detection',
          enabled: true,
          threshold: 100,
          timeWindow: const Duration(hours: 1),
          actions: [ResponseAction.alert, ResponseAction.restrict],
        ),
        'auto_lockdown': ThreatDetectionRule(
          id: 'auto_lockdown',
          name: 'Auto Lockdown',
          enabled: false, // Disabled by default
          threshold: 1,
          timeWindow: const Duration(seconds: 1),
          actions: [ResponseAction.quarantine],
        ),
      };
      await _saveThreatConfiguration();
    }
  }
  
  String _generateEventId() {
    return DateTime.now().millisecondsSinceEpoch.toString() +
        Random().nextInt(10000).toString();
  }
}

// Supporting data class for threat detection rules
class ThreatDetectionRule {
  final String id;
  final String name;
  final bool enabled;
  final int threshold;
  final Duration timeWindow;
  final List<ResponseAction> actions;
  
  ThreatDetectionRule({
    required this.id,
    required this.name,
    required this.enabled,
    required this.threshold,
    required this.timeWindow,
    required this.actions,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'enabled': enabled,
      'threshold': threshold,
      'time_window_ms': timeWindow.inMilliseconds,
      'actions': actions.map((a) => a.toString()).toList(),
    };
  }
  
  factory ThreatDetectionRule.fromJson(Map<String, dynamic> json) {
    return ThreatDetectionRule(
      id: json['id'],
      name: json['name'],
      enabled: json['enabled'],
      threshold: json['threshold'],
      timeWindow: Duration(milliseconds: json['time_window_ms']),
      actions: (json['actions'] as List<dynamic>)
          .map((a) => ResponseAction.values.firstWhere(
                (action) => action.toString() == a,
                orElse: () => ResponseAction.log,
              ))
          .toList(),
    );
  }
}