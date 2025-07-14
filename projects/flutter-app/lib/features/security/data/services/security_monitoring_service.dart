import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/security_event.dart';
import '../../../../core/enums/security_enums.dart';

class SecurityMonitoringService {
  static const String _eventsKey = 'security_events';
  static const int _maxEvents = 1000;
  
  final _eventController = StreamController<SecurityEvent>.broadcast();
  Stream<SecurityEvent> get eventStream => _eventController.stream;
  
  SecurityMonitoringService(); // 매개변수 없는 생성자 추가
  
  Future<void> logEvent(SecurityEvent event) async {
    _eventController.add(event);
    await _persistEvent(event);
  }
  
  Future<void> _persistEvent(SecurityEvent event) async {
    final prefs = await SharedPreferences.getInstance();
    final events = await getRecentEvents();
    
    events.add(event);
    
    // Keep only the most recent events
    if (events.length > _maxEvents) {
      events.removeRange(0, events.length - _maxEvents);
    }
    
    final jsonList = events.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_eventsKey, jsonList);
  }
  
  Future<List<SecurityEvent>> getRecentEvents({int? limit}) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_eventsKey) ?? [];
    
    final events = jsonList.map((json) {
      return SecurityEvent.fromJson(
        Map<String, dynamic>.from(jsonDecode(json)),
      );
    }).toList();
    
    if (limit != null && events.length > limit) {
      return events.sublist(events.length - limit);
    }
    
    return events;
  }
  
  Future<Map<String, dynamic>> getSecurityMetrics() async {
    final events = await getRecentEvents();
    final now = DateTime.now();
    final last24Hours = now.subtract(const Duration(hours: 24));
    
    final recentEvents = events.where((e) => e.timestamp.isAfter(last24Hours)).toList();
    
    final metrics = <String, dynamic>{
      'totalEvents': events.length,
      'events24h': recentEvents.length,
      'suspiciousEvents': recentEvents.where((e) => e.type == SecurityEventType.suspicious).length,
      'loginAttempts': recentEvents.where((e) => e.type == SecurityEventType.login).length,
      'lastEvent': events.isNotEmpty ? events.last.timestamp : null,
    };
    
    return metrics;
  }
  
  Future<void> cleanupOldEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final events = await getRecentEvents();
    final cutoff = DateTime.now().subtract(const Duration(days: 30));
    
    final filteredEvents = events.where((e) => e.timestamp.isAfter(cutoff)).toList();
    
    final jsonList = filteredEvents.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_eventsKey, jsonList);
  }
  
  Future<void> cleanupTempFiles() async {
    // 임시 파일 정리 로직
    // 실제 구현 시 임시 디렉토리의 파일들을 삭제
  }
  
  SecurityThreatLevel assessThreatLevel(List<SecurityEvent> events) {
    final suspiciousCount = events.where((e) => e.type == SecurityEventType.suspicious).length;
    final criticalCount = events.where((e) => e.level == SecurityLevel.critical).length;
    
    if (criticalCount > 0) return SecurityThreatLevel.critical;
    if (suspiciousCount > 5) return SecurityThreatLevel.high;
    if (suspiciousCount > 2) return SecurityThreatLevel.medium;
    if (suspiciousCount > 0) return SecurityThreatLevel.low;
    
    return SecurityThreatLevel.none;
  }
  
  void dispose() {
    _eventController.close();
  }
}