// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'security_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SecurityEvent _$SecurityEventFromJson(Map<String, dynamic> json) {
  return _SecurityEvent.fromJson(json);
}

/// @nodoc
mixin _$SecurityEvent {
  String get id => throw _privateConstructorUsedError;
  SecurityEventType get type => throw _privateConstructorUsedError;
  SecurityLevel get level => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get ipAddress => throw _privateConstructorUsedError;
  String? get userAgent => throw _privateConstructorUsedError;
  String? get deviceId => throw _privateConstructorUsedError;
  String? get sessionId => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata =>
      throw _privateConstructorUsedError; // 위치 정보 (선택적)
  double? get latitude => throw _privateConstructorUsedError;
  double? get longitude => throw _privateConstructorUsedError;
  String? get location => throw _privateConstructorUsedError; // 처리 상태
  bool get isResolved => throw _privateConstructorUsedError;
  DateTime? get resolvedAt => throw _privateConstructorUsedError;
  String? get resolvedBy => throw _privateConstructorUsedError;
  String? get resolution => throw _privateConstructorUsedError;

  /// Serializes this SecurityEvent to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SecurityEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SecurityEventCopyWith<SecurityEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SecurityEventCopyWith<$Res> {
  factory $SecurityEventCopyWith(
          SecurityEvent value, $Res Function(SecurityEvent) then) =
      _$SecurityEventCopyWithImpl<$Res, SecurityEvent>;
  @useResult
  $Res call(
      {String id,
      SecurityEventType type,
      SecurityLevel level,
      DateTime timestamp,
      String userId,
      String? description,
      String? ipAddress,
      String? userAgent,
      String? deviceId,
      String? sessionId,
      Map<String, dynamic>? metadata,
      double? latitude,
      double? longitude,
      String? location,
      bool isResolved,
      DateTime? resolvedAt,
      String? resolvedBy,
      String? resolution});
}

/// @nodoc
class _$SecurityEventCopyWithImpl<$Res, $Val extends SecurityEvent>
    implements $SecurityEventCopyWith<$Res> {
  _$SecurityEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SecurityEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? level = null,
    Object? timestamp = null,
    Object? userId = null,
    Object? description = freezed,
    Object? ipAddress = freezed,
    Object? userAgent = freezed,
    Object? deviceId = freezed,
    Object? sessionId = freezed,
    Object? metadata = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? location = freezed,
    Object? isResolved = null,
    Object? resolvedAt = freezed,
    Object? resolvedBy = freezed,
    Object? resolution = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as SecurityEventType,
      level: null == level
          ? _value.level
          : level // ignore: cast_nullable_to_non_nullable
              as SecurityLevel,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      ipAddress: freezed == ipAddress
          ? _value.ipAddress
          : ipAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      userAgent: freezed == userAgent
          ? _value.userAgent
          : userAgent // ignore: cast_nullable_to_non_nullable
              as String?,
      deviceId: freezed == deviceId
          ? _value.deviceId
          : deviceId // ignore: cast_nullable_to_non_nullable
              as String?,
      sessionId: freezed == sessionId
          ? _value.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: freezed == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      latitude: freezed == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double?,
      longitude: freezed == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      isResolved: null == isResolved
          ? _value.isResolved
          : isResolved // ignore: cast_nullable_to_non_nullable
              as bool,
      resolvedAt: freezed == resolvedAt
          ? _value.resolvedAt
          : resolvedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      resolvedBy: freezed == resolvedBy
          ? _value.resolvedBy
          : resolvedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      resolution: freezed == resolution
          ? _value.resolution
          : resolution // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SecurityEventImplCopyWith<$Res>
    implements $SecurityEventCopyWith<$Res> {
  factory _$$SecurityEventImplCopyWith(
          _$SecurityEventImpl value, $Res Function(_$SecurityEventImpl) then) =
      __$$SecurityEventImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      SecurityEventType type,
      SecurityLevel level,
      DateTime timestamp,
      String userId,
      String? description,
      String? ipAddress,
      String? userAgent,
      String? deviceId,
      String? sessionId,
      Map<String, dynamic>? metadata,
      double? latitude,
      double? longitude,
      String? location,
      bool isResolved,
      DateTime? resolvedAt,
      String? resolvedBy,
      String? resolution});
}

