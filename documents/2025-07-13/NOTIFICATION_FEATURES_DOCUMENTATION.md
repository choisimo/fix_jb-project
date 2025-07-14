# JB Report - Notification System Documentation

## Overview

The JB Report application features a sophisticated **multi-channel notification system** that provides real-time communication through **Firebase Cloud Messaging (FCM)**, **WebSocket connections**, and **local notifications**. The system supports comprehensive notification management, advanced settings, and intelligent delivery mechanisms.

## 🔔 Notification Architecture

### Multi-Channel Delivery System
The notification system operates through three primary channels:

1. **🔥 Firebase Cloud Messaging (FCM)**
   - Remote push notifications
   - Background message handling
   - Cross-platform delivery (iOS/Android)
   - Topic-based subscriptions

2. **⚡ WebSocket Real-Time**
   - Instant in-app notifications
   - Real-time status updates
   - Connection status monitoring
   - Automatic reconnection

3. **📱 Local Notifications**
   - Scheduled notifications
   - Offline notification display
   - Custom action buttons
   - Rich media support

## 📋 Notification Types

### Core Notification Categories
The system supports 5 main notification types:

#### 1. **📊 Report Status (`reportStatus`)**
- **Purpose**: Updates on submitted report progress
- **Triggers**: 
  - Report submitted for review
  - Status changed (approved/rejected/resolved)
  - Assignment to administrator
  - Resolution completion
- **User Settings**: Individually controllable
- **Default**: Enabled

#### 2. **💬 Comments (`comment`)**
- **Purpose**: Engagement on user's reports
- **Triggers**:
  - New comment on user's report
  - Reply to user's comment
  - Comment mentions
  - Administrator responses
- **User Settings**: Individually controllable
- **Default**: Enabled

#### 3. **⚙️ System (`system`)**
- **Purpose**: Important system notifications
- **Triggers**:
  - System maintenance alerts
  - Security notifications
  - Account-related updates
  - Service status changes
- **User Settings**: Individually controllable
- **Default**: Enabled

#### 4. **📢 Announcements (`announcement`)**
- **Purpose**: Platform announcements and updates
- **Triggers**:
  - New feature announcements
  - Policy updates
  - Community guidelines
  - Platform news
- **User Settings**: Individually controllable
- **Default**: Enabled

#### 5. **⏰ Reminders (`reminder`)**
- **Purpose**: Scheduled reminders and follow-ups
- **Triggers**:
  - Follow-up on pending reports
  - Scheduled maintenance reminders
  - Action item reminders
  - Deadline notifications
- **User Settings**: Individually controllable
- **Default**: Disabled

## 🎯 Priority System

### Four-Level Priority Classification

#### 1. **🟢 Low Priority**
- Non-urgent informational notifications
- Feature updates and tips
- Community highlights
- Optional reminders

#### 2. **🟡 Normal Priority**
- Standard operational notifications
- Comment responses
- Regular status updates
- General announcements

#### 3. **🟠 High Priority**
- Important status changes
- Report approvals/rejections
- Administrative messages
- Time-sensitive updates

#### 4. **🔴 Urgent Priority**
- Critical system alerts
- Security notifications
- Emergency maintenance
- Immediate action required

### Priority-Based Behavior
- **Sound & Vibration**: Higher priority notifications have distinct alert patterns
- **Display Time**: Urgent notifications persist longer
- **Interrupt Level**: Higher priority can bypass Do Not Disturb settings
- **Visual Indicators**: Color-coded priority indicators

## 📱 Notification Models

### Core Data Structure (`app_notification.dart`)

```dart
class AppNotification {
  String id;                           // Unique identifier
  String title;                        // Notification title
  String body;                         // Notification content
  NotificationType type;               // Category classification
  NotificationPriority priority;       // Urgency level
  DateTime createdAt;                  // Creation timestamp
  
  bool isRead;                         // Read status
  String? icon;                        // Custom icon
  String? imageUrl;                    // Rich media image
  Map<String, dynamic>? data;          // Additional metadata
  List<NotificationAction>? actions;   // Action buttons
  DateTime? expiresAt;                 // Expiration time
  DateTime? readAt;                    // Read timestamp
  
  // Relationship Data
  String? relatedId;                   // Related entity ID
  String? relatedType;                 // Related entity type
  
  // Sender Information
  String? senderId;                    // Sender user ID
  String? senderName;                  // Sender display name
  String? senderAvatar;                // Sender profile image
}
```

