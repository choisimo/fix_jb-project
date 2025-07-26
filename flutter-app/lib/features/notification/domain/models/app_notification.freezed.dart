// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_notification.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AppNotification _$AppNotificationFromJson(Map<String, dynamic> json) {
  return _AppNotification.fromJson(json);
}

/// @nodoc
mixin _$AppNotification {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get body => throw _privateConstructorUsedError;
  NotificationType get type => throw _privateConstructorUsedError;
  NotificationPriority get priority => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  bool get isRead => throw _privateConstructorUsedError;
  String? get icon => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  Map<String, dynamic>? get data => throw _privateConstructorUsedError;
  List<NotificationAction>? get actions => throw _privateConstructorUsedError;
  DateTime? get expiresAt => throw _privateConstructorUsedError;
  DateTime? get readAt =>
      throw _privateConstructorUsedError; // 관련 리소스 ID (리포트 ID, 댓글 ID 등)
  String? get relatedId => throw _privateConstructorUsedError;
  String? get relatedType => throw _privateConstructorUsedError; // 발신자 정보
  String? get senderId => throw _privateConstructorUsedError;
  String? get senderName => throw _privateConstructorUsedError;
  String? get senderAvatar => throw _privateConstructorUsedError;

  /// Serializes this AppNotification to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AppNotification
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AppNotificationCopyWith<AppNotification> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppNotificationCopyWith<$Res> {
  factory $AppNotificationCopyWith(
          AppNotification value, $Res Function(AppNotification) then) =
      _$AppNotificationCopyWithImpl<$Res, AppNotification>;
  @useResult
  $Res call(
      {String id,
      String title,
      String body,
      NotificationType type,
      NotificationPriority priority,
      DateTime createdAt,
      bool isRead,
      String? icon,
      String? imageUrl,
      Map<String, dynamic>? data,
      List<NotificationAction>? actions,
      DateTime? expiresAt,
      DateTime? readAt,
      String? relatedId,
      String? relatedType,
      String? senderId,
      String? senderName,
      String? senderAvatar});
}

/// @nodoc
class _$AppNotificationCopyWithImpl<$Res, $Val extends AppNotification>
    implements $AppNotificationCopyWith<$Res> {
  _$AppNotificationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AppNotification
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? body = null,
    Object? type = null,
    Object? priority = null,
    Object? createdAt = null,
    Object? isRead = null,
    Object? icon = freezed,
    Object? imageUrl = freezed,
    Object? data = freezed,
    Object? actions = freezed,
    Object? expiresAt = freezed,
    Object? readAt = freezed,
    Object? relatedId = freezed,
    Object? relatedType = freezed,
    Object? senderId = freezed,
    Object? senderName = freezed,
    Object? senderAvatar = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      body: null == body
          ? _value.body
          : body // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as NotificationType,
      priority: null == priority
          ? _value.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as NotificationPriority,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isRead: null == isRead
          ? _value.isRead
          : isRead // ignore: cast_nullable_to_non_nullable
              as bool,
      icon: freezed == icon
          ? _value.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      data: freezed == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      actions: freezed == actions
          ? _value.actions
          : actions // ignore: cast_nullable_to_non_nullable
              as List<NotificationAction>?,
      expiresAt: freezed == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      readAt: freezed == readAt
          ? _value.readAt
          : readAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      relatedId: freezed == relatedId
          ? _value.relatedId
          : relatedId // ignore: cast_nullable_to_non_nullable
              as String?,
      relatedType: freezed == relatedType
          ? _value.relatedType
          : relatedType // ignore: cast_nullable_to_non_nullable
              as String?,
      senderId: freezed == senderId
          ? _value.senderId
          : senderId // ignore: cast_nullable_to_non_nullable
              as String?,
      senderName: freezed == senderName
          ? _value.senderName
          : senderName // ignore: cast_nullable_to_non_nullable
              as String?,
      senderAvatar: freezed == senderAvatar
          ? _value.senderAvatar
          : senderAvatar // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AppNotificationImplCopyWith<$Res>
    implements $AppNotificationCopyWith<$Res> {
  factory _$$AppNotificationImplCopyWith(_$AppNotificationImpl value,
          $Res Function(_$AppNotificationImpl) then) =
      __$$AppNotificationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      String body,
      NotificationType type,
      NotificationPriority priority,
      DateTime createdAt,
      bool isRead,
      String? icon,
      String? imageUrl,
      Map<String, dynamic>? data,
      List<NotificationAction>? actions,
      DateTime? expiresAt,
      DateTime? readAt,
      String? relatedId,
      String? relatedType,
      String? senderId,
      String? senderName,
      String? senderAvatar});
}