/// @nodoc
class __$$SecurityEventImplCopyWithImpl<$Res>
    extends _$SecurityEventCopyWithImpl<$Res, _$SecurityEventImpl>
    implements _$$SecurityEventImplCopyWith<$Res> {
  __$$SecurityEventImplCopyWithImpl(
      _$SecurityEventImpl _value, $Res Function(_$SecurityEventImpl) _then)
      : super(_value, _then);

  /// Create a copy of SecurityEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? level = null,
    Object? timestamp = null,
    Object? userId = null,
    Object? description = freezed,
    Object? ipAddress = freezed,
    Object? userAgent = freezed,
    Object? deviceId = freezed,
    Object? sessionId = freezed,
    Object? metadata = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? location = freezed,
    Object? isResolved = null,
    Object? resolvedAt = freezed,
    Object? resolvedBy = freezed,
    Object? resolution = freezed,
  }) {
    return _then(_$SecurityEventImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as SecurityEventType,
      level: null == level
          ? _value.level
          : level // ignore: cast_nullable_to_non_nullable
              as SecurityLevel,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      ipAddress: freezed == ipAddress
          ? _value.ipAddress
          : ipAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      userAgent: freezed == userAgent
          ? _value.userAgent
          : userAgent // ignore: cast_nullable_to_non_nullable
              as String?,
      deviceId: freezed == deviceId
          ? _value.deviceId
          : deviceId // ignore: cast_nullable_to_non_nullable
              as String?,
      sessionId: freezed == sessionId
          ? _value.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: freezed == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      latitude: freezed == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double?,
      longitude: freezed == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      isResolved: null == isResolved
          ? _value.isResolved
          : isResolved // ignore: cast_nullable_to_non_nullable
              as bool,
      resolvedAt: freezed == resolvedAt
          ? _value.resolvedAt
          : resolvedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      resolvedBy: freezed == resolvedBy
          ? _value.resolvedBy
          : resolvedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      resolution: freezed == resolution
          ? _value.resolution
          : resolution // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SecurityEventImpl extends _SecurityEvent {
  const _$SecurityEventImpl(
      {required this.id,
      required this.type,
      required this.level,
      required this.timestamp,
      required this.userId,
      this.description,
      this.ipAddress,
      this.userAgent,
      this.deviceId,
      this.sessionId,
      final Map<String, dynamic>? metadata,
      this.latitude,
      this.longitude,
      this.location,
      this.isResolved = false,
      this.resolvedAt,
      this.resolvedBy,
      this.resolution})
      : _metadata = metadata,
        super._();

  factory _$SecurityEventImpl.fromJson(Map<String, dynamic> json) =>
      _$$SecurityEventImplFromJson(json);

  @override
  final String id;
  @override
  final SecurityEventType type;
  @override
  final SecurityLevel level;
  @override
  final DateTime timestamp;
  @override
  final String userId;
  @override
  final String? description;
  @override
  final String? ipAddress;
  @override
  final String? userAgent;
  @override
  final String? deviceId;
  @override
  final String? sessionId;
  final Map<String, dynamic>? _metadata;
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

// 위치 정보 (선택적)
  @override
  final double? latitude;
  @override
  final double? longitude;
  @override
  final String? location;
// 처리 상태
  @override
  @JsonKey()
  final bool isResolved;
  @override
  final DateTime? resolvedAt;
  @override
  final String? resolvedBy;
  @override
  final String? resolution;

  @override
  String toString() {
    return 'SecurityEvent(id: $id, type: $type, level: $level, timestamp: $timestamp, userId: $userId, description: $description, ipAddress: $ipAddress, userAgent: $userAgent, deviceId: $deviceId, sessionId: $sessionId, metadata: $metadata, latitude: $latitude, longitude: $longitude, location: $location, isResolved: $isResolved, resolvedAt: $resolvedAt, resolvedBy: $resolvedBy, resolution: $resolution)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SecurityEventImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.level, level) || other.level == level) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.ipAddress, ipAddress) ||
                other.ipAddress == ipAddress) &&
            (identical(other.userAgent, userAgent) ||
                other.userAgent == userAgent) &&
            (identical(other.deviceId, deviceId) ||
                other.deviceId == deviceId) &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.isResolved, isResolved) ||
                other.isResolved == isResolved) &&
            (identical(other.resolvedAt, resolvedAt) ||
                other.resolvedAt == resolvedAt) &&
            (identical(other.resolvedBy, resolvedBy) ||
                other.resolvedBy == resolvedBy) &&
            (identical(other.resolution, resolution) ||
                other.resolution == resolution));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      type,
      level,
      timestamp,
      userId,
      description,
      ipAddress,
      userAgent,
      deviceId,
      sessionId,
      const DeepCollectionEquality().hash(_metadata),
      latitude,
      longitude,
      location,
      isResolved,
      resolvedAt,
      resolvedBy,
      resolution);

  /// Create a copy of SecurityEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SecurityEventImplCopyWith<_$SecurityEventImpl> get copyWith =>
      __$$SecurityEventImplCopyWithImpl<_$SecurityEventImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SecurityEventImplToJson(
      this,
    );
  }
}

