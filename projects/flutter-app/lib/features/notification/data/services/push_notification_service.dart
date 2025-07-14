import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:timezone/timezone.dart' as tz;
import '../domain/models/app_notification.dart';
import '../domain/models/notification_settings.dart';

// Helper to get timezone location
tz.Location getLocation(String locationName) {
  return tz.getLocation(locationName);
}

// TZDateTime alias
typedef TZDateTime = tz.TZDateTime;

// Top-level function for background message handling
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('Background message received: ${message.messageId}');
  
  // Handle background message
  await PushNotificationService._handleBackgroundMessage(message);
}

class PushNotificationService {
  static const String _fcmTokenKey = 'fcm_token';
  static const String _notificationChannelId = 'jb_report_notifications';
  static const String _notificationChannelName = 'JB Report Notifications';
  static const String _notificationChannelDescription = 'Notifications for JB Report Platform';
  
  final FirebaseMessaging _firebaseMessaging;
  final FlutterLocalNotificationsPlugin _localNotifications;
  final FlutterSecureStorage _secureStorage;
  
  StreamController<AppNotification>? _notificationController;
  StreamController<String>? _tokenController;
  StreamController<String>? _errorController;
  
  NotificationSettings? _settings;
  String? _currentToken;
  bool _isInitialized = false;
  
  PushNotificationService(
    this._firebaseMessaging,
    this._localNotifications,
    this._secureStorage,
  );
  
  // Streams
  Stream<AppNotification> get notificationStream => 
      _notificationController?.stream ?? const Stream.empty();
  Stream<String> get tokenStream => 
      _tokenController?.stream ?? const Stream.empty();
  Stream<String> get errorStream => 
      _errorController?.stream ?? const Stream.empty();
  
  // Getters
  String? get currentToken => _currentToken;
  bool get isInitialized => _isInitialized;
  
  /// Initialize push notification service
  Future<void> initialize({NotificationSettings? settings}) async {
    try {
      if (_isInitialized) return;
      
      _settings = settings;
      
      // Initialize Firebase
      await Firebase.initializeApp();
      
      // Initialize stream controllers
      _notificationController = StreamController<AppNotification>.broadcast();
      _tokenController = StreamController<String>.broadcast();
      _errorController = StreamController<String>.broadcast();
      
      // Setup local notifications
      await _setupLocalNotifications();
      
      // Request permissions
      await _requestPermissions();
      
      // Setup Firebase messaging
      await _setupFirebaseMessaging();
      
      // Get and save FCM token
      await _initializeToken();
      
      _isInitialized = true;
      debugPrint('Push notification service initialized successfully');
      
    } catch (e) {
      debugPrint('Failed to initialize push notification service: $e');
      _errorController?.add('Initialization failed: $e');
      rethrow;
    }
  }
  
  /// Request notification permissions
  Future<bool> requestPermissions() async {
    try {
      return await _requestPermissions();
    } catch (e) {
      debugPrint('Error requesting permissions: $e');
      _errorController?.add('Permission request failed: $e');
      return false;
    }
  }
  
  /// Get current FCM token
  Future<String?> getToken() async {
    try {
      if (_currentToken == null) {
        _currentToken = await _firebaseMessaging.getToken();
        if (_currentToken != null) {
          await _saveToken(_currentToken!);
        }
      }
      return _currentToken;
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
      _errorController?.add('Failed to get token: $e');
      return null;
    }
  }
  
  /// Refresh FCM token
  Future<String?> refreshToken() async {
    try {
      await _firebaseMessaging.deleteToken();
      _currentToken = await _firebaseMessaging.getToken();
      
      if (_currentToken != null) {
        await _saveToken(_currentToken!);
        _tokenController?.add(_currentToken!);
      }
      
      return _currentToken;
    } catch (e) {
      debugPrint('Error refreshing FCM token: $e');
      _errorController?.add('Failed to refresh token: $e');
      return null;
    }
  }
  
  /// Delete FCM token
  Future<void> deleteToken() async {
    try {
      await _firebaseMessaging.deleteToken();
      await _secureStorage.delete(key: _fcmTokenKey);
      _currentToken = null;
    } catch (e) {
      debugPrint('Error deleting FCM token: $e');
      _errorController?.add('Failed to delete token: $e');
    }
  }
  