/// @nodoc
class __$$AppNotificationImplCopyWithImpl<$Res>
    extends _$AppNotificationCopyWithImpl<$Res, _$AppNotificationImpl>
    implements _$$AppNotificationImplCopyWith<$Res> {
  __$$AppNotificationImplCopyWithImpl(
      _$AppNotificationImpl _value, $Res Function(_$AppNotificationImpl) _then)
      : super(_value, _then);

  /// Create a copy of AppNotification
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? body = null,
    Object? type = null,
    Object? priority = null,
    Object? createdAt = null,
    Object? isRead = null,
    Object? icon = freezed,
    Object? imageUrl = freezed,
    Object? data = freezed,
    Object? actions = freezed,
    Object? expiresAt = freezed,
    Object? readAt = freezed,
    Object? relatedId = freezed,
    Object? relatedType = freezed,
    Object? senderId = freezed,
    Object? senderName = freezed,
    Object? senderAvatar = freezed,
  }) {
    return _then(_$AppNotificationImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      body: null == body
          ? _value.body
          : body // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as NotificationType,
      priority: null == priority
          ? _value.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as NotificationPriority,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isRead: null == isRead
          ? _value.isRead
          : isRead // ignore: cast_nullable_to_non_nullable
              as bool,
      icon: freezed == icon
          ? _value.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      data: freezed == data
          ? _value._data
          : data // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      actions: freezed == actions
          ? _value._actions
          : actions // ignore: cast_nullable_to_non_nullable
              as List<NotificationAction>?,
      expiresAt: freezed == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      readAt: freezed == readAt
          ? _value.readAt
          : readAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      relatedId: freezed == relatedId
          ? _value.relatedId
          : relatedId // ignore: cast_nullable_to_non_nullable
              as String?,
      relatedType: freezed == relatedType
          ? _value.relatedType
          : relatedType // ignore: cast_nullable_to_non_nullable
              as String?,
      senderId: freezed == senderId
          ? _value.senderId
          : senderId // ignore: cast_nullable_to_non_nullable
              as String?,
      senderName: freezed == senderName
          ? _value.senderName
          : senderName // ignore: cast_nullable_to_non_nullable
              as String?,
      senderAvatar: freezed == senderAvatar
          ? _value.senderAvatar
          : senderAvatar // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AppNotificationImpl extends _AppNotification {
  const _$AppNotificationImpl(
      {required this.id,
      required this.title,
      required this.body,
      required this.type,
      required this.priority,
      required this.createdAt,
      this.isRead = false,
      this.icon,
      this.imageUrl,
      final Map<String, dynamic>? data,
      final List<NotificationAction>? actions,
      this.expiresAt,
      this.readAt,
      this.relatedId,
      this.relatedType,
      this.senderId,
      this.senderName,
      this.senderAvatar})
      : _data = data,
        _actions = actions,
        super._();

  factory _$AppNotificationImpl.fromJson(Map<String, dynamic> json) =>
      _$$AppNotificationImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String body;
  @override
  final NotificationType type;
  @override
  final NotificationPriority priority;
  @override
  final DateTime createdAt;
  @override
  @JsonKey()
  final bool isRead;
  @override
  final String? icon;
  @override
  final String? imageUrl;
  final Map<String, dynamic>? _data;
  @override
  Map<String, dynamic>? get data {
    final value = _data;
    if (value == null) return null;
    if (_data is EqualUnmodifiableMapView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final List<NotificationAction>? _actions;
  @override
  List<NotificationAction>? get actions {
    final value = _actions;
    if (value == null) return null;
    if (_actions is EqualUnmodifiableListView) return _actions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final DateTime? expiresAt;
  @override
  final DateTime? readAt;
// 관련 리소스 ID (리포트 ID, 댓글 ID 등)
  @override
  final String? relatedId;
  @override
  final String? relatedType;
// 발신자 정보
  @override
  final String? senderId;
  @override
  final String? senderName;
  @override
  final String? senderAvatar;

  @override
  String toString() {
    return 'AppNotification(id: $id, title: $title, body: $body, type: $type, priority: $priority, createdAt: $createdAt, isRead: $isRead, icon: $icon, imageUrl: $imageUrl, data: $data, actions: $actions, expiresAt: $expiresAt, readAt: $readAt, relatedId: $relatedId, relatedType: $relatedType, senderId: $senderId, senderName: $senderName, senderAvatar: $senderAvatar)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AppNotificationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.body, body) || other.body == body) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.isRead, isRead) || other.isRead == isRead) &&
            (identical(other.icon, icon) || other.icon == icon) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            const DeepCollectionEquality().equals(other._data, _data) &&
            const DeepCollectionEquality().equals(other._actions, _actions) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt) &&
            (identical(other.readAt, readAt) || other.readAt == readAt) &&
            (identical(other.relatedId, relatedId) ||
                other.relatedId == relatedId) &&
            (identical(other.relatedType, relatedType) ||
                other.relatedType == relatedType) &&
            (identical(other.senderId, senderId) ||
                other.senderId == senderId) &&
            (identical(other.senderName, senderName) ||
                other.senderName == senderName) &&
            (identical(other.senderAvatar, senderAvatar) ||
                other.senderAvatar == senderAvatar));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      body,
      type,
      priority,
      createdAt,
      isRead,
      icon,
      imageUrl,
      const DeepCollectionEquality().hash(_data),
      const DeepCollectionEquality().hash(_actions),
      expiresAt,
      readAt,
      relatedId,
      relatedType,
      senderId,
      senderName,
      senderAvatar);

  /// Create a copy of AppNotification
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AppNotificationImplCopyWith<_$AppNotificationImpl> get copyWith =>
      __$$AppNotificationImplCopyWithImpl<_$AppNotificationImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AppNotificationImplToJson(
      this,
    );
  }
}

abstract class _AppNotification extends AppNotification {
  const factory _AppNotification(
      {required final String id,
      required final String title,
      required final String body,
      required final NotificationType type,
      required final NotificationPriority priority,
      required final DateTime createdAt,
      final bool isRead,
      final String? icon,
      final String? imageUrl,
      final Map<String, dynamic>? data,
      final List<NotificationAction>? actions,
      final DateTime? expiresAt,
      final DateTime? readAt,
      final String? relatedId,
      final String? relatedType,
      final String? senderId,
      final String? senderName,
      final String? senderAvatar}) = _$AppNotificationImpl;
  const _AppNotification._() : super._();

  factory _AppNotification.fromJson(Map<String, dynamic> json) =
      _$AppNotificationImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get body;
  @override
  NotificationType get type;
  @override
  NotificationPriority get priority;
  @override
  DateTime get createdAt;
  @override
  bool get isRead;
  @override
  String? get icon;
  @override
  String? get imageUrl;
  @override
  Map<String, dynamic>? get data;
  @override
  List<NotificationAction>? get actions;
  @override
  DateTime? get expiresAt;
  @override
  DateTime? get readAt; // 관련 리소스 ID (리포트 ID, 댓글 ID 등)
  @override
  String? get relatedId;
  @override
  String? get relatedType; // 발신자 정보
  @override
  String? get senderId;
  @override
  String? get senderName;
  @override
  String? get senderAvatar;

  /// Create a copy of AppNotification
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AppNotificationImplCopyWith<_$AppNotificationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

NotificationFilter _$NotificationFilterFromJson(Map<String, dynamic> json) {
  return _NotificationFilter.fromJson(json);
}

/// @nodoc
mixin _$NotificationFilter {
  bool get showReadOnly => throw _privateConstructorUsedError;
  bool get showUnreadOnly => throw _privateConstructorUsedError;
  NotificationType? get type => throw _privateConstructorUsedError;
  NotificationPriority? get priority => throw _privateConstructorUsedError;
  DateTime? get fromDate => throw _privateConstructorUsedError;
  DateTime? get toDate => throw _privateConstructorUsedError;
  int get limit => throw _privateConstructorUsedError;
  int get offset => throw _privateConstructorUsedError;

  /// Serializes this NotificationFilter to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NotificationFilter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NotificationFilterCopyWith<NotificationFilter> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotificationFilterCopyWith<$Res> {
  factory $NotificationFilterCopyWith(
          NotificationFilter value, $Res Function(NotificationFilter) then) =
      _$NotificationFilterCopyWithImpl<$Res, NotificationFilter>;
  @useResult
  $Res call(
      {bool showReadOnly,
      bool showUnreadOnly,
      NotificationType? type,
      NotificationPriority? priority,
      DateTime? fromDate,
      DateTime? toDate,
      int limit,
      int offset});
}

/// @nodoc
class _$NotificationFilterCopyWithImpl<$Res, $Val extends NotificationFilter>
    implements $NotificationFilterCopyWith<$Res> {
  _$NotificationFilterCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NotificationFilter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? showReadOnly = null,
    Object? showUnreadOnly = null,
    Object? type = freezed,
    Object? priority = freezed,
    Object? fromDate = freezed,
    Object? toDate = freezed,
    Object? limit = null,
    Object? offset = null,
  }) {
    return _then(_value.copyWith(
      showReadOnly: null == showReadOnly
          ? _value.showReadOnly
          : showReadOnly // ignore: cast_nullable_to_non_nullable
              as bool,
      showUnreadOnly: null == showUnreadOnly
          ? _value.showUnreadOnly
          : showUnreadOnly // ignore: cast_nullable_to_non_nullable
              as bool,
      type: freezed == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as NotificationType?,
      priority: freezed == priority
          ? _value.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as NotificationPriority?,
      fromDate: freezed == fromDate
          ? _value.fromDate
          : fromDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      toDate: freezed == toDate
          ? _value.toDate
          : toDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      limit: null == limit
          ? _value.limit
          : limit // ignore: cast_nullable_to_non_nullable
              as int,
      offset: null == offset
          ? _value.offset
          : offset // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$NotificationFilterImplCopyWith<$Res>
    implements $NotificationFilterCopyWith<$Res> {
  factory _$$NotificationFilterImplCopyWith(_$NotificationFilterImpl value,
          $Res Function(_$NotificationFilterImpl) then) =
      __$$NotificationFilterImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool showReadOnly,
      bool showUnreadOnly,
      NotificationType? type,
      NotificationPriority? priority,
      DateTime? fromDate,
      DateTime? toDate,
      int limit,
      int offset});
}

/// @nodoc
class __$$NotificationFilterImplCopyWithImpl<$Res>
    extends _$NotificationFilterCopyWithImpl<$Res, _$NotificationFilterImpl>
    implements _$$NotificationFilterImplCopyWith<$Res> {
  __$$NotificationFilterImplCopyWithImpl(_$NotificationFilterImpl _value,
      $Res Function(_$NotificationFilterImpl) _then)
      : super(_value, _then);

  /// Create a copy of NotificationFilter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? showReadOnly = null,
    Object? showUnreadOnly = null,
    Object? type = freezed,
    Object? priority = freezed,
    Object? fromDate = freezed,
    Object? toDate = freezed,
    Object? limit = null,
    Object? offset = null,
  }) {
    return _then(_$NotificationFilterImpl(
      showReadOnly: null == showReadOnly
          ? _value.showReadOnly
          : showReadOnly // ignore: cast_nullable_to_non_nullable
              as bool,
      showUnreadOnly: null == showUnreadOnly
          ? _value.showUnreadOnly
          : showUnreadOnly // ignore: cast_nullable_to_non_nullable
              as bool,
      type: freezed == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as NotificationType?,
      priority: freezed == priority
          ? _value.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as NotificationPriority?,
      fromDate: freezed == fromDate
          ? _value.fromDate
          : fromDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      toDate: freezed == toDate
          ? _value.toDate
          : toDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      limit: null == limit
          ? _value.limit
          : limit // ignore: cast_nullable_to_non_nullable
              as int,
      offset: null == offset
          ? _value.offset
          : offset // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$NotificationFilterImpl implements _NotificationFilter {
  const _$NotificationFilterImpl(
      {this.showReadOnly = false,
      this.showUnreadOnly = false,
      this.type,
      this.priority,
      this.fromDate,
      this.toDate,
      this.limit = 20,
      this.offset = 0});

  factory _$NotificationFilterImpl.fromJson(Map<String, dynamic> json) =>
      _$$NotificationFilterImplFromJson(json);

  @override
  @JsonKey()
  final bool showReadOnly;
  @override
  @JsonKey()
  final bool showUnreadOnly;
  @override
  final NotificationType? type;
  @override
  final NotificationPriority? priority;
  @override
  final DateTime? fromDate;
  @override
  final DateTime? toDate;
  @override
  @JsonKey()
  final int limit;
  @override
  @JsonKey()
  final int offset;

  @override
  String toString() {
    return 'NotificationFilter(showReadOnly: $showReadOnly, showUnreadOnly: $showUnreadOnly, type: $type, priority: $priority, fromDate: $fromDate, toDate: $toDate, limit: $limit, offset: $offset)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationFilterImpl &&
            (identical(other.showReadOnly, showReadOnly) ||
                other.showReadOnly == showReadOnly) &&
            (identical(other.showUnreadOnly, showUnreadOnly) ||
                other.showUnreadOnly == showUnreadOnly) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            (identical(other.fromDate, fromDate) ||
                other.fromDate == fromDate) &&
            (identical(other.toDate, toDate) || other.toDate == toDate) &&
            (identical(other.limit, limit) || other.limit == limit) &&
            (identical(other.offset, offset) || other.offset == offset));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, showReadOnly, showUnreadOnly,
      type, priority, fromDate, toDate, limit, offset);

  /// Create a copy of NotificationFilter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NotificationFilterImplCopyWith<_$NotificationFilterImpl> get copyWith =>
      __$$NotificationFilterImplCopyWithImpl<_$NotificationFilterImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NotificationFilterImplToJson(
      this,
    );
  }
}

abstract class _NotificationFilter implements NotificationFilter {
  const factory _NotificationFilter(
      {final bool showReadOnly,
      final bool showUnreadOnly,
      final NotificationType? type,
      final NotificationPriority? priority,
      final DateTime? fromDate,
      final DateTime? toDate,
      final int limit,
      final int offset}) = _$NotificationFilterImpl;

  factory _NotificationFilter.fromJson(Map<String, dynamic> json) =
      _$NotificationFilterImpl.fromJson;

  @override
  bool get showReadOnly;
  @override
  bool get showUnreadOnly;
  @override
  NotificationType? get type;
  @override
  NotificationPriority? get priority;
  @override
  DateTime? get fromDate;
  @override
  DateTime? get toDate;
  @override
  int get limit;
  @override
  int get offset;

  /// Create a copy of NotificationFilter
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NotificationFilterImplCopyWith<_$NotificationFilterImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
