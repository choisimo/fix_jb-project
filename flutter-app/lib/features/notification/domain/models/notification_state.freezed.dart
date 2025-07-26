// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

NotificationState _$NotificationStateFromJson(Map<String, dynamic> json) {
  return _NotificationState.fromJson(json);
}

/// @nodoc
mixin _$NotificationState {
  List<AppNotification> get notifications => throw _privateConstructorUsedError;
  int get unreadCount => throw _privateConstructorUsedError;
  bool get isConnected => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  bool get isInitializing => throw _privateConstructorUsedError;
  NotificationSettings? get settings => throw _privateConstructorUsedError;
  ConnectionStatus get connectionStatus => throw _privateConstructorUsedError;
  List<AppNotification> get recentNotifications =>
      throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;
  DateTime? get lastSync => throw _privateConstructorUsedError;
  bool get hasPendingNotifications => throw _privateConstructorUsedError;
  String? get fcmToken => throw _privateConstructorUsedError;

  /// Serializes this NotificationState to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NotificationState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NotificationStateCopyWith<NotificationState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotificationStateCopyWith<$Res> {
  factory $NotificationStateCopyWith(
          NotificationState value, $Res Function(NotificationState) then) =
      _$NotificationStateCopyWithImpl<$Res, NotificationState>;
  @useResult
  $Res call(
      {List<AppNotification> notifications,
      int unreadCount,
      bool isConnected,
      bool isLoading,
      bool isInitializing,
      NotificationSettings? settings,
      ConnectionStatus connectionStatus,
      List<AppNotification> recentNotifications,
      String? error,
      DateTime? lastSync,
      bool hasPendingNotifications,
      String? fcmToken});

  $NotificationSettingsCopyWith<$Res>? get settings;
}