abstract class _SecurityEvent extends SecurityEvent {
  const factory _SecurityEvent(
      {required final String id,
      required final SecurityEventType type,
      required final SecurityLevel level,
      required final DateTime timestamp,
      required final String userId,
      final String? description,
      final String? ipAddress,
      final String? userAgent,
      final String? deviceId,
      final String? sessionId,
      final Map<String, dynamic>? metadata,
      final double? latitude,
      final double? longitude,
      final String? location,
      final bool isResolved,
      final DateTime? resolvedAt,
      final String? resolvedBy,
      final String? resolution}) = _$SecurityEventImpl;
  const _SecurityEvent._() : super._();

  factory _SecurityEvent.fromJson(Map<String, dynamic> json) =
      _$SecurityEventImpl.fromJson;

  @override
  String get id;
  @override
  SecurityEventType get type;
  @override
  SecurityLevel get level;
  @override
  DateTime get timestamp;
  @override
  String get userId;
  @override
  String? get description;
  @override
  String? get ipAddress;
  @override
  String? get userAgent;
  @override
  String? get deviceId;
  @override
  String? get sessionId;
  @override
  Map<String, dynamic>? get metadata; // 위치 정보 (선택적)
  @override
  double? get latitude;
  @override
  double? get longitude;
  @override
  String? get location; // 처리 상태
  @override
  bool get isResolved;
  @override
  DateTime? get resolvedAt;
  @override
  String? get resolvedBy;
  @override
  String? get resolution;

  /// Create a copy of SecurityEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SecurityEventImplCopyWith<_$SecurityEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SecurityState _$SecurityStateFromJson(Map<String, dynamic> json) {
  return _SecurityState.fromJson(json);
}

/// @nodoc
mixin _$SecurityState {
  SecurityThreatLevel get threatLevel => throw _privateConstructorUsedError;
  bool get isDeviceSecure => throw _privateConstructorUsedError;
  bool get isBiometricEnabled => throw _privateConstructorUsedError;
  bool get isAppTampered => throw _privateConstructorUsedError;
  bool get isDebuggingDetected => throw _privateConstructorUsedError;
  bool get isRootedOrJailbroken => throw _privateConstructorUsedError;
  List<SecurityEvent>? get recentEvents => throw _privateConstructorUsedError;
  DateTime? get lastSecurityCheck => throw _privateConstructorUsedError;
  Map<String, dynamic>? get deviceInfo => throw _privateConstructorUsedError;

  /// Serializes this SecurityState to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SecurityState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SecurityStateCopyWith<SecurityState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SecurityStateCopyWith<$Res> {
  factory $SecurityStateCopyWith(
          SecurityState value, $Res Function(SecurityState) then) =
      _$SecurityStateCopyWithImpl<$Res, SecurityState>;
  @useResult
  $Res call(
      {SecurityThreatLevel threatLevel,
      bool isDeviceSecure,
      bool isBiometricEnabled,
      bool isAppTampered,
      bool isDebuggingDetected,
      bool isRootedOrJailbroken,
      List<SecurityEvent>? recentEvents,
      DateTime? lastSecurityCheck,
      Map<String, dynamic>? deviceInfo});
}

/// @nodoc
class _$SecurityStateCopyWithImpl<$Res, $Val extends SecurityState>
    implements $SecurityStateCopyWith<$Res> {
  _$SecurityStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SecurityState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? threatLevel = null,
    Object? isDeviceSecure = null,
    Object? isBiometricEnabled = null,
    Object? isAppTampered = null,
    Object? isDebuggingDetected = null,
    Object? isRootedOrJailbroken = null,
    Object? recentEvents = freezed,
    Object? lastSecurityCheck = freezed,
    Object? deviceInfo = freezed,
  }) {
    return _then(_value.copyWith(
      threatLevel: null == threatLevel
          ? _value.threatLevel
          : threatLevel // ignore: cast_nullable_to_non_nullable
              as SecurityThreatLevel,
      isDeviceSecure: null == isDeviceSecure
          ? _value.isDeviceSecure
          : isDeviceSecure // ignore: cast_nullable_to_non_nullable
              as bool,
      isBiometricEnabled: null == isBiometricEnabled
          ? _value.isBiometricEnabled
          : isBiometricEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      isAppTampered: null == isAppTampered
          ? _value.isAppTampered
          : isAppTampered // ignore: cast_nullable_to_non_nullable
              as bool,
      isDebuggingDetected: null == isDebuggingDetected
          ? _value.isDebuggingDetected
          : isDebuggingDetected // ignore: cast_nullable_to_non_nullable
              as bool,
      isRootedOrJailbroken: null == isRootedOrJailbroken
          ? _value.isRootedOrJailbroken
          : isRootedOrJailbroken // ignore: cast_nullable_to_non_nullable
              as bool,
      recentEvents: freezed == recentEvents
          ? _value.recentEvents
          : recentEvents // ignore: cast_nullable_to_non_nullable
              as List<SecurityEvent>?,
      lastSecurityCheck: freezed == lastSecurityCheck
          ? _value.lastSecurityCheck
          : lastSecurityCheck // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      deviceInfo: freezed == deviceInfo
          ? _value.deviceInfo
          : deviceInfo // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SecurityStateImplCopyWith<$Res>
    implements $SecurityStateCopyWith<$Res> {
  factory _$$SecurityStateImplCopyWith(
          _$SecurityStateImpl value, $Res Function(_$SecurityStateImpl) then) =
      __$$SecurityStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {SecurityThreatLevel threatLevel,
      bool isDeviceSecure,
      bool isBiometricEnabled,
      bool isAppTampered,
      bool isDebuggingDetected,
      bool isRootedOrJailbroken,
      List<SecurityEvent>? recentEvents,
      DateTime? lastSecurityCheck,
      Map<String, dynamic>? deviceInfo});
}

/// @nodoc
class __$$SecurityStateImplCopyWithImpl<$Res>
    extends _$SecurityStateCopyWithImpl<$Res, _$SecurityStateImpl>
    implements _$$SecurityStateImplCopyWith<$Res> {
  __$$SecurityStateImplCopyWithImpl(
      _$SecurityStateImpl _value, $Res Function(_$SecurityStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of SecurityState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? threatLevel = null,
    Object? isDeviceSecure = null,
    Object? isBiometricEnabled = null,
    Object? isAppTampered = null,
    Object? isDebuggingDetected = null,
    Object? isRootedOrJailbroken = null,
    Object? recentEvents = freezed,
    Object? lastSecurityCheck = freezed,
    Object? deviceInfo = freezed,
  }) {
    return _then(_$SecurityStateImpl(
      threatLevel: null == threatLevel
          ? _value.threatLevel
          : threatLevel // ignore: cast_nullable_to_non_nullable
              as SecurityThreatLevel,
      isDeviceSecure: null == isDeviceSecure
          ? _value.isDeviceSecure
          : isDeviceSecure // ignore: cast_nullable_to_non_nullable
              as bool,
      isBiometricEnabled: null == isBiometricEnabled
          ? _value.isBiometricEnabled
          : isBiometricEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      isAppTampered: null == isAppTampered
          ? _value.isAppTampered
          : isAppTampered // ignore: cast_nullable_to_non_nullable
              as bool,
      isDebuggingDetected: null == isDebuggingDetected
          ? _value.isDebuggingDetected
          : isDebuggingDetected // ignore: cast_nullable_to_non_nullable
              as bool,
      isRootedOrJailbroken: null == isRootedOrJailbroken
          ? _value.isRootedOrJailbroken
          : isRootedOrJailbroken // ignore: cast_nullable_to_non_nullable
              as bool,
      recentEvents: freezed == recentEvents
          ? _value._recentEvents
          : recentEvents // ignore: cast_nullable_to_non_nullable
              as List<SecurityEvent>?,
      lastSecurityCheck: freezed == lastSecurityCheck
          ? _value.lastSecurityCheck
          : lastSecurityCheck // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      deviceInfo: freezed == deviceInfo
          ? _value._deviceInfo
          : deviceInfo // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SecurityStateImpl extends _SecurityState {
  const _$SecurityStateImpl(
      {this.threatLevel = SecurityThreatLevel.none,
      this.isDeviceSecure = false,
      this.isBiometricEnabled = false,
      this.isAppTampered = false,
      this.isDebuggingDetected = false,
      this.isRootedOrJailbroken = false,
      final List<SecurityEvent>? recentEvents,
      this.lastSecurityCheck,
      final Map<String, dynamic>? deviceInfo})
      : _recentEvents = recentEvents,
        _deviceInfo = deviceInfo,
        super._();

  factory _$SecurityStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$SecurityStateImplFromJson(json);

  @override
  @JsonKey()
  final SecurityThreatLevel threatLevel;
  @override
  @JsonKey()
  final bool isDeviceSecure;
  @override
  @JsonKey()
  final bool isBiometricEnabled;
  @override
  @JsonKey()
  final bool isAppTampered;
  @override
  @JsonKey()
  final bool isDebuggingDetected;
  @override
  @JsonKey()
  final bool isRootedOrJailbroken;
  final List<SecurityEvent>? _recentEvents;
  @override
  List<SecurityEvent>? get recentEvents {
    final value = _recentEvents;
    if (value == null) return null;
    if (_recentEvents is EqualUnmodifiableListView) return _recentEvents;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final DateTime? lastSecurityCheck;
  final Map<String, dynamic>? _deviceInfo;
  @override
  Map<String, dynamic>? get deviceInfo {
    final value = _deviceInfo;
    if (value == null) return null;
    if (_deviceInfo is EqualUnmodifiableMapView) return _deviceInfo;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'SecurityState(threatLevel: $threatLevel, isDeviceSecure: $isDeviceSecure, isBiometricEnabled: $isBiometricEnabled, isAppTampered: $isAppTampered, isDebuggingDetected: $isDebuggingDetected, isRootedOrJailbroken: $isRootedOrJailbroken, recentEvents: $recentEvents, lastSecurityCheck: $lastSecurityCheck, deviceInfo: $deviceInfo)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SecurityStateImpl &&
            (identical(other.threatLevel, threatLevel) ||
                other.threatLevel == threatLevel) &&
            (identical(other.isDeviceSecure, isDeviceSecure) ||
                other.isDeviceSecure == isDeviceSecure) &&
            (identical(other.isBiometricEnabled, isBiometricEnabled) ||
                other.isBiometricEnabled == isBiometricEnabled) &&
            (identical(other.isAppTampered, isAppTampered) ||
                other.isAppTampered == isAppTampered) &&
            (identical(other.isDebuggingDetected, isDebuggingDetected) ||
                other.isDebuggingDetected == isDebuggingDetected) &&
            (identical(other.isRootedOrJailbroken, isRootedOrJailbroken) ||
                other.isRootedOrJailbroken == isRootedOrJailbroken) &&
            const DeepCollectionEquality()
                .equals(other._recentEvents, _recentEvents) &&
            (identical(other.lastSecurityCheck, lastSecurityCheck) ||
                other.lastSecurityCheck == lastSecurityCheck) &&
            const DeepCollectionEquality()
                .equals(other._deviceInfo, _deviceInfo));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      threatLevel,
      isDeviceSecure,
      isBiometricEnabled,
      isAppTampered,
      isDebuggingDetected,
      isRootedOrJailbroken,
      const DeepCollectionEquality().hash(_recentEvents),
      lastSecurityCheck,
      const DeepCollectionEquality().hash(_deviceInfo));

  /// Create a copy of SecurityState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SecurityStateImplCopyWith<_$SecurityStateImpl> get copyWith =>
      __$$SecurityStateImplCopyWithImpl<_$SecurityStateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SecurityStateImplToJson(
      this,
    );
  }
}

abstract class _SecurityState extends SecurityState {
  const factory _SecurityState(
      {final SecurityThreatLevel threatLevel,
      final bool isDeviceSecure,
      final bool isBiometricEnabled,
      final bool isAppTampered,
      final bool isDebuggingDetected,
      final bool isRootedOrJailbroken,
      final List<SecurityEvent>? recentEvents,
      final DateTime? lastSecurityCheck,
      final Map<String, dynamic>? deviceInfo}) = _$SecurityStateImpl;
  const _SecurityState._() : super._();

  factory _SecurityState.fromJson(Map<String, dynamic> json) =
      _$SecurityStateImpl.fromJson;

  @override
  SecurityThreatLevel get threatLevel;
  @override
  bool get isDeviceSecure;
  @override
  bool get isBiometricEnabled;
  @override
  bool get isAppTampered;
  @override
  bool get isDebuggingDetected;
  @override
  bool get isRootedOrJailbroken;
  @override
  List<SecurityEvent>? get recentEvents;
  @override
  DateTime? get lastSecurityCheck;
  @override
  Map<String, dynamic>? get deviceInfo;

  /// Create a copy of SecurityState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SecurityStateImplCopyWith<_$SecurityStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