  /// Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      debugPrint('Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('Error subscribing to topic $topic: $e');
      _errorController?.add('Failed to subscribe to topic: $e');
    }
  }
  
  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      debugPrint('Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('Error unsubscribing from topic $topic: $e');
      _errorController?.add('Failed to unsubscribe from topic: $e');
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
      if (_settings?.enableNotifications != true) return;
      
      final importance = _mapPriorityToImportance(priority);
      final androidDetails = AndroidNotificationDetails(
        _notificationChannelId,
        _notificationChannelName,
        channelDescription: _notificationChannelDescription,
        importance: importance,
        priority: _mapPriorityToAndroidPriority(priority),
        playSound: _settings?.enableSound ?? true,
        enableVibration: _settings?.enableVibration ?? true,
        enableLights: _settings?.enableLedIndicator ?? false,
        icon: 'notification_icon',
        largeIcon: imageUrl != null ? FilePathAndroidBitmap(imageUrl) : null,
        styleInformation: imageUrl != null 
            ? BigPictureStyleInformation(
                FilePathAndroidBitmap(imageUrl),
                contentTitle: title,
                summaryText: body,
              )
            : BigTextStyleInformation(
                body,
                contentTitle: title,
              ),
        actions: actions?.map((action) => AndroidNotificationAction(
          action.id,
          action.title,
          icon: action.icon != null ? DrawableResourceAndroidBitmap(action.icon!) : null,
        )).toList(),
      );
      
      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        interruptionLevel: InterruptionLevel.active,
      );
      
      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );
      
      await _localNotifications.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title,
        body,
        details,
        payload: payload,
      );
      
    } catch (e) {
      debugPrint('Error showing local notification: $e');
      _errorController?.add('Failed to show notification: $e');
    }
  }
  
  /// Schedule local notification
  Future<void> scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
    NotificationPriority priority = NotificationPriority.normal,
  }) async {
    try {
      if (_settings?.enableNotifications != true) return;
      
      final importance = _mapPriorityToImportance(priority);
      final androidDetails = AndroidNotificationDetails(
        _notificationChannelId,
        _notificationChannelName,
        channelDescription: _notificationChannelDescription,
        importance: importance,
        priority: _mapPriorityToAndroidPriority(priority),
        playSound: _settings?.enableSound ?? true,
        enableVibration: _settings?.enableVibration ?? true,
        enableLights: _settings?.enableLedIndicator ?? false,
      );
      
      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );
      
      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );
      
      await _localNotifications.zonedSchedule(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title,
        body,
        TZDateTime.from(scheduledDate, getLocation('UTC')),
        details,
        payload: payload,
        uiLocalNotificationDateInterpretation: 
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
      _errorController?.add('Failed to schedule notification: $e');
    }
  }
  
  /// Cancel notification
  Future<void> cancelNotification(int id) async {
    try {
      await _localNotifications.cancel(id);
    } catch (e) {
      debugPrint('Error canceling notification: $e');
    }
  }
  
  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    try {
      await _localNotifications.cancelAll();
    } catch (e) {
      debugPrint('Error canceling all notifications: $e');
    }
  }
  
  /// Update notification settings
  Future<void> updateSettings(NotificationSettings settings) async {
    _settings = settings;
    
    // Update notification channel if needed
    if (Platform.isAndroid) {
      await _updateAndroidNotificationChannel();
    }
  }
  
  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    try {
      if (Platform.isAndroid) {
        return await Permission.notification.isGranted;
      } else if (Platform.isIOS) {
        final settings = await _firebaseMessaging.getNotificationSettings();
        return settings.authorizationStatus == AuthorizationStatus.authorized;
      }
      return false;
    } catch (e) {
      debugPrint('Error checking notification status: $e');
      return false;
    }
  }
  
  /// Get notification statistics
  Future<Map<String, dynamic>> getStatistics() async {
    try {
      final pendingNotifications = await _localNotifications.pendingNotificationRequests();
      final activeNotifications = Platform.isAndroid 
          ? await _localNotifications.getActiveNotifications()
          : <ActiveNotification>[];
      
      return {
        'pending_count': pendingNotifications.length,
        'active_count': activeNotifications.length,
        'fcm_token': _currentToken,
        'permissions_granted': await areNotificationsEnabled(),
        'settings': _settings?.toJson(),
      };
    } catch (e) {
      debugPrint('Error getting notification statistics: $e');
      return {'error': e.toString()};
    }
  }
  
  /// Dispose resources
  void dispose() {
    _notificationController?.close();
    _tokenController?.close();
    _errorController?.close();
  }
  
  // Private methods
  
  Future<void> _setupLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('notification_icon');
    
    final iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      onDidReceiveLocalNotification: _onDidReceiveLocalNotification,
    );
    
    final initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
    );
    
    // Create notification channel for Android
    if (Platform.isAndroid) {
      await _createAndroidNotificationChannel();
    }
  }
  
  Future<void> _createAndroidNotificationChannel() async {
    const androidChannel = AndroidNotificationChannel(
      _notificationChannelId,
      _notificationChannelName,
      description: _notificationChannelDescription,
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
      enableLights: true,
    );
    
    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }
  
  Future<void> _updateAndroidNotificationChannel() async {
    if (_settings == null) return;
    
    final androidChannel = AndroidNotificationChannel(
      _notificationChannelId,
      _notificationChannelName,
      description: _notificationChannelDescription,
      importance: Importance.high,
      playSound: _settings!.enableSound,
      enableVibration: _settings!.enableVibration,
      enableLights: _settings!.enableLedIndicator,
    );
    
    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }
  
  Future<bool> _requestPermissions() async {
    try {
      if (Platform.isAndroid) {
        // Android 13+ requires notification permission
        if (await Permission.notification.isDenied) {
          final status = await Permission.notification.request();
          return status.isGranted;
        }
        return true;
      } else if (Platform.isIOS) {
        final settings = await _firebaseMessaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
          carPlay: false,
          criticalAlert: false,
          provisional: false,
          announcement: false,
        );
        return settings.authorizationStatus == AuthorizationStatus.authorized;
      }
      return false;
    } catch (e) {
      debugPrint('Error requesting permissions: $e');
      return false;
    }
  }
  
  Future<void> _setupFirebaseMessaging() async {
    // Set background message handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    
    // Handle message opened app
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
    
    // Handle token refresh
    _firebaseMessaging.onTokenRefresh.listen(_handleTokenRefresh);
    
    // Handle initial message (app opened from notification)
    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageOpenedApp(initialMessage);
    }
  }
  
  Future<void> _initializeToken() async {
    try {
      // Load cached token
      final cachedToken = await _secureStorage.read(key: _fcmTokenKey);
      
      // Get current token
      _currentToken = await _firebaseMessaging.getToken();
      
      if (_currentToken != null) {
        // Save token if it's new or different
        if (cachedToken != _currentToken) {
          await _saveToken(_currentToken!);
          _tokenController?.add(_currentToken!);
        }
      }
    } catch (e) {
      debugPrint('Error initializing token: $e');
    }
  }
  
  Future<void> _saveToken(String token) async {
    try {
      await _secureStorage.write(key: _fcmTokenKey, value: token);
      debugPrint('FCM token saved');
    } catch (e) {
      debugPrint('Error saving FCM token: $e');
    }
  }
  
  void _handleForegroundMessage(RemoteMessage message) {
    try {
      debugPrint('Foreground message received: ${message.messageId}');
      
      final notification = _convertRemoteMessageToAppNotification(message);
      _notificationController?.add(notification);
      
      // Show local notification if in-app notifications are disabled
      if (_settings?.enableInAppNotifications != true) {
        _showNotificationFromRemoteMessage(message);
      }
    } catch (e) {
      debugPrint('Error handling foreground message: $e');
      _errorController?.add('Failed to handle foreground message: $e');
    }
  }
  
  void _handleMessageOpenedApp(RemoteMessage message) {
    try {
      debugPrint('Message opened app: ${message.messageId}');
      
      final notification = _convertRemoteMessageToAppNotification(message);
      _notificationController?.add(notification);
      
      // Handle navigation or action based on message data
      _handleNotificationAction(message);
    } catch (e) {
      debugPrint('Error handling message opened app: $e');
      _errorController?.add('Failed to handle message opened app: $e');
    }
  }
  
  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    try {
      debugPrint('Background message handled: ${message.messageId}');
      // Background message handling logic
    } catch (e) {
      debugPrint('Error handling background message: $e');
    }
  }
  
  void _handleTokenRefresh(String token) {
    try {
      _currentToken = token;
      _saveToken(token);
      _tokenController?.add(token);
      debugPrint('FCM token refreshed');
    } catch (e) {
      debugPrint('Error handling token refresh: $e');
    }
  }
  
  void _onDidReceiveLocalNotification(
    int id,
    String? title,
    String? body,
    String? payload,
  ) {
    // iOS local notification received while app in foreground
    debugPrint('Local notification received: $title');
  }
  
  void _onDidReceiveNotificationResponse(NotificationResponse response) {
    try {
      debugPrint('Notification response: ${response.payload}');
      
      if (response.payload != null) {
        final data = jsonDecode(response.payload!) as Map<String, dynamic>;
        // Handle notification action
        _handleNotificationActionFromPayload(data);
      }
    } catch (e) {
      debugPrint('Error handling notification response: $e');
    }
  }
  
  AppNotification _convertRemoteMessageToAppNotification(RemoteMessage message) {
    return AppNotification(
      id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      type: _parseNotificationType(message.data['type']),
      title: message.notification?.title ?? 'Notification',
      message: message.notification?.body ?? '',
      imageUrl: message.notification?.android?.imageUrl ?? 
                message.notification?.apple?.imageUrl,
      data: message.data,
      createdAt: DateTime.now(),
      priority: _parseNotificationPriority(message.data['priority']),
      actionUrl: message.data['action_url'],
      userId: message.data['user_id'],
      reportId: message.data['report_id'],
    );
  }
  
  Future<void> _showNotificationFromRemoteMessage(RemoteMessage message) async {
    final notification = message.notification;
    if (notification != null) {
      await showLocalNotification(
        title: notification.title ?? 'Notification',
        body: notification.body ?? '',
        payload: jsonEncode(message.data),
        priority: _parseNotificationPriority(message.data['priority']),
        imageUrl: notification.android?.imageUrl ?? notification.apple?.imageUrl,
      );
    }
  }
  
  void _handleNotificationAction(RemoteMessage message) {
    // Handle navigation or action based on message data
    final actionUrl = message.data['action_url'];
    if (actionUrl != null) {
      // Navigate to specific screen or perform action
      debugPrint('Handling notification action: $actionUrl');
    }
  }
  
  void _handleNotificationActionFromPayload(Map<String, dynamic> data) {
    // Handle notification action from local notification payload
    final actionUrl = data['action_url'];
    if (actionUrl != null) {
      debugPrint('Handling payload action: $actionUrl');
    }
  }
  
  NotificationType _parseNotificationType(dynamic type) {
    if (type is String) {
      switch (type) {
        case 'report_status':
          return NotificationType.reportStatus;
        case 'comment_new':
          return NotificationType.commentNew;
        case 'comment_reply':
          return NotificationType.commentReply;
        case 'admin_message':
          return NotificationType.adminMessage;
        case 'system_notice':
          return NotificationType.systemNotice;
        case 'emergency':
          return NotificationType.emergency;
        case 'security_alert':
          return NotificationType.securityAlert;
        case 'maintenance':
          return NotificationType.maintenance;
        case 'promotion':
          return NotificationType.promotion;
        default:
          return NotificationType.systemNotice;
      }
    }
    return NotificationType.systemNotice;
  }
  
  NotificationPriority _parseNotificationPriority(dynamic priority) {
    if (priority is String) {
      switch (priority) {
        case 'low':
          return NotificationPriority.low;
        case 'normal':
          return NotificationPriority.normal;
        case 'high':
          return NotificationPriority.high;
        case 'urgent':
          return NotificationPriority.urgent;
        default:
          return NotificationPriority.normal;
      }
    }
    return NotificationPriority.normal;
  }
  
  Importance _mapPriorityToImportance(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.low:
        return Importance.low;
      case NotificationPriority.normal:
        return Importance.defaultImportance;
      case NotificationPriority.high:
        return Importance.high;
      case NotificationPriority.urgent:
        return Importance.max;
    }
  }
  
  Priority _mapPriorityToAndroidPriority(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.low:
        return Priority.low;
      case NotificationPriority.normal:
        return Priority.defaultPriority;
      case NotificationPriority.high:
        return Priority.high;
      case NotificationPriority.urgent:
        return Priority.max;
    }
  }
}