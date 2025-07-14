import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/models/notification_state.dart';
import '../domain/models/app_notification.dart';
import '../domain/models/notification_settings.dart';
import '../data/services/notification_service.dart';
import '../data/services/push_notification_service.dart';
import '../data/providers/notification_providers.dart';

part 'notification_controller.g.dart';

@riverpod
class NotificationController extends _$NotificationController {
  late final NotificationService _notificationService;
  late final PushNotificationService _pushService;
  
  StreamSubscription<AppNotification>? _notificationSubscription;
  StreamSubscription<WebSocketConnectionState>? _connectionSubscription;
  StreamSubscription<AppNotification>? _pushNotificationSubscription;
  StreamSubscription<String>? _tokenSubscription;
  
  @override
  NotificationState build() {
    _initializeServices();
    return const NotificationState();
  }
  
  void _initializeServices() {
    _notificationService = ref.read(notificationServiceProvider);
    _pushService = ref.read(pushNotificationServiceProvider);
  }
  
  /// Initialize notification system
  Future<void> initialize({String? authToken}) async {
    try {
      state = state.copyWith(isInitializing: true);
      
      // Initialize both services
      await Future.wait([
        _notificationService.initialize(authToken: authToken),
        _pushService.initialize(settings: state.settings),
      ]);
      
      // Load cached data
      final cachedNotifications = _notificationService.cachedNotifications;
      final settings = _notificationService.settings;
      final unreadCount = _notificationService.getUnreadCount();
      
      // Get FCM token
      final fcmToken = await _pushService.getToken();
      
      state = state.copyWith(
        notifications: cachedNotifications,
        settings: settings ?? const NotificationSettings(),
        unreadCount: unreadCount,
        fcmToken: fcmToken,
        isInitializing: false,
        error: null,
      );
      
      // Setup stream listeners
      _setupStreamListeners();
      
      // Connect to WebSocket
      await connectWebSocket();
      
    } catch (e) {
      state = state.copyWith(
        isInitializing: false,
        error: 'Failed to initialize notifications: ${e.toString()}',
      );
      rethrow;
    }
  }
  
