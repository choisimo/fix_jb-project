// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'privacy_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PrivacySettings _$PrivacySettingsFromJson(Map<String, dynamic> json) {
  return _PrivacySettings.fromJson(json);
}

/// @nodoc
mixin _$PrivacySettings {
  bool get allowDataCollection => throw _privateConstructorUsedError;
  bool get allowLocationTracking => throw _privateConstructorUsedError;
  bool get allowAnalytics => throw _privateConstructorUsedError;
  bool get allowMarketing => throw _privateConstructorUsedError;
  DataRetentionPeriod get retention => throw _privateConstructorUsedError;
  List<String>? get consentedPurposes => throw _privateConstructorUsedError;
  DateTime? get lastUpdated => throw _privateConstructorUsedError;
  bool get allowPersonalization => throw _privateConstructorUsedError;
  bool get allowThirdPartySharing => throw _privateConstructorUsedError;
  bool get requireExplicitConsent => throw _privateConstructorUsedError;

  /// Serializes this PrivacySettings to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PrivacySettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PrivacySettingsCopyWith<PrivacySettings> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PrivacySettingsCopyWith<$Res> {
  factory $PrivacySettingsCopyWith(
          PrivacySettings value, $Res Function(PrivacySettings) then) =
      _$PrivacySettingsCopyWithImpl<$Res, PrivacySettings>;
  @useResult
  $Res call(
      {bool allowDataCollection,
      bool allowLocationTracking,
      bool allowAnalytics,
      bool allowMarketing,
      DataRetentionPeriod retention,
      List<String>? consentedPurposes,
      DateTime? lastUpdated,
      bool allowPersonalization,
      bool allowThirdPartySharing,
      bool requireExplicitConsent});
}

