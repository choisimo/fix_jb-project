import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../domain/models/app_notification.dart';
import '../domain/models/notification_settings.dart';

enum WebSocketConnectionState {
  connecting,
  connected,
  disconnected,
  reconnecting,
  error,
}

class NotificationService {
  static const String _baseUrl = 'ws://localhost:8080';
  static const String _notificationEndpoint = '/ws/notifications';
  static const Duration _heartbeatInterval = Duration(seconds: 30);
  static const Duration _reconnectBaseDelay = Duration(seconds: 1);
  static const int _maxReconnectAttempts = 10;
  static const String _notificationsStorageKey = 'cached_notifications';
  static const String _settingsStorageKey = 'notification_settings';
  
  final FlutterSecureStorage _secureStorage;
  
  WebSocketChannel? _channel;
  WebSocketConnectionState _connectionState = WebSocketConnectionState.disconnected;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  String? _authToken;
  
  final StreamController<AppNotification> _notificationController = 
      StreamController<AppNotification>.broadcast();
  final StreamController<WebSocketConnectionState> _connectionController = 
      StreamController<WebSocketConnectionState>.broadcast();
  final StreamController<String> _errorController = 
      StreamController<String>.broadcast();
  
  List<AppNotification> _cachedNotifications = [];
  NotificationSettings? _settings;
  
  // Message queue for offline scenarios
  final List<Map<String, dynamic>> _messageQueue = [];
  
  NotificationService(this._secureStorage);
  
  // Streams
  Stream<AppNotification> get notificationStream => _notificationController.stream;
  Stream<WebSocketConnectionState> get connectionStream => _connectionController.stream;
  Stream<String> get errorStream => _errorController.stream;
  
  // Getters
  WebSocketConnectionState get connectionState => _connectionState;
  List<AppNotification> get cachedNotifications => List.unmodifiable(_cachedNotifications);
  NotificationSettings? get settings => _settings;
  
  /// Initialize notification service
  Future<void> initialize({String? authToken}) async {
    try {
      _authToken = authToken;
      await _loadCachedNotifications();
      await _loadSettings();
      
      debugPrint('Notification service initialized');
    } catch (e) {
      debugPrint('Failed to initialize notification service: $e');
      _errorController.add('Initialization failed: $e');
    }
  }
  