/// @nodoc
class _$NotificationStateCopyWithImpl<$Res, $Val extends NotificationState>
    implements $NotificationStateCopyWith<$Res> {
  _$NotificationStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NotificationState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? notifications = null,
    Object? unreadCount = null,
    Object? isConnected = null,
    Object? isLoading = null,
    Object? isInitializing = null,
    Object? settings = freezed,
    Object? connectionStatus = null,
    Object? recentNotifications = null,
    Object? error = freezed,
    Object? lastSync = freezed,
    Object? hasPendingNotifications = null,
    Object? fcmToken = freezed,
  }) {
    return _then(_value.copyWith(
      notifications: null == notifications
          ? _value.notifications
          : notifications // ignore: cast_nullable_to_non_nullable
              as List<AppNotification>,
      unreadCount: null == unreadCount
          ? _value.unreadCount
          : unreadCount // ignore: cast_nullable_to_non_nullable
              as int,
      isConnected: null == isConnected
          ? _value.isConnected
          : isConnected // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isInitializing: null == isInitializing
          ? _value.isInitializing
          : isInitializing // ignore: cast_nullable_to_non_nullable
              as bool,
      settings: freezed == settings
          ? _value.settings
          : settings // ignore: cast_nullable_to_non_nullable
              as NotificationSettings?,
      connectionStatus: null == connectionStatus
          ? _value.connectionStatus
          : connectionStatus // ignore: cast_nullable_to_non_nullable
              as ConnectionStatus,
      recentNotifications: null == recentNotifications
          ? _value.recentNotifications
          : recentNotifications // ignore: cast_nullable_to_non_nullable
              as List<AppNotification>,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      lastSync: freezed == lastSync
          ? _value.lastSync
          : lastSync // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      hasPendingNotifications: null == hasPendingNotifications
          ? _value.hasPendingNotifications
          : hasPendingNotifications // ignore: cast_nullable_to_non_nullable
              as bool,
      fcmToken: freezed == fcmToken
          ? _value.fcmToken
          : fcmToken // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  /// Create a copy of NotificationState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $NotificationSettingsCopyWith<$Res>? get settings {
    if (_value.settings == null) {
      return null;
    }

    return $NotificationSettingsCopyWith<$Res>(_value.settings!, (value) {
      return _then(_value.copyWith(settings: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$NotificationStateImplCopyWith<$Res>
    implements $NotificationStateCopyWith<$Res> {
  factory _$$NotificationStateImplCopyWith(_$NotificationStateImpl value,
          $Res Function(_$NotificationStateImpl) then) =
      __$$NotificationStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<AppNotification> notifications,
      int unreadCount,
      bool isConnected,
      bool isLoading,
      bool isInitializing,
      NotificationSettings? settings,
      ConnectionStatus connectionStatus,
      List<AppNotification> recentNotifications,
      String? error,
      DateTime? lastSync,
      bool hasPendingNotifications,
      String? fcmToken});

  @override
  $NotificationSettingsCopyWith<$Res>? get settings;
}

/// @nodoc
class __$$NotificationStateImplCopyWithImpl<$Res>
    extends _$NotificationStateCopyWithImpl<$Res, _$NotificationStateImpl>
    implements _$$NotificationStateImplCopyWith<$Res> {
  __$$NotificationStateImplCopyWithImpl(_$NotificationStateImpl _value,
      $Res Function(_$NotificationStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of NotificationState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? notifications = null,
    Object? unreadCount = null,
    Object? isConnected = null,
    Object? isLoading = null,
    Object? isInitializing = null,
    Object? settings = freezed,
    Object? connectionStatus = null,
    Object? recentNotifications = null,
    Object? error = freezed,
    Object? lastSync = freezed,
    Object? hasPendingNotifications = null,
    Object? fcmToken = freezed,
  }) {
    return _then(_$NotificationStateImpl(
      notifications: null == notifications
          ? _value._notifications
          : notifications // ignore: cast_nullable_to_non_nullable
              as List<AppNotification>,
      unreadCount: null == unreadCount
          ? _value.unreadCount
          : unreadCount // ignore: cast_nullable_to_non_nullable
              as int,
      isConnected: null == isConnected
          ? _value.isConnected
          : isConnected // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isInitializing: null == isInitializing
          ? _value.isInitializing
          : isInitializing // ignore: cast_nullable_to_non_nullable
              as bool,
      settings: freezed == settings
          ? _value.settings
          : settings // ignore: cast_nullable_to_non_nullable
              as NotificationSettings?,
      connectionStatus: null == connectionStatus
          ? _value.connectionStatus
          : connectionStatus // ignore: cast_nullable_to_non_nullable
              as ConnectionStatus,
      recentNotifications: null == recentNotifications
          ? _value._recentNotifications
          : recentNotifications // ignore: cast_nullable_to_non_nullable
              as List<AppNotification>,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      lastSync: freezed == lastSync
          ? _value.lastSync
          : lastSync // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      hasPendingNotifications: null == hasPendingNotifications
          ? _value.hasPendingNotifications
          : hasPendingNotifications // ignore: cast_nullable_to_non_nullable
              as bool,
      fcmToken: freezed == fcmToken
          ? _value.fcmToken
          : fcmToken // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$NotificationStateImpl implements _NotificationState {
  const _$NotificationStateImpl(
      {final List<AppNotification> notifications = const [],
      this.unreadCount = 0,
      this.isConnected = false,
      this.isLoading = false,
      this.isInitializing = false,
      this.settings,
      this.connectionStatus = ConnectionStatus.disconnected,
      final List<AppNotification> recentNotifications = const [],
      this.error,
      this.lastSync,
      this.hasPendingNotifications = false,
      this.fcmToken})
      : _notifications = notifications,
        _recentNotifications = recentNotifications;

  factory _$NotificationStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$NotificationStateImplFromJson(json);

  final List<AppNotification> _notifications;
  @override
  @JsonKey()
  List<AppNotification> get notifications {
    if (_notifications is EqualUnmodifiableListView) return _notifications;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_notifications);
  }

  @override
  @JsonKey()
  final int unreadCount;
  @override
  @JsonKey()
  final bool isConnected;
  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final bool isInitializing;
  @override
  final NotificationSettings? settings;
  @override
  @JsonKey()
  final ConnectionStatus connectionStatus;
  final List<AppNotification> _recentNotifications;
  @override
  @JsonKey()
  List<AppNotification> get recentNotifications {
    if (_recentNotifications is EqualUnmodifiableListView)
      return _recentNotifications;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recentNotifications);
  }

  @override
  final String? error;
  @override
  final DateTime? lastSync;
  @override
  @JsonKey()
  final bool hasPendingNotifications;
  @override
  final String? fcmToken;

  @override
  String toString() {
    return 'NotificationState(notifications: $notifications, unreadCount: $unreadCount, isConnected: $isConnected, isLoading: $isLoading, isInitializing: $isInitializing, settings: $settings, connectionStatus: $connectionStatus, recentNotifications: $recentNotifications, error: $error, lastSync: $lastSync, hasPendingNotifications: $hasPendingNotifications, fcmToken: $fcmToken)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationStateImpl &&
            const DeepCollectionEquality()
                .equals(other._notifications, _notifications) &&
            (identical(other.unreadCount, unreadCount) ||
                other.unreadCount == unreadCount) &&
            (identical(other.isConnected, isConnected) ||
                other.isConnected == isConnected) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.isInitializing, isInitializing) ||
                other.isInitializing == isInitializing) &&
            (identical(other.settings, settings) ||
                other.settings == settings) &&
            (identical(other.connectionStatus, connectionStatus) ||
                other.connectionStatus == connectionStatus) &&
            const DeepCollectionEquality()
                .equals(other._recentNotifications, _recentNotifications) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.lastSync, lastSync) ||
                other.lastSync == lastSync) &&
            (identical(
                    other.hasPendingNotifications, hasPendingNotifications) ||
                other.hasPendingNotifications == hasPendingNotifications) &&
            (identical(other.fcmToken, fcmToken) ||
                other.fcmToken == fcmToken));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_notifications),
      unreadCount,
      isConnected,
      isLoading,
      isInitializing,
      settings,
      connectionStatus,
      const DeepCollectionEquality().hash(_recentNotifications),
      error,
      lastSync,
      hasPendingNotifications,
      fcmToken);

  /// Create a copy of NotificationState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NotificationStateImplCopyWith<_$NotificationStateImpl> get copyWith =>
      __$$NotificationStateImplCopyWithImpl<_$NotificationStateImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NotificationStateImplToJson(
      this,
    );
  }
}

abstract class _NotificationState implements NotificationState {
  const factory _NotificationState(
      {final List<AppNotification> notifications,
      final int unreadCount,
      final bool isConnected,
      final bool isLoading,
      final bool isInitializing,
      final NotificationSettings? settings,
      final ConnectionStatus connectionStatus,
      final List<AppNotification> recentNotifications,
      final String? error,
      final DateTime? lastSync,
      final bool hasPendingNotifications,
      final String? fcmToken}) = _$NotificationStateImpl;

  factory _NotificationState.fromJson(Map<String, dynamic> json) =
      _$NotificationStateImpl.fromJson;

  @override
  List<AppNotification> get notifications;
  @override
  int get unreadCount;
  @override
  bool get isConnected;
  @override
  bool get isLoading;
  @override
  bool get isInitializing;
  @override
  NotificationSettings? get settings;
  @override
  ConnectionStatus get connectionStatus;
  @override
  List<AppNotification> get recentNotifications;
  @override
  String? get error;
  @override
  DateTime? get lastSync;
  @override
  bool get hasPendingNotifications;
  @override
  String? get fcmToken;

  /// Create a copy of NotificationState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NotificationStateImplCopyWith<_$NotificationStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
