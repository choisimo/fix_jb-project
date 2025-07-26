// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'secure_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SecureData _$SecureDataFromJson(Map<String, dynamic> json) {
  return _SecureData.fromJson(json);
}

/// @nodoc
mixin _$SecureData {
  String get encryptedData => throw _privateConstructorUsedError;
  String get salt => throw _privateConstructorUsedError;
  String get iv => throw _privateConstructorUsedError;
  EncryptionAlgorithm get algorithm => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get expiresAt => throw _privateConstructorUsedError;
  String? get keyId => throw _privateConstructorUsedError;
  bool get isCompressed => throw _privateConstructorUsedError;

  /// Serializes this SecureData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SecureData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SecureDataCopyWith<SecureData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SecureDataCopyWith<$Res> {
  factory $SecureDataCopyWith(
          SecureData value, $Res Function(SecureData) then) =
      _$SecureDataCopyWithImpl<$Res, SecureData>;
  @useResult
  $Res call(
      {String encryptedData,
      String salt,
      String iv,
      EncryptionAlgorithm algorithm,
      DateTime createdAt,
      DateTime? expiresAt,
      String? keyId,
      bool isCompressed});
}

/// @nodoc
class _$SecureDataCopyWithImpl<$Res, $Val extends SecureData>
    implements $SecureDataCopyWith<$Res> {
  _$SecureDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SecureData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? encryptedData = null,
    Object? salt = null,
    Object? iv = null,
    Object? algorithm = null,
    Object? createdAt = null,
    Object? expiresAt = freezed,
    Object? keyId = freezed,
    Object? isCompressed = null,
  }) {
    return _then(_value.copyWith(
      encryptedData: null == encryptedData
          ? _value.encryptedData
          : encryptedData // ignore: cast_nullable_to_non_nullable
              as String,
      salt: null == salt
          ? _value.salt
          : salt // ignore: cast_nullable_to_non_nullable
              as String,
      iv: null == iv
          ? _value.iv
          : iv // ignore: cast_nullable_to_non_nullable
              as String,
      algorithm: null == algorithm
          ? _value.algorithm
          : algorithm // ignore: cast_nullable_to_non_nullable
              as EncryptionAlgorithm,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      expiresAt: freezed == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      keyId: freezed == keyId
          ? _value.keyId
          : keyId // ignore: cast_nullable_to_non_nullable
              as String?,
      isCompressed: null == isCompressed
          ? _value.isCompressed
          : isCompressed // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SecureDataImplCopyWith<$Res>
    implements $SecureDataCopyWith<$Res> {
  factory _$$SecureDataImplCopyWith(
          _$SecureDataImpl value, $Res Function(_$SecureDataImpl) then) =
      __$$SecureDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String encryptedData,
      String salt,
      String iv,
      EncryptionAlgorithm algorithm,
      DateTime createdAt,
      DateTime? expiresAt,
      String? keyId,
      bool isCompressed});
}

/// @nodoc
class __$$SecureDataImplCopyWithImpl<$Res>
    extends _$SecureDataCopyWithImpl<$Res, _$SecureDataImpl>
    implements _$$SecureDataImplCopyWith<$Res> {
  __$$SecureDataImplCopyWithImpl(
      _$SecureDataImpl _value, $Res Function(_$SecureDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of SecureData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? encryptedData = null,
    Object? salt = null,
    Object? iv = null,
    Object? algorithm = null,
    Object? createdAt = null,
    Object? expiresAt = freezed,
    Object? keyId = freezed,
    Object? isCompressed = null,
  }) {
    return _then(_$SecureDataImpl(
      encryptedData: null == encryptedData
          ? _value.encryptedData
          : encryptedData // ignore: cast_nullable_to_non_nullable
              as String,
      salt: null == salt
          ? _value.salt
          : salt // ignore: cast_nullable_to_non_nullable
              as String,
      iv: null == iv
          ? _value.iv
          : iv // ignore: cast_nullable_to_non_nullable
              as String,
      algorithm: null == algorithm
          ? _value.algorithm
          : algorithm // ignore: cast_nullable_to_non_nullable
              as EncryptionAlgorithm,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      expiresAt: freezed == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      keyId: freezed == keyId
          ? _value.keyId
          : keyId // ignore: cast_nullable_to_non_nullable
              as String?,
      isCompressed: null == isCompressed
          ? _value.isCompressed
          : isCompressed // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SecureDataImpl implements _SecureData {
  const _$SecureDataImpl(
      {required this.encryptedData,
      required this.salt,
      required this.iv,
      required this.algorithm,
      required this.createdAt,
      this.expiresAt,
      this.keyId,
      this.isCompressed = false});

  factory _$SecureDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$SecureDataImplFromJson(json);

  @override
  final String encryptedData;
  @override
  final String salt;
  @override
  final String iv;
  @override
  final EncryptionAlgorithm algorithm;
  @override
  final DateTime createdAt;
  @override
  final DateTime? expiresAt;
  @override
  final String? keyId;
  @override
  @JsonKey()
  final bool isCompressed;

  @override
  String toString() {
    return 'SecureData(encryptedData: $encryptedData, salt: $salt, iv: $iv, algorithm: $algorithm, createdAt: $createdAt, expiresAt: $expiresAt, keyId: $keyId, isCompressed: $isCompressed)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SecureDataImpl &&
            (identical(other.encryptedData, encryptedData) ||
                other.encryptedData == encryptedData) &&
            (identical(other.salt, salt) || other.salt == salt) &&
            (identical(other.iv, iv) || other.iv == iv) &&
            (identical(other.algorithm, algorithm) ||
                other.algorithm == algorithm) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt) &&
            (identical(other.keyId, keyId) || other.keyId == keyId) &&
            (identical(other.isCompressed, isCompressed) ||
                other.isCompressed == isCompressed));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, encryptedData, salt, iv,
      algorithm, createdAt, expiresAt, keyId, isCompressed);

  /// Create a copy of SecureData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SecureDataImplCopyWith<_$SecureDataImpl> get copyWith =>
      __$$SecureDataImplCopyWithImpl<_$SecureDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SecureDataImplToJson(
      this,
    );
  }
}

abstract class _SecureData implements SecureData {
  const factory _SecureData(
      {required final String encryptedData,
      required final String salt,
      required final String iv,
      required final EncryptionAlgorithm algorithm,
      required final DateTime createdAt,
      final DateTime? expiresAt,
      final String? keyId,
      final bool isCompressed}) = _$SecureDataImpl;

  factory _SecureData.fromJson(Map<String, dynamic> json) =
      _$SecureDataImpl.fromJson;

  @override
  String get encryptedData;
  @override
  String get salt;
  @override
  String get iv;
  @override
  EncryptionAlgorithm get algorithm;
  @override
  DateTime get createdAt;
  @override
  DateTime? get expiresAt;
  @override
  String? get keyId;
  @override
  bool get isCompressed;

  /// Create a copy of SecureData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SecureDataImplCopyWith<_$SecureDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