  /// Connect to WebSocket server
  Future<void> connect() async {
    if (_connectionState == WebSocketConnectionState.connected ||
        _connectionState == WebSocketConnectionState.connecting) {
      return;
    }
    
    try {
      _updateConnectionState(WebSocketConnectionState.connecting);
      
      final uri = Uri.parse('$_baseUrl$_notificationEndpoint');
      
      // Add authentication header if available
      final headers = <String, String>{};
      if (_authToken != null) {
        headers['Authorization'] = 'Bearer $_authToken';
      }
      
      _channel = WebSocketChannel.connect(uri);
      
      // Send authentication message if token is available
      if (_authToken != null) {
        _sendMessage({
          'type': 'authenticate',
          'token': _authToken,
        });
      }
      
      // Listen to messages
      _channel!.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDisconnection,
      );
      
      _updateConnectionState(WebSocketConnectionState.connected);
      _reconnectAttempts = 0;
      _startHeartbeat();
      _processMessageQueue();
      
      debugPrint('WebSocket connected successfully');
    } catch (e) {
      debugPrint('WebSocket connection failed: $e');
      _updateConnectionState(WebSocketConnectionState.error);
      _errorController.add('Connection failed: $e');
      _scheduleReconnect();
    }
  }
  
  /// Disconnect from WebSocket server
  Future<void> disconnect() async {
    try {
      _heartbeatTimer?.cancel();
      _reconnectTimer?.cancel();
      
      if (_channel != null) {
        await _channel!.sink.close(status.goingAway);
        _channel = null;
      }
      
      _updateConnectionState(WebSocketConnectionState.disconnected);
      _reconnectAttempts = 0;
      
      debugPrint('WebSocket disconnected');
    } catch (e) {
      debugPrint('Error during disconnect: $e');
    }
  }
  
  /// Send message to server
  void sendMessage(Map<String, dynamic> message) {
    if (_connectionState == WebSocketConnectionState.connected && _channel != null) {
      _sendMessage(message);
    } else {
      // Queue message for later sending
      _messageQueue.add(message);
    }
  }
  
  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      // Update local cache
      final index = _cachedNotifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _cachedNotifications[index] = _cachedNotifications[index].copyWith(isRead: true);
        await _saveCachedNotifications();
      }
      
      // Send to server
      sendMessage({
        'type': 'mark_read',
        'notification_id': notificationId,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
      _errorController.add('Failed to mark as read: $e');
    }
  }
  
  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      // Update local cache
      _cachedNotifications = _cachedNotifications
          .map((n) => n.copyWith(isRead: true))
          .toList();
      await _saveCachedNotifications();
      
      // Send to server
      sendMessage({
        'type': 'mark_all_read',
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Error marking all notifications as read: $e');
      _errorController.add('Failed to mark all as read: $e');
    }
  }
  
  /// Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      // Remove from local cache
      _cachedNotifications.removeWhere((n) => n.id == notificationId);
      await _saveCachedNotifications();
      
      // Send to server
      sendMessage({
        'type': 'delete_notification',
        'notification_id': notificationId,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Error deleting notification: $e');
      _errorController.add('Failed to delete notification: $e');
    }
  }
  
  /// Update notification settings
  Future<void> updateSettings(NotificationSettings settings) async {
    try {
      _settings = settings.copyWith(lastUpdated: DateTime.now());
      await _saveSettings();
      
      // Send to server
      sendMessage({
        'type': 'update_settings',
        'settings': _settings!.toJson(),
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Error updating settings: $e');
      _errorController.add('Failed to update settings: $e');
    }
  }
  
  /// Get notifications with filtering
  List<AppNotification> getNotifications({
    bool? isRead,
    NotificationType? type,
    NotificationPriority? priority,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) {
    var notifications = List<AppNotification>.from(_cachedNotifications);
    
    // Apply filters
    if (isRead != null) {
      notifications = notifications.where((n) => n.isRead == isRead).toList();
    }
    
    if (type != null) {
      notifications = notifications.where((n) => n.type == type).toList();
    }
    
    if (priority != null) {
      notifications = notifications.where((n) => n.priority == priority).toList();
    }
    
    if (startDate != null) {
      notifications = notifications.where((n) => n.createdAt.isAfter(startDate)).toList();
    }
    
    if (endDate != null) {
      notifications = notifications.where((n) => n.createdAt.isBefore(endDate)).toList();
    }
    
    // Sort by creation date (newest first)
    notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    // Apply limit
    if (limit != null && notifications.length > limit) {
      notifications = notifications.take(limit).toList();
    }
    
    return notifications;
  }
  
  /// Get unread count
  int getUnreadCount() {
    return _cachedNotifications.where((n) => !n.isRead).length;
  }
  
  /// Request notification history from server
  Future<void> requestNotificationHistory({
    DateTime? since,
    int? limit,
  }) async {
    sendMessage({
      'type': 'request_history',
      'since': since?.toIso8601String(),
      'limit': limit ?? 100,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
  
  /// Clear all notifications
  Future<void> clearAll() async {
    try {
      _cachedNotifications.clear();
      await _saveCachedNotifications();
      
      sendMessage({
        'type': 'clear_all',
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Error clearing notifications: $e');
      _errorController.add('Failed to clear notifications: $e');
    }
  }
  
  /// Dispose resources
  void dispose() {
    _heartbeatTimer?.cancel();
    _reconnectTimer?.cancel();
    _channel?.sink.close();
    _notificationController.close();
    _connectionController.close();
    _errorController.close();
  }
  
  // Private methods
  
  void _handleMessage(dynamic message) {
    try {
      final data = jsonDecode(message as String) as Map<String, dynamic>;
      final messageType = data['type'] as String;
      
      switch (messageType) {
        case 'notification':
          _handleNotificationMessage(data);
          break;
        case 'notification_history':
          _handleNotificationHistory(data);
          break;
        case 'settings_updated':
          _handleSettingsUpdated(data);
          break;
        case 'pong':
          // Heartbeat response - no action needed
          break;
        case 'error':
          _handleServerError(data);
          break;
        default:
          debugPrint('Unknown message type: $messageType');
      }
    } catch (e) {
      debugPrint('Error handling message: $e');
      _errorController.add('Message handling error: $e');
    }
  }
  
  void _handleNotificationMessage(Map<String, dynamic> data) {
    try {
      final notificationData = data['data'] as Map<String, dynamic>;
      final notification = AppNotification.fromJson(notificationData);
      
      // Add to cache
      _cachedNotifications.insert(0, notification);
      
      // Remove expired notifications
      _removeExpiredNotifications();
      
      // Limit cache size
      if (_cachedNotifications.length > 1000) {
        _cachedNotifications = _cachedNotifications.take(1000).toList();
      }
      
      _saveCachedNotifications();
      
      // Emit notification
      _notificationController.add(notification);
      
      debugPrint('Received notification: ${notification.title}');
    } catch (e) {
      debugPrint('Error handling notification message: $e');
    }
  }
  
  void _handleNotificationHistory(Map<String, dynamic> data) {
    try {
      final notifications = (data['notifications'] as List<dynamic>)
          .map((item) => AppNotification.fromJson(item as Map<String, dynamic>))
          .toList();
      
      // Merge with existing notifications (avoid duplicates)
      for (final notification in notifications) {
        if (!_cachedNotifications.any((n) => n.id == notification.id)) {
          _cachedNotifications.add(notification);
        }
      }
      
      // Sort by creation date
      _cachedNotifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      _saveCachedNotifications();
      
      debugPrint('Loaded ${notifications.length} notifications from history');
    } catch (e) {
      debugPrint('Error handling notification history: $e');
    }
  }
  
  void _handleSettingsUpdated(Map<String, dynamic> data) {
    try {
      final settingsData = data['settings'] as Map<String, dynamic>;
      _settings = NotificationSettings.fromJson(settingsData);
      _saveSettings();
      
      debugPrint('Settings updated from server');
    } catch (e) {
      debugPrint('Error handling settings update: $e');
    }
  }
  
  void _handleServerError(Map<String, dynamic> data) {
    final error = data['message'] as String? ?? 'Unknown server error';
    debugPrint('Server error: $error');
    _errorController.add('Server error: $error');
  }
  
  void _handleError(dynamic error) {
    debugPrint('WebSocket error: $error');
    _updateConnectionState(WebSocketConnectionState.error);
    _errorController.add('Connection error: $error');
    _scheduleReconnect();
  }
  
  void _handleDisconnection() {
    debugPrint('WebSocket disconnected');
    _updateConnectionState(WebSocketConnectionState.disconnected);
    _scheduleReconnect();
  }
  
  void _sendMessage(Map<String, dynamic> message) {
    try {
      if (_channel != null) {
        _channel!.sink.add(jsonEncode(message));
      }
    } catch (e) {
      debugPrint('Error sending message: $e');
      _messageQueue.add(message);
    }
  }
  
  void _updateConnectionState(WebSocketConnectionState state) {
    if (_connectionState != state) {
      _connectionState = state;
      _connectionController.add(state);
    }
  }
  
  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(_heartbeatInterval, (_) {
      if (_connectionState == WebSocketConnectionState.connected) {
        _sendMessage({
          'type': 'ping',
          'timestamp': DateTime.now().toIso8601String(),
        });
      }
    });
  }
  
  void _scheduleReconnect() {
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      debugPrint('Max reconnect attempts reached');
      _updateConnectionState(WebSocketConnectionState.error);
      return;
    }
    
    _reconnectTimer?.cancel();
    
    final delay = Duration(
      seconds: _reconnectBaseDelay.inSeconds * pow(2, _reconnectAttempts).toInt(),
    );
    
    debugPrint('Scheduling reconnect in ${delay.inSeconds} seconds (attempt ${_reconnectAttempts + 1})');
    
    _updateConnectionState(WebSocketConnectionState.reconnecting);
    
    _reconnectTimer = Timer(delay, () {
      _reconnectAttempts++;
      connect();
    });
  }
  
  void _processMessageQueue() {
    if (_messageQueue.isNotEmpty && _connectionState == WebSocketConnectionState.connected) {
      final messages = List<Map<String, dynamic>>.from(_messageQueue);
      _messageQueue.clear();
      
      for (final message in messages) {
        _sendMessage(message);
      }
      
      debugPrint('Processed ${messages.length} queued messages');
    }
  }
  
  void _removeExpiredNotifications() {
    final now = DateTime.now();
    _cachedNotifications.removeWhere((notification) {
      return notification.expiresAt != null && notification.expiresAt!.isBefore(now);
    });
  }
  
  Future<void> _loadCachedNotifications() async {
    try {
      final cachedData = await _secureStorage.read(key: _notificationsStorageKey);
      if (cachedData != null) {
        final List<dynamic> notificationsList = jsonDecode(cachedData);
        _cachedNotifications = notificationsList
            .map((item) => AppNotification.fromJson(item as Map<String, dynamic>))
            .toList();
        
        _removeExpiredNotifications();
        
        debugPrint('Loaded ${_cachedNotifications.length} cached notifications');
      }
    } catch (e) {
      debugPrint('Error loading cached notifications: $e');
      _cachedNotifications = [];
    }
  }
  
  Future<void> _saveCachedNotifications() async {
    try {
      final notificationsJson = _cachedNotifications
          .map((notification) => notification.toJson())
          .toList();
      
      await _secureStorage.write(
        key: _notificationsStorageKey,
        value: jsonEncode(notificationsJson),
      );
    } catch (e) {
      debugPrint('Error saving cached notifications: $e');
    }
  }
  
  Future<void> _loadSettings() async {
    try {
      final settingsData = await _secureStorage.read(key: _settingsStorageKey);
      if (settingsData != null) {
        _settings = NotificationSettings.fromJson(jsonDecode(settingsData));
      } else {
        // Create default settings
        _settings = const NotificationSettings();
        await _saveSettings();
      }
    } catch (e) {
      debugPrint('Error loading settings: $e');
      _settings = const NotificationSettings();
    }
  }
  
  Future<void> _saveSettings() async {
    try {
      if (_settings != null) {
        await _secureStorage.write(
          key: _settingsStorageKey,
          value: jsonEncode(_settings!.toJson()),
        );
      }
    } catch (e) {
      debugPrint('Error saving settings: $e');
    }
  }
}