### Smart Features
- **Expiration Check**: Automatic expiration detection
- **Recency Detection**: Identifies recent notifications (24h)
- **Relative Time Display**: User-friendly time formatting (Korean)
- **Rich Metadata**: Extensible data structure

## ⚙️ Notification Settings

### Comprehensive Settings Management (`notification_settings.dart`)

#### Basic Configuration
- **Global Toggle**: Master notification enable/disable
- **Push Notifications**: FCM remote notifications
- **In-App Notifications**: Real-time WebSocket notifications
- **Email Notifications**: Server-side email delivery

#### Sensory Settings
- **Sound**: Audio notification alerts
- **Vibration**: Haptic feedback
- **LED Indicator**: Visual light notifications

#### Type-Specific Controls
- Individual toggles for each notification type
- Granular control over notification categories
- User-customizable preferences

#### Advanced Features

##### **🔕 Quiet Hours**
- **Start Time**: Configurable quiet period start
- **End Time**: Configurable quiet period end
- **Smart Detection**: Automatic time zone handling
- **Cross-Day Support**: Handles quiet hours spanning midnight

##### **📊 Smart Filtering**
- **Minimum Priority**: Filter by priority level
- **Daily Limits**: Maximum notifications per day
- **Grouping**: Intelligent notification clustering
- **Deduplication**: Prevents notification spam

#### Technical Integration
- **FCM Token Management**: Secure token storage and refresh
- **Settings Sync**: Server-side settings synchronization
- **Last Updated Tracking**: Change history

## 🚀 Push Notification Service

### Firebase Cloud Messaging Integration (`push_notification_service.dart`)

#### Core Features

##### **🔧 Service Initialization**
- **Firebase Setup**: Automatic Firebase app initialization
- **Permission Management**: Intelligent permission requests
- **Channel Configuration**: Android notification channels
- **Background Handler**: Background message processing

##### **📋 Token Management**
- **Token Generation**: Secure FCM token creation
- **Token Refresh**: Automatic token renewal
- **Token Storage**: Encrypted local storage
- **Token Sync**: Server synchronization

##### **🎯 Topic Subscriptions**
- **Dynamic Subscriptions**: Runtime topic management
- **Group Notifications**: Topic-based message delivery
- **Targeted Messaging**: User segment targeting
- **Subscription Sync**: Cross-device synchronization

##### **📊 Local Notification Display**
- **Rich Notifications**: Images, actions, and custom layouts
- **Priority Mapping**: Priority-based display behavior
- **Action Buttons**: Interactive notification actions
- **Scheduling**: Time-based notification delivery

#### Advanced Capabilities

##### **🔒 Permission Handling**
- **Runtime Requests**: Dynamic permission management
- **Platform-Specific**: iOS/Android specific implementations
- **Graceful Degradation**: Fallback behavior
- **Status Monitoring**: Permission state tracking

##### **📱 Platform Integration**
- **Android Channels**: Custom notification channels
- **iOS Extensions**: Rich notification support
- **Background Processing**: Background app refresh
- **Deep Linking**: Navigation from notifications

##### **🎨 Rich Media Support**
- **Images**: Large image display
- **Big Text**: Expandable text content
- **Action Buttons**: Custom action handling
- **Grouping**: Related notification clustering

#### Message Flow
```
Remote Server → FCM → Device → Background Handler → Local Display
                                      ↓
                               Foreground Handler → In-App Display
```

## 🎮 Notification Controller

### State Management (`notification_controller.dart`)

