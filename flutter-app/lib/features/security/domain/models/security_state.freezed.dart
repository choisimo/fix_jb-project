// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'security_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SecurityState _$SecurityStateFromJson(Map<String, dynamic> json) {
  return _SecurityState.fromJson(json);
}

/// @nodoc
mixin _$SecurityState {
  bool get isBiometricEnabled => throw _privateConstructorUsedError;
  SecurityLevel get currentLevel => throw _privateConstructorUsedError;
  List<SecurityEvent> get recentEvents => throw _privateConstructorUsedError;
  PrivacySettings? get privacySettings => throw _privateConstructorUsedError;
  bool get isDeviceSecure => throw _privateConstructorUsedError;
  bool get isRootDetected => throw _privateConstructorUsedError;
  bool get isDebugMode => throw _privateConstructorUsedError;
  bool get isTampered => throw _privateConstructorUsedError;
  DateTime? get lastSecurityCheck => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;
  int get failedAuthAttempts => throw _privateConstructorUsedError;
  DateTime? get lastFailedAuth => throw _privateConstructorUsedError;

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
      {bool isBiometricEnabled,
      SecurityLevel currentLevel,
      List<SecurityEvent> recentEvents,
      PrivacySettings? privacySettings,
      bool isDeviceSecure,
      bool isRootDetected,
      bool isDebugMode,
      bool isTampered,
      DateTime? lastSecurityCheck,
      String? error,
      int failedAuthAttempts,
      DateTime? lastFailedAuth});

  $PrivacySettingsCopyWith<$Res>? get privacySettings;
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
    Object? isBiometricEnabled = null,
    Object? currentLevel = null,
    Object? recentEvents = null,
    Object? privacySettings = freezed,
    Object? isDeviceSecure = null,
    Object? isRootDetected = null,
    Object? isDebugMode = null,
    Object? isTampered = null,
    Object? lastSecurityCheck = freezed,
    Object? error = freezed,
    Object? failedAuthAttempts = null,
    Object? lastFailedAuth = freezed,
  }) {
    return _then(_value.copyWith(
      isBiometricEnabled: null == isBiometricEnabled
          ? _value.isBiometricEnabled
          : isBiometricEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      currentLevel: null == currentLevel
          ? _value.currentLevel
          : currentLevel // ignore: cast_nullable_to_non_nullable
              as SecurityLevel,
      recentEvents: null == recentEvents
          ? _value.recentEvents
          : recentEvents // ignore: cast_nullable_to_non_nullable
              as List<SecurityEvent>,
      privacySettings: freezed == privacySettings
          ? _value.privacySettings
          : privacySettings // ignore: cast_nullable_to_non_nullable
              as PrivacySettings?,
      isDeviceSecure: null == isDeviceSecure
          ? _value.isDeviceSecure
          : isDeviceSecure // ignore: cast_nullable_to_non_nullable
              as bool,
      isRootDetected: null == isRootDetected
          ? _value.isRootDetected
          : isRootDetected // ignore: cast_nullable_to_non_nullable
              as bool,
      isDebugMode: null == isDebugMode
          ? _value.isDebugMode
          : isDebugMode // ignore: cast_nullable_to_non_nullable
              as bool,
      isTampered: null == isTampered
          ? _value.isTampered
          : isTampered // ignore: cast_nullable_to_non_nullable
              as bool,
      lastSecurityCheck: freezed == lastSecurityCheck
          ? _value.lastSecurityCheck
          : lastSecurityCheck // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      failedAuthAttempts: null == failedAuthAttempts
          ? _value.failedAuthAttempts
          : failedAuthAttempts // ignore: cast_nullable_to_non_nullable
              as int,
      lastFailedAuth: freezed == lastFailedAuth
          ? _value.lastFailedAuth
          : lastFailedAuth // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }

  /// Create a copy of SecurityState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PrivacySettingsCopyWith<$Res>? get privacySettings {
    if (_value.privacySettings == null) {
      return null;
    }

    return $PrivacySettingsCopyWith<$Res>(_value.privacySettings!, (value) {
      return _then(_value.copyWith(privacySettings: value) as $Val);
    });
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
      {bool isBiometricEnabled,
      SecurityLevel currentLevel,
      List<SecurityEvent> recentEvents,
      PrivacySettings? privacySettings,
      bool isDeviceSecure,
      bool isRootDetected,
      bool isDebugMode,
      bool isTampered,
      DateTime? lastSecurityCheck,
      String? error,
      int failedAuthAttempts,
      DateTime? lastFailedAuth});

  @override
  $PrivacySettingsCopyWith<$Res>? get privacySettings;
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
    Object? isBiometricEnabled = null,
    Object? currentLevel = null,
    Object? recentEvents = null,
    Object? privacySettings = freezed,
    Object? isDeviceSecure = null,
    Object? isRootDetected = null,
    Object? isDebugMode = null,
    Object? isTampered = null,
    Object? lastSecurityCheck = freezed,
    Object? error = freezed,
    Object? failedAuthAttempts = null,
    Object? lastFailedAuth = freezed,
  }) {
    return _then(_$SecurityStateImpl(
      isBiometricEnabled: null == isBiometricEnabled
          ? _value.isBiometricEnabled
          : isBiometricEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      currentLevel: null == currentLevel
          ? _value.currentLevel
          : currentLevel // ignore: cast_nullable_to_non_nullable
              as SecurityLevel,
      recentEvents: null == recentEvents
          ? _value._recentEvents
          : recentEvents // ignore: cast_nullable_to_non_nullable
              as List<SecurityEvent>,
      privacySettings: freezed == privacySettings
          ? _value.privacySettings
          : privacySettings // ignore: cast_nullable_to_non_nullable
              as PrivacySettings?,
      isDeviceSecure: null == isDeviceSecure
          ? _value.isDeviceSecure
          : isDeviceSecure // ignore: cast_nullable_to_non_nullable
              as bool,
      isRootDetected: null == isRootDetected
          ? _value.isRootDetected
          : isRootDetected // ignore: cast_nullable_to_non_nullable
              as bool,
      isDebugMode: null == isDebugMode
          ? _value.isDebugMode
          : isDebugMode // ignore: cast_nullable_to_non_nullable
              as bool,
      isTampered: null == isTampered
          ? _value.isTampered
          : isTampered // ignore: cast_nullable_to_non_nullable
              as bool,
      lastSecurityCheck: freezed == lastSecurityCheck
          ? _value.lastSecurityCheck
          : lastSecurityCheck // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      failedAuthAttempts: null == failedAuthAttempts
          ? _value.failedAuthAttempts
          : failedAuthAttempts // ignore: cast_nullable_to_non_nullable
              as int,
      lastFailedAuth: freezed == lastFailedAuth
          ? _value.lastFailedAuth
          : lastFailedAuth // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SecurityStateImpl implements _SecurityState {
  const _$SecurityStateImpl(
      {this.isBiometricEnabled = false,
      this.currentLevel = SecurityLevel.medium,
      final List<SecurityEvent> recentEvents = const [],
      this.privacySettings,
      this.isDeviceSecure = false,
      this.isRootDetected = false,
      this.isDebugMode = false,
      this.isTampered = false,
      this.lastSecurityCheck,
      this.error,
      this.failedAuthAttempts = 0,
      this.lastFailedAuth})
      : _recentEvents = recentEvents;

  factory _$SecurityStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$SecurityStateImplFromJson(json);

  @override
  @JsonKey()
  final bool isBiometricEnabled;
  @override
  @JsonKey()
  final SecurityLevel currentLevel;
  final List<SecurityEvent> _recentEvents;
  @override
  @JsonKey()
  List<SecurityEvent> get recentEvents {
    if (_recentEvents is EqualUnmodifiableListView) return _recentEvents;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recentEvents);
  }

  @override
  final PrivacySettings? privacySettings;
  @override
  @JsonKey()
  final bool isDeviceSecure;
  @override
  @JsonKey()
  final bool isRootDetected;
  @override
  @JsonKey()
  final bool isDebugMode;
  @override
  @JsonKey()
  final bool isTampered;
  @override
  final DateTime? lastSecurityCheck;
  @override
  final String? error;
  @override
  @JsonKey()
  final int failedAuthAttempts;
  @override
  final DateTime? lastFailedAuth;

  @override
  String toString() {
    return 'SecurityState(isBiometricEnabled: $isBiometricEnabled, currentLevel: $currentLevel, recentEvents: $recentEvents, privacySettings: $privacySettings, isDeviceSecure: $isDeviceSecure, isRootDetected: $isRootDetected, isDebugMode: $isDebugMode, isTampered: $isTampered, lastSecurityCheck: $lastSecurityCheck, error: $error, failedAuthAttempts: $failedAuthAttempts, lastFailedAuth: $lastFailedAuth)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SecurityStateImpl &&
            (identical(other.isBiometricEnabled, isBiometricEnabled) ||
                other.isBiometricEnabled == isBiometricEnabled) &&
            (identical(other.currentLevel, currentLevel) ||
                other.currentLevel == currentLevel) &&
            const DeepCollectionEquality()
                .equals(other._recentEvents, _recentEvents) &&
            (identical(other.privacySettings, privacySettings) ||
                other.privacySettings == privacySettings) &&
            (identical(other.isDeviceSecure, isDeviceSecure) ||
                other.isDeviceSecure == isDeviceSecure) &&
            (identical(other.isRootDetected, isRootDetected) ||
                other.isRootDetected == isRootDetected) &&
            (identical(other.isDebugMode, isDebugMode) ||
                other.isDebugMode == isDebugMode) &&
            (identical(other.isTampered, isTampered) ||
                other.isTampered == isTampered) &&
            (identical(other.lastSecurityCheck, lastSecurityCheck) ||
                other.lastSecurityCheck == lastSecurityCheck) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.failedAuthAttempts, failedAuthAttempts) ||
                other.failedAuthAttempts == failedAuthAttempts) &&
            (identical(other.lastFailedAuth, lastFailedAuth) ||
                other.lastFailedAuth == lastFailedAuth));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      isBiometricEnabled,
      currentLevel,
      const DeepCollectionEquality().hash(_recentEvents),
      privacySettings,
      isDeviceSecure,
      isRootDetected,
      isDebugMode,
      isTampered,
      lastSecurityCheck,
      error,
      failedAuthAttempts,
      lastFailedAuth);

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