  /// Connect to WebSocket server
  Future<void> connectWebSocket() async {
    try {
      await _notificationService.connect();
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to connect to notification server: ${e.toString()}',
      );
    }
  }
  
  /// Disconnect from WebSocket server
  Future<void> disconnectWebSocket() async {
    try {
      await _notificationService.disconnect();
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to disconnect from notification server: ${e.toString()}',
      );
    }
  }
  
  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _notificationService.markAsRead(notificationId);
      
      // Update local state
      final updatedNotifications = state.notifications.map((notification) {
        if (notification.id == notificationId) {
          return notification.copyWith(isRead: true);
        }
        return notification;
      }).toList();
      
      final unreadCount = updatedNotifications.where((n) => !n.isRead).length;
      
      state = state.copyWith(
        notifications: updatedNotifications,
        unreadCount: unreadCount,
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to mark notification as read: ${e.toString()}',
      );
    }
  }
  
  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      await _notificationService.markAllAsRead();
      
      // Update local state
      final updatedNotifications = state.notifications
          .map((notification) => notification.copyWith(isRead: true))
          .toList();
      
      state = state.copyWith(
        notifications: updatedNotifications,
        unreadCount: 0,
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to mark all notifications as read: ${e.toString()}',
      );
    }
  }
  
  /// Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _notificationService.deleteNotification(notificationId);
      
      // Update local state
      final updatedNotifications = state.notifications
          .where((notification) => notification.id != notificationId)
          .toList();
      
      final unreadCount = updatedNotifications.where((n) => !n.isRead).length;
      
      state = state.copyWith(
        notifications: updatedNotifications,
        unreadCount: unreadCount,
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to delete notification: ${e.toString()}',
      );
    }
  }
  
  /// Update notification settings
  Future<void> updateSettings(NotificationSettings settings) async {
    try {
      await Future.wait([
        _notificationService.updateSettings(settings),
        _pushService.updateSettings(settings),
      ]);
      
      state = state.copyWith(
        settings: settings,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to update notification settings: ${e.toString()}',
      );
    }
  }
  
  /// Request notification permissions
  Future<bool> requestPermissions() async {
    try {
      return await _pushService.requestPermissions();
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to request permissions: ${e.toString()}',
      );
      return false;
    }
  }
  
  /// Show local notification
  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
    NotificationPriority priority = NotificationPriority.normal,
    String? imageUrl,
    List<NotificationAction>? actions,
  }) async {
    try {
      await _pushService.showLocalNotification(
        title: title,
        body: body,
        payload: payload,
        priority: priority,
        imageUrl: imageUrl,
        actions: actions,
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to show local notification: ${e.toString()}',
      );
    }
  }
  
  /// Schedule notification
  Future<void> scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
    NotificationPriority priority = NotificationPriority.normal,
  }) async {
    try {
      await _pushService.scheduleNotification(
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        payload: payload,
        priority: priority,
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to schedule notification: ${e.toString()}',
      );
    }
  }
  
  /// Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _pushService.subscribeToTopic(topic);
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to subscribe to topic: ${e.toString()}',
      );
    }
  }
  
  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _pushService.unsubscribeFromTopic(topic);
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to unsubscribe from topic: ${e.toString()}',
      );
    }
  }
  
  /// Get filtered notifications
  List<AppNotification> getFilteredNotifications({
    bool? isRead,
    NotificationType? type,
    NotificationPriority? priority,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) {
    return _notificationService.getNotifications(
      isRead: isRead,
      type: type,
      priority: priority,
      startDate: startDate,
      endDate: endDate,
      limit: limit,
    );
  }
  
  /// Request notification history
  Future<void> requestNotificationHistory({
    DateTime? since,
    int? limit,
  }) async {
    try {
      await _notificationService.requestNotificationHistory(
        since: since,
        limit: limit,
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to request notification history: ${e.toString()}',
      );
    }
  }
  
  /// Clear all notifications
  Future<void> clearAllNotifications() async {
    try {
      await _notificationService.clearAll();
      await _pushService.cancelAllNotifications();
      
      state = state.copyWith(
        notifications: [],
        unreadCount: 0,
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to clear notifications: ${e.toString()}',
      );
    }
  }
  
  /// Get notification statistics
  Future<Map<String, dynamic>> getStatistics() async {
    try {
      final pushStats = await _pushService.getStatistics();
      final webSocketStats = {
        'connection_state': _notificationService.connectionState.toString(),
        'cached_notifications': _notificationService.cachedNotifications.length,
        'unread_count': _notificationService.getUnreadCount(),
      };
      
      return {
        'push_notifications': pushStats,
        'websocket': webSocketStats,
        'total_notifications': state.notifications.length,
        'unread_notifications': state.unreadCount,
        'last_sync': state.lastSync?.toIso8601String(),
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }
  
  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    try {
      return await _pushService.areNotificationsEnabled();
    } catch (e) {
      return false;
    }
  }
  
  /// Refresh FCM token
  Future<String?> refreshFCMToken() async {
    try {
      final token = await _pushService.refreshToken();
      state = state.copyWith(fcmToken: token);
      return token;
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to refresh FCM token: ${e.toString()}',
      );
      return null;
    }
  }
  
  /// Clear error state
  void clearError() {
    state = state.copyWith(error: null);
  }
  
  /// Add notification to recent list
  void _addToRecentNotifications(AppNotification notification) {
    final recentNotifications = List<AppNotification>.from(state.recentNotifications);
    recentNotifications.insert(0, notification);
    
    // Keep only last 10 recent notifications
    if (recentNotifications.length > 10) {
      recentNotifications.removeLast();
    }
    
    state = state.copyWith(recentNotifications: recentNotifications);
  }
  
  /// Setup stream listeners
  void _setupStreamListeners() {
    // Listen to WebSocket notifications
    _notificationSubscription = _notificationService.notificationStream.listen(
      (notification) {
        // Add to notifications list
        final updatedNotifications = [notification, ...state.notifications];
        final unreadCount = updatedNotifications.where((n) => !n.isRead).length;
        
        state = state.copyWith(
          notifications: updatedNotifications,
          unreadCount: unreadCount,
          hasPendingNotifications: true,
          lastSync: DateTime.now(),
        );
        
        // Add to recent notifications
        _addToRecentNotifications(notification);
        
        // Show local notification if app is in background
        if (state.settings?.enableInAppNotifications == false) {
          _pushService.showLocalNotification(
            title: notification.title,
            body: notification.message,
            priority: notification.priority,
            imageUrl: notification.imageUrl,
            actions: notification.actions,
          );
        }
      },
      onError: (error) {
        state = state.copyWith(
          error: 'Notification stream error: ${error.toString()}',
        );
      },
    );
    
    // Listen to WebSocket connection status
    _connectionSubscription = _notificationService.connectionStream.listen(
      (connectionState) {
        final status = _mapWebSocketStateToConnectionStatus(connectionState);
        state = state.copyWith(
          connectionStatus: status,
          isConnected: connectionState == WebSocketConnectionState.connected,
        );
      },
    );
    
    // Listen to push notifications
    _pushNotificationSubscription = _pushService.notificationStream.listen(
      (notification) {
        // Add to notifications list if not already present
        final exists = state.notifications.any((n) => n.id == notification.id);
        if (!exists) {
          final updatedNotifications = [notification, ...state.notifications];
          final unreadCount = updatedNotifications.where((n) => !n.isRead).length;
          
          state = state.copyWith(
            notifications: updatedNotifications,
            unreadCount: unreadCount,
            lastSync: DateTime.now(),
          );
          
          _addToRecentNotifications(notification);
        }
      },
      onError: (error) {
        state = state.copyWith(
          error: 'Push notification error: ${error.toString()}',
        );
      },
    );
    
    // Listen to FCM token updates
    _tokenSubscription = _pushService.tokenStream.listen(
      (token) {
        state = state.copyWith(fcmToken: token);
      },
    );
  }
  
  /// Map WebSocket connection state to ConnectionStatus
  ConnectionStatus _mapWebSocketStateToConnectionStatus(WebSocketConnectionState wsState) {
    switch (wsState) {
      case WebSocketConnectionState.connected:
        return ConnectionStatus.connected;
      case WebSocketConnectionState.connecting:
        return ConnectionStatus.connecting;
      case WebSocketConnectionState.disconnected:
        return ConnectionStatus.disconnected;
      case WebSocketConnectionState.reconnecting:
        return ConnectionStatus.reconnecting;
      case WebSocketConnectionState.error:
        return ConnectionStatus.error;
    }
  }
  
  /// Dispose resources
  void dispose() {
    _notificationSubscription?.cancel();
    _connectionSubscription?.cancel();
    _pushNotificationSubscription?.cancel();
    _tokenSubscription?.cancel();
    
    _notificationService.dispose();
    _pushService.dispose();
  }
}