#### Comprehensive State Management
- **Riverpod Integration**: Reactive state management
- **Stream Handling**: Real-time data streams
- **Error Recovery**: Robust error handling
- **Cache Management**: Offline notification storage

#### Key Functionalities

##### **📊 Notification CRUD Operations**
- **Mark as Read**: Individual and bulk read operations
- **Delete Notifications**: Safe deletion with confirmation
- **Filter Notifications**: Multi-criteria filtering
- **Search Functionality**: Content-based search

##### **⚡ Real-Time Features**
- **WebSocket Connection**: Live notification streaming
- **Connection Monitoring**: Connection status tracking
- **Auto-Reconnection**: Intelligent reconnection logic
- **Offline Support**: Queue management for offline notifications

##### **📈 Analytics & Statistics**
- **Delivery Metrics**: Success/failure tracking
- **Engagement Analytics**: Read rates and interaction metrics
- **Performance Monitoring**: Service health metrics
- **Usage Patterns**: User behavior analysis

#### Stream Management
The controller manages multiple data streams:
- **Notification Stream**: Real-time notification delivery
- **Connection Stream**: WebSocket status updates
- **Push Stream**: FCM message handling
- **Token Stream**: FCM token updates
- **Error Stream**: Error event handling

## 🔧 Technical Implementation

### Architecture Patterns
- **Clean Architecture**: Separation of concerns
- **Repository Pattern**: Data access abstraction
- **Observer Pattern**: Event-driven updates
- **Stream Processing**: Reactive programming

### Performance Optimization
- **Lazy Loading**: Load notifications on demand
- **Caching Strategy**: Intelligent local caching
- **Memory Management**: Efficient resource handling
- **Background Processing**: Non-blocking operations

### Security Features
- **Token Encryption**: Secure FCM token storage
- **Message Validation**: Content security validation
- **Permission Management**: Respectful permission handling
- **Data Privacy**: GDPR-compliant data handling

## 📊 Notification Features Summary

### User Experience
1. **📱 Multi-Platform**: Consistent experience across iOS/Android
2. **🎨 Rich Content**: Images, actions, and custom formatting
3. **⚡ Real-Time**: Instant notification delivery
4. **🔕 Smart Controls**: Intelligent filtering and quiet hours
5. **📖 Read Tracking**: Comprehensive read status management

### Developer Experience
1. **🏗️ Modular Design**: Easy to extend and maintain
2. **🧪 Testable**: Comprehensive testing support
3. **📝 Well Documented**: Clear API documentation
4. **🔧 Configurable**: Flexible configuration options
5. **📊 Observable**: Rich analytics and monitoring

### Business Features
1. **📈 Analytics**: Detailed engagement metrics
2. **🎯 Targeting**: User segment targeting
3. **📢 Broadcasting**: Topic-based messaging
4. **⏰ Scheduling**: Time-based delivery
5. **🔄 Integration**: Server-side integration APIs

## 🚀 Integration Points

### Backend Integration
- **REST APIs**: Standard HTTP notification endpoints
- **WebSocket**: Real-time bidirectional communication
- **FCM Server**: Firebase Cloud Messaging integration
- **Database Sync**: Notification persistence

### Mobile Platform Integration
- **iOS Integration**: Native iOS notification features
- **Android Integration**: Android notification channels
- **Permission APIs**: Platform permission management
- **Background Processing**: Platform background tasks

## 🎯 Key Advantages

1. **🔄 Real-Time Delivery**: Instant notification processing
2. **🎨 Rich Experience**: Multimedia notification support
3. **🔧 Flexible Configuration**: Comprehensive user controls
4. **📊 Analytics Ready**: Built-in analytics support
5. **🔒 Secure by Design**: Privacy and security first
6. **⚡ High Performance**: Optimized for scale
7. **🌐 Cross-Platform**: Universal mobile support
8. **🔌 Easy Integration**: Simple API integration

This comprehensive notification system provides a robust, scalable, and user-friendly communication platform that enhances user engagement while respecting user preferences and privacy. The multi-channel approach ensures reliable message delivery across all scenarios, from real-time in-app notifications to background push messages.