abstract class _SecurityState implements SecurityState {
  const factory _SecurityState(
      {final bool isBiometricEnabled,
      final SecurityLevel currentLevel,
      final List<SecurityEvent> recentEvents,
      final PrivacySettings? privacySettings,
      final bool isDeviceSecure,
      final bool isRootDetected,
      final bool isDebugMode,
      final bool isTampered,
      final DateTime? lastSecurityCheck,
      final String? error,
      final int failedAuthAttempts,
      final DateTime? lastFailedAuth}) = _$SecurityStateImpl;

  factory _SecurityState.fromJson(Map<String, dynamic> json) =
      _$SecurityStateImpl.fromJson;

  @override
  bool get isBiometricEnabled;
  @override
  SecurityLevel get currentLevel;
  @override
  List<SecurityEvent> get recentEvents;
  @override
  PrivacySettings? get privacySettings;
  @override
  bool get isDeviceSecure;
  @override
  bool get isRootDetected;
  @override
  bool get isDebugMode;
  @override
  bool get isTampered;
  @override
  DateTime? get lastSecurityCheck;
  @override
  String? get error;
  @override
  int get failedAuthAttempts;
  @override
  DateTime? get lastFailedAuth;

  /// Create a copy of SecurityState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SecurityStateImplCopyWith<_$SecurityStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