/// @nodoc
class _$PrivacySettingsCopyWithImpl<$Res, $Val extends PrivacySettings>
    implements $PrivacySettingsCopyWith<$Res> {
  _$PrivacySettingsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PrivacySettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? allowDataCollection = null,
    Object? allowLocationTracking = null,
    Object? allowAnalytics = null,
    Object? allowMarketing = null,
    Object? retention = null,
    Object? consentedPurposes = freezed,
    Object? lastUpdated = freezed,
    Object? allowPersonalization = null,
    Object? allowThirdPartySharing = null,
    Object? requireExplicitConsent = null,
  }) {
    return _then(_value.copyWith(
      allowDataCollection: null == allowDataCollection
          ? _value.allowDataCollection
          : allowDataCollection // ignore: cast_nullable_to_non_nullable
              as bool,
      allowLocationTracking: null == allowLocationTracking
          ? _value.allowLocationTracking
          : allowLocationTracking // ignore: cast_nullable_to_non_nullable
              as bool,
      allowAnalytics: null == allowAnalytics
          ? _value.allowAnalytics
          : allowAnalytics // ignore: cast_nullable_to_non_nullable
              as bool,
      allowMarketing: null == allowMarketing
          ? _value.allowMarketing
          : allowMarketing // ignore: cast_nullable_to_non_nullable
              as bool,
      retention: null == retention
          ? _value.retention
          : retention // ignore: cast_nullable_to_non_nullable
              as DataRetentionPeriod,
      consentedPurposes: freezed == consentedPurposes
          ? _value.consentedPurposes
          : consentedPurposes // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      lastUpdated: freezed == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      allowPersonalization: null == allowPersonalization
          ? _value.allowPersonalization
          : allowPersonalization // ignore: cast_nullable_to_non_nullable
              as bool,
      allowThirdPartySharing: null == allowThirdPartySharing
          ? _value.allowThirdPartySharing
          : allowThirdPartySharing // ignore: cast_nullable_to_non_nullable
              as bool,
      requireExplicitConsent: null == requireExplicitConsent
          ? _value.requireExplicitConsent
          : requireExplicitConsent // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PrivacySettingsImplCopyWith<$Res>
    implements $PrivacySettingsCopyWith<$Res> {
  factory _$$PrivacySettingsImplCopyWith(_$PrivacySettingsImpl value,
          $Res Function(_$PrivacySettingsImpl) then) =
      __$$PrivacySettingsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool allowDataCollection,
      bool allowLocationTracking,
      bool allowAnalytics,
      bool allowMarketing,
      DataRetentionPeriod retention,
      List<String>? consentedPurposes,
      DateTime? lastUpdated,
      bool allowPersonalization,
      bool allowThirdPartySharing,
      bool requireExplicitConsent});
}

/// @nodoc
class __$$PrivacySettingsImplCopyWithImpl<$Res>
    extends _$PrivacySettingsCopyWithImpl<$Res, _$PrivacySettingsImpl>
    implements _$$PrivacySettingsImplCopyWith<$Res> {
  __$$PrivacySettingsImplCopyWithImpl(
      _$PrivacySettingsImpl _value, $Res Function(_$PrivacySettingsImpl) _then)
      : super(_value, _then);

  /// Create a copy of PrivacySettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? allowDataCollection = null,
    Object? allowLocationTracking = null,
    Object? allowAnalytics = null,
    Object? allowMarketing = null,
    Object? retention = null,
    Object? consentedPurposes = freezed,
    Object? lastUpdated = freezed,
    Object? allowPersonalization = null,
    Object? allowThirdPartySharing = null,
    Object? requireExplicitConsent = null,
  }) {
    return _then(_$PrivacySettingsImpl(
      allowDataCollection: null == allowDataCollection
          ? _value.allowDataCollection
          : allowDataCollection // ignore: cast_nullable_to_non_nullable
              as bool,
      allowLocationTracking: null == allowLocationTracking
          ? _value.allowLocationTracking
          : allowLocationTracking // ignore: cast_nullable_to_non_nullable
              as bool,
      allowAnalytics: null == allowAnalytics
          ? _value.allowAnalytics
          : allowAnalytics // ignore: cast_nullable_to_non_nullable
              as bool,
      allowMarketing: null == allowMarketing
          ? _value.allowMarketing
          : allowMarketing // ignore: cast_nullable_to_non_nullable
              as bool,
      retention: null == retention
          ? _value.retention
          : retention // ignore: cast_nullable_to_non_nullable
              as DataRetentionPeriod,
      consentedPurposes: freezed == consentedPurposes
          ? _value._consentedPurposes
          : consentedPurposes // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      lastUpdated: freezed == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      allowPersonalization: null == allowPersonalization
          ? _value.allowPersonalization
          : allowPersonalization // ignore: cast_nullable_to_non_nullable
              as bool,
      allowThirdPartySharing: null == allowThirdPartySharing
          ? _value.allowThirdPartySharing
          : allowThirdPartySharing // ignore: cast_nullable_to_non_nullable
              as bool,
      requireExplicitConsent: null == requireExplicitConsent
          ? _value.requireExplicitConsent
          : requireExplicitConsent // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PrivacySettingsImpl implements _PrivacySettings {
  const _$PrivacySettingsImpl(
      {this.allowDataCollection = false,
      this.allowLocationTracking = false,
      this.allowAnalytics = false,
      this.allowMarketing = false,
      this.retention = DataRetentionPeriod.oneYear,
      final List<String>? consentedPurposes,
      this.lastUpdated,
      this.allowPersonalization = false,
      this.allowThirdPartySharing = false,
      this.requireExplicitConsent = true})
      : _consentedPurposes = consentedPurposes;

  factory _$PrivacySettingsImpl.fromJson(Map<String, dynamic> json) =>
      _$$PrivacySettingsImplFromJson(json);

  @override
  @JsonKey()
  final bool allowDataCollection;
  @override
  @JsonKey()
  final bool allowLocationTracking;
  @override
  @JsonKey()
  final bool allowAnalytics;
  @override
  @JsonKey()
  final bool allowMarketing;
  @override
  @JsonKey()
  final DataRetentionPeriod retention;
  final List<String>? _consentedPurposes;
  @override
  List<String>? get consentedPurposes {
    final value = _consentedPurposes;
    if (value == null) return null;
    if (_consentedPurposes is EqualUnmodifiableListView)
      return _consentedPurposes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final DateTime? lastUpdated;
  @override
  @JsonKey()
  final bool allowPersonalization;
  @override
  @JsonKey()
  final bool allowThirdPartySharing;
  @override
  @JsonKey()
  final bool requireExplicitConsent;

  @override
  String toString() {
    return 'PrivacySettings(allowDataCollection: $allowDataCollection, allowLocationTracking: $allowLocationTracking, allowAnalytics: $allowAnalytics, allowMarketing: $allowMarketing, retention: $retention, consentedPurposes: $consentedPurposes, lastUpdated: $lastUpdated, allowPersonalization: $allowPersonalization, allowThirdPartySharing: $allowThirdPartySharing, requireExplicitConsent: $requireExplicitConsent)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PrivacySettingsImpl &&
            (identical(other.allowDataCollection, allowDataCollection) ||
                other.allowDataCollection == allowDataCollection) &&
            (identical(other.allowLocationTracking, allowLocationTracking) ||
                other.allowLocationTracking == allowLocationTracking) &&
            (identical(other.allowAnalytics, allowAnalytics) ||
                other.allowAnalytics == allowAnalytics) &&
            (identical(other.allowMarketing, allowMarketing) ||
                other.allowMarketing == allowMarketing) &&
            (identical(other.retention, retention) ||
                other.retention == retention) &&
            const DeepCollectionEquality()
                .equals(other._consentedPurposes, _consentedPurposes) &&
            (identical(other.lastUpdated, lastUpdated) ||
                other.lastUpdated == lastUpdated) &&
            (identical(other.allowPersonalization, allowPersonalization) ||
                other.allowPersonalization == allowPersonalization) &&
            (identical(other.allowThirdPartySharing, allowThirdPartySharing) ||
                other.allowThirdPartySharing == allowThirdPartySharing) &&
            (identical(other.requireExplicitConsent, requireExplicitConsent) ||
                other.requireExplicitConsent == requireExplicitConsent));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      allowDataCollection,
      allowLocationTracking,
      allowAnalytics,
      allowMarketing,
      retention,
      const DeepCollectionEquality().hash(_consentedPurposes),
      lastUpdated,
      allowPersonalization,
      allowThirdPartySharing,
      requireExplicitConsent);

  /// Create a copy of PrivacySettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PrivacySettingsImplCopyWith<_$PrivacySettingsImpl> get copyWith =>
      __$$PrivacySettingsImplCopyWithImpl<_$PrivacySettingsImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PrivacySettingsImplToJson(
      this,
    );
  }
}

abstract class _PrivacySettings implements PrivacySettings {
  const factory _PrivacySettings(
      {final bool allowDataCollection,
      final bool allowLocationTracking,
      final bool allowAnalytics,
      final bool allowMarketing,
      final DataRetentionPeriod retention,
      final List<String>? consentedPurposes,
      final DateTime? lastUpdated,
      final bool allowPersonalization,
      final bool allowThirdPartySharing,
      final bool requireExplicitConsent}) = _$PrivacySettingsImpl;

  factory _PrivacySettings.fromJson(Map<String, dynamic> json) =
      _$PrivacySettingsImpl.fromJson;

  @override
  bool get allowDataCollection;
  @override
  bool get allowLocationTracking;
  @override
  bool get allowAnalytics;
  @override
  bool get allowMarketing;
  @override
  DataRetentionPeriod get retention;
  @override
  List<String>? get consentedPurposes;
  @override
  DateTime? get lastUpdated;
  @override
  bool get allowPersonalization;
  @override
  bool get allowThirdPartySharing;
  @override
  bool get requireExplicitConsent;

  /// Create a copy of PrivacySettings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PrivacySettingsImplCopyWith<_$PrivacySettingsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
