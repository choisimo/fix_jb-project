// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'report.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ReportLocation _$ReportLocationFromJson(Map<String, dynamic> json) {
  return _ReportLocation.fromJson(json);
}

/// @nodoc
mixin _$ReportLocation {
  double get latitude => throw _privateConstructorUsedError;
  double get longitude => throw _privateConstructorUsedError;
  String? get address => throw _privateConstructorUsedError;
  String? get city => throw _privateConstructorUsedError;
  String? get district => throw _privateConstructorUsedError;
  String? get postalCode => throw _privateConstructorUsedError;
  String? get landmark => throw _privateConstructorUsedError;

  /// Serializes this ReportLocation to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ReportLocation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReportLocationCopyWith<ReportLocation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReportLocationCopyWith<$Res> {
  factory $ReportLocationCopyWith(
          ReportLocation value, $Res Function(ReportLocation) then) =
      _$ReportLocationCopyWithImpl<$Res, ReportLocation>;
  @useResult
  $Res call(
      {double latitude,
      double longitude,
      String? address,
      String? city,
      String? district,
      String? postalCode,
      String? landmark});
}

/// @nodoc
class _$ReportLocationCopyWithImpl<$Res, $Val extends ReportLocation>
    implements $ReportLocationCopyWith<$Res> {
  _$ReportLocationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReportLocation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? latitude = null,
    Object? longitude = null,
    Object? address = freezed,
    Object? city = freezed,
    Object? district = freezed,
    Object? postalCode = freezed,
    Object? landmark = freezed,
  }) {
    return _then(_value.copyWith(
      latitude: null == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double,
      longitude: null == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      city: freezed == city
          ? _value.city
          : city // ignore: cast_nullable_to_non_nullable
              as String?,
      district: freezed == district
          ? _value.district
          : district // ignore: cast_nullable_to_non_nullable
              as String?,
      postalCode: freezed == postalCode
          ? _value.postalCode
          : postalCode // ignore: cast_nullable_to_non_nullable
              as String?,
      landmark: freezed == landmark
          ? _value.landmark
          : landmark // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ReportLocationImplCopyWith<$Res>
    implements $ReportLocationCopyWith<$Res> {
  factory _$$ReportLocationImplCopyWith(_$ReportLocationImpl value,
          $Res Function(_$ReportLocationImpl) then) =
      __$$ReportLocationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {double latitude,
      double longitude,
      String? address,
      String? city,
      String? district,
      String? postalCode,
      String? landmark});
}

/// @nodoc
class __$$ReportLocationImplCopyWithImpl<$Res>
    extends _$ReportLocationCopyWithImpl<$Res, _$ReportLocationImpl>
    implements _$$ReportLocationImplCopyWith<$Res> {
  __$$ReportLocationImplCopyWithImpl(
      _$ReportLocationImpl _value, $Res Function(_$ReportLocationImpl) _then)
      : super(_value, _then);

  /// Create a copy of ReportLocation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? latitude = null,
    Object? longitude = null,
    Object? address = freezed,
    Object? city = freezed,
    Object? district = freezed,
    Object? postalCode = freezed,
    Object? landmark = freezed,
  }) {
    return _then(_$ReportLocationImpl(
      latitude: null == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double,
      longitude: null == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      city: freezed == city
          ? _value.city
          : city // ignore: cast_nullable_to_non_nullable
              as String?,
      district: freezed == district
          ? _value.district
          : district // ignore: cast_nullable_to_non_nullable
              as String?,
      postalCode: freezed == postalCode
          ? _value.postalCode
          : postalCode // ignore: cast_nullable_to_non_nullable
              as String?,
      landmark: freezed == landmark
          ? _value.landmark
          : landmark // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ReportLocationImpl implements _ReportLocation {
  const _$ReportLocationImpl(
      {required this.latitude,
      required this.longitude,
      this.address,
      this.city,
      this.district,
      this.postalCode,
      this.landmark});

  factory _$ReportLocationImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReportLocationImplFromJson(json);

  @override
  final double latitude;
  @override
  final double longitude;
  @override
  final String? address;
  @override
  final String? city;
  @override
  final String? district;
  @override
  final String? postalCode;
  @override
  final String? landmark;

  @override
  String toString() {
    return 'ReportLocation(latitude: $latitude, longitude: $longitude, address: $address, city: $city, district: $district, postalCode: $postalCode, landmark: $landmark)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReportLocationImpl &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.district, district) ||
                other.district == district) &&
            (identical(other.postalCode, postalCode) ||
                other.postalCode == postalCode) &&
            (identical(other.landmark, landmark) ||
                other.landmark == landmark));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, latitude, longitude, address,
      city, district, postalCode, landmark);

  /// Create a copy of ReportLocation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReportLocationImplCopyWith<_$ReportLocationImpl> get copyWith =>
      __$$ReportLocationImplCopyWithImpl<_$ReportLocationImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReportLocationImplToJson(
      this,
    );
  }
}

abstract class _ReportLocation implements ReportLocation {
  const factory _ReportLocation(
      {required final double latitude,
      required final double longitude,
      final String? address,
      final String? city,
      final String? district,
      final String? postalCode,
      final String? landmark}) = _$ReportLocationImpl;

  factory _ReportLocation.fromJson(Map<String, dynamic> json) =
      _$ReportLocationImpl.fromJson;

  @override
  double get latitude;
  @override
  double get longitude;
  @override
  String? get address;
  @override
  String? get city;
  @override
  String? get district;
  @override
  String? get postalCode;
  @override
  String? get landmark;

  /// Create a copy of ReportLocation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReportLocationImplCopyWith<_$ReportLocationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ReportImage _$ReportImageFromJson(Map<String, dynamic> json) {
  return _ReportImage.fromJson(json);
}

/// @nodoc
mixin _$ReportImage {
  String get id => throw _privateConstructorUsedError;
  String get url => throw _privateConstructorUsedError;
  String? get thumbnailUrl => throw _privateConstructorUsedError;
  String? get filename => throw _privateConstructorUsedError;
  int? get fileSize => throw _privateConstructorUsedError;
  String? get mimeType => throw _privateConstructorUsedError;
  int get order => throw _privateConstructorUsedError;
  DateTime? get uploadedAt => throw _privateConstructorUsedError;

  /// Serializes this ReportImage to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ReportImage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReportImageCopyWith<ReportImage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReportImageCopyWith<$Res> {
  factory $ReportImageCopyWith(
          ReportImage value, $Res Function(ReportImage) then) =
      _$ReportImageCopyWithImpl<$Res, ReportImage>;
  @useResult
  $Res call(
      {String id,
      String url,
      String? thumbnailUrl,
      String? filename,
      int? fileSize,
      String? mimeType,
      int order,
      DateTime? uploadedAt});
}

/// @nodoc
class _$ReportImageCopyWithImpl<$Res, $Val extends ReportImage>
    implements $ReportImageCopyWith<$Res> {
  _$ReportImageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReportImage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? url = null,
    Object? thumbnailUrl = freezed,
    Object? filename = freezed,
    Object? fileSize = freezed,
    Object? mimeType = freezed,
    Object? order = null,
    Object? uploadedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      thumbnailUrl: freezed == thumbnailUrl
          ? _value.thumbnailUrl
          : thumbnailUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      filename: freezed == filename
          ? _value.filename
          : filename // ignore: cast_nullable_to_non_nullable
              as String?,
      fileSize: freezed == fileSize
          ? _value.fileSize
          : fileSize // ignore: cast_nullable_to_non_nullable
              as int?,
      mimeType: freezed == mimeType
          ? _value.mimeType
          : mimeType // ignore: cast_nullable_to_non_nullable
              as String?,
      order: null == order
          ? _value.order
          : order // ignore: cast_nullable_to_non_nullable
              as int,
      uploadedAt: freezed == uploadedAt
          ? _value.uploadedAt
          : uploadedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ReportImageImplCopyWith<$Res>
    implements $ReportImageCopyWith<$Res> {
  factory _$$ReportImageImplCopyWith(
          _$ReportImageImpl value, $Res Function(_$ReportImageImpl) then) =
      __$$ReportImageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String url,
      String? thumbnailUrl,
      String? filename,
      int? fileSize,
      String? mimeType,
      int order,
      DateTime? uploadedAt});
}

/// @nodoc
class __$$ReportImageImplCopyWithImpl<$Res>
    extends _$ReportImageCopyWithImpl<$Res, _$ReportImageImpl>
    implements _$$ReportImageImplCopyWith<$Res> {
  __$$ReportImageImplCopyWithImpl(
      _$ReportImageImpl _value, $Res Function(_$ReportImageImpl) _then)
      : super(_value, _then);

  /// Create a copy of ReportImage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? url = null,
    Object? thumbnailUrl = freezed,
    Object? filename = freezed,
    Object? fileSize = freezed,
    Object? mimeType = freezed,
    Object? order = null,
    Object? uploadedAt = freezed,
  }) {
    return _then(_$ReportImageImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      thumbnailUrl: freezed == thumbnailUrl
          ? _value.thumbnailUrl
          : thumbnailUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      filename: freezed == filename
          ? _value.filename
          : filename // ignore: cast_nullable_to_non_nullable
              as String?,
      fileSize: freezed == fileSize
          ? _value.fileSize
          : fileSize // ignore: cast_nullable_to_non_nullable
              as int?,
      mimeType: freezed == mimeType
          ? _value.mimeType
          : mimeType // ignore: cast_nullable_to_non_nullable
              as String?,
      order: null == order
          ? _value.order
          : order // ignore: cast_nullable_to_non_nullable
              as int,
      uploadedAt: freezed == uploadedAt
          ? _value.uploadedAt
          : uploadedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ReportImageImpl implements _ReportImage {
  const _$ReportImageImpl(
      {required this.id,
      required this.url,
      this.thumbnailUrl,
      this.filename,
      this.fileSize,
      this.mimeType,
      this.order = 0,
      this.uploadedAt});

  factory _$ReportImageImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReportImageImplFromJson(json);

  @override
  final String id;
  @override
  final String url;
  @override
  final String? thumbnailUrl;
  @override
  final String? filename;
  @override
  final int? fileSize;
  @override
  final String? mimeType;
  @override
  @JsonKey()
  final int order;
  @override
  final DateTime? uploadedAt;

  @override
  String toString() {
    return 'ReportImage(id: $id, url: $url, thumbnailUrl: $thumbnailUrl, filename: $filename, fileSize: $fileSize, mimeType: $mimeType, order: $order, uploadedAt: $uploadedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReportImageImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.thumbnailUrl, thumbnailUrl) ||
                other.thumbnailUrl == thumbnailUrl) &&
            (identical(other.filename, filename) ||
                other.filename == filename) &&
            (identical(other.fileSize, fileSize) ||
                other.fileSize == fileSize) &&
            (identical(other.mimeType, mimeType) ||
                other.mimeType == mimeType) &&
            (identical(other.order, order) || other.order == order) &&
            (identical(other.uploadedAt, uploadedAt) ||
                other.uploadedAt == uploadedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, url, thumbnailUrl, filename,
      fileSize, mimeType, order, uploadedAt);

  /// Create a copy of ReportImage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReportImageImplCopyWith<_$ReportImageImpl> get copyWith =>
      __$$ReportImageImplCopyWithImpl<_$ReportImageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReportImageImplToJson(
      this,
    );
  }
}

abstract class _ReportImage implements ReportImage {
  const factory _ReportImage(
      {required final String id,
      required final String url,
      final String? thumbnailUrl,
      final String? filename,
      final int? fileSize,
      final String? mimeType,
      final int order,
      final DateTime? uploadedAt}) = _$ReportImageImpl;

  factory _ReportImage.fromJson(Map<String, dynamic> json) =
      _$ReportImageImpl.fromJson;

  @override
  String get id;
  @override
  String get url;
  @override
  String? get thumbnailUrl;
  @override
  String? get filename;
  @override
  int? get fileSize;
  @override
  String? get mimeType;
  @override
  int get order;
  @override
  DateTime? get uploadedAt;

  /// Create a copy of ReportImage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReportImageImplCopyWith<_$ReportImageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AIAnalysisResult _$AIAnalysisResultFromJson(Map<String, dynamic> json) {
  return _AIAnalysisResult.fromJson(json);
}

/// @nodoc
mixin _$AIAnalysisResult {
  String get id => throw _privateConstructorUsedError;
  ReportType get detectedType => throw _privateConstructorUsedError;
  double get confidence => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;
  List<String>? get tags => throw _privateConstructorUsedError;
  Priority get suggestedPriority => throw _privateConstructorUsedError;
  DateTime? get analyzedAt => throw _privateConstructorUsedError;

  /// Serializes this AIAnalysisResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AIAnalysisResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AIAnalysisResultCopyWith<AIAnalysisResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AIAnalysisResultCopyWith<$Res> {
  factory $AIAnalysisResultCopyWith(
          AIAnalysisResult value, $Res Function(AIAnalysisResult) then) =
      _$AIAnalysisResultCopyWithImpl<$Res, AIAnalysisResult>;
  @useResult
  $Res call(
      {String id,
      ReportType detectedType,
      double confidence,
      String? description,
      Map<String, dynamic>? metadata,
      List<String>? tags,
      Priority suggestedPriority,
      DateTime? analyzedAt});
}

/// @nodoc
class _$AIAnalysisResultCopyWithImpl<$Res, $Val extends AIAnalysisResult>
    implements $AIAnalysisResultCopyWith<$Res> {
  _$AIAnalysisResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AIAnalysisResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? detectedType = null,
    Object? confidence = null,
    Object? description = freezed,
    Object? metadata = freezed,
    Object? tags = freezed,
    Object? suggestedPriority = null,
    Object? analyzedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      detectedType: null == detectedType
          ? _value.detectedType
          : detectedType // ignore: cast_nullable_to_non_nullable
              as ReportType,
      confidence: null == confidence
          ? _value.confidence
          : confidence // ignore: cast_nullable_to_non_nullable
              as double,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: freezed == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      tags: freezed == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      suggestedPriority: null == suggestedPriority
          ? _value.suggestedPriority
          : suggestedPriority // ignore: cast_nullable_to_non_nullable
              as Priority,
      analyzedAt: freezed == analyzedAt
          ? _value.analyzedAt
          : analyzedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AIAnalysisResultImplCopyWith<$Res>
    implements $AIAnalysisResultCopyWith<$Res> {
  factory _$$AIAnalysisResultImplCopyWith(_$AIAnalysisResultImpl value,
          $Res Function(_$AIAnalysisResultImpl) then) =
      __$$AIAnalysisResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      ReportType detectedType,
      double confidence,
      String? description,
      Map<String, dynamic>? metadata,
      List<String>? tags,
      Priority suggestedPriority,
      DateTime? analyzedAt});
}

/// @nodoc
class __$$AIAnalysisResultImplCopyWithImpl<$Res>
    extends _$AIAnalysisResultCopyWithImpl<$Res, _$AIAnalysisResultImpl>
    implements _$$AIAnalysisResultImplCopyWith<$Res> {
  __$$AIAnalysisResultImplCopyWithImpl(_$AIAnalysisResultImpl _value,
      $Res Function(_$AIAnalysisResultImpl) _then)
      : super(_value, _then);

  /// Create a copy of AIAnalysisResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? detectedType = null,
    Object? confidence = null,
    Object? description = freezed,
    Object? metadata = freezed,
    Object? tags = freezed,
    Object? suggestedPriority = null,
    Object? analyzedAt = freezed,
  }) {
    return _then(_$AIAnalysisResultImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      detectedType: null == detectedType
          ? _value.detectedType
          : detectedType // ignore: cast_nullable_to_non_nullable
              as ReportType,
      confidence: null == confidence
          ? _value.confidence
          : confidence // ignore: cast_nullable_to_non_nullable
              as double,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: freezed == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      tags: freezed == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      suggestedPriority: null == suggestedPriority
          ? _value.suggestedPriority
          : suggestedPriority // ignore: cast_nullable_to_non_nullable
              as Priority,
      analyzedAt: freezed == analyzedAt
          ? _value.analyzedAt
          : analyzedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AIAnalysisResultImpl implements _AIAnalysisResult {
  const _$AIAnalysisResultImpl(
      {required this.id,
      required this.detectedType,
      required this.confidence,
      this.description,
      final Map<String, dynamic>? metadata,
      final List<String>? tags,
      this.suggestedPriority = Priority.medium,
      this.analyzedAt})
      : _metadata = metadata,
        _tags = tags;

  factory _$AIAnalysisResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$AIAnalysisResultImplFromJson(json);

  @override
  final String id;
  @override
  final ReportType detectedType;
  @override
  final double confidence;
  @override
  final String? description;
  final Map<String, dynamic>? _metadata;
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final List<String>? _tags;
  @override
  List<String>? get tags {
    final value = _tags;
    if (value == null) return null;
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey()
  final Priority suggestedPriority;
  @override
  final DateTime? analyzedAt;

  @override
  String toString() {
    return 'AIAnalysisResult(id: $id, detectedType: $detectedType, confidence: $confidence, description: $description, metadata: $metadata, tags: $tags, suggestedPriority: $suggestedPriority, analyzedAt: $analyzedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AIAnalysisResultImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.detectedType, detectedType) ||
                other.detectedType == detectedType) &&
            (identical(other.confidence, confidence) ||
                other.confidence == confidence) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.suggestedPriority, suggestedPriority) ||
                other.suggestedPriority == suggestedPriority) &&
            (identical(other.analyzedAt, analyzedAt) ||
                other.analyzedAt == analyzedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      detectedType,
      confidence,
      description,
      const DeepCollectionEquality().hash(_metadata),
      const DeepCollectionEquality().hash(_tags),
      suggestedPriority,
      analyzedAt);

  /// Create a copy of AIAnalysisResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AIAnalysisResultImplCopyWith<_$AIAnalysisResultImpl> get copyWith =>
      __$$AIAnalysisResultImplCopyWithImpl<_$AIAnalysisResultImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AIAnalysisResultImplToJson(
      this,
    );
  }
}

abstract class _AIAnalysisResult implements AIAnalysisResult {
  const factory _AIAnalysisResult(
      {required final String id,
      required final ReportType detectedType,
      required final double confidence,
      final String? description,
      final Map<String, dynamic>? metadata,
      final List<String>? tags,
      final Priority suggestedPriority,
      final DateTime? analyzedAt}) = _$AIAnalysisResultImpl;

  factory _AIAnalysisResult.fromJson(Map<String, dynamic> json) =
      _$AIAnalysisResultImpl.fromJson;

  @override
  String get id;
  @override
  ReportType get detectedType;
  @override
  double get confidence;
  @override
  String? get description;
  @override
  Map<String, dynamic>? get metadata;
  @override
  List<String>? get tags;
  @override
  Priority get suggestedPriority;
  @override
  DateTime? get analyzedAt;

  /// Create a copy of AIAnalysisResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AIAnalysisResultImplCopyWith<_$AIAnalysisResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Report _$ReportFromJson(Map<String, dynamic> json) {
  return _Report.fromJson(json);
}

/// @nodoc
mixin _$Report {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  ReportType get type => throw _privateConstructorUsedError;
  ReportStatus get status => throw _privateConstructorUsedError;
  ReportLocation get location => throw _privateConstructorUsedError;
  List<ReportImage> get images => throw _privateConstructorUsedError;
  int get userId => throw _privateConstructorUsedError;
  String? get userFullName => throw _privateConstructorUsedError;
  Priority get priority => throw _privateConstructorUsedError;
  AIAnalysisResult? get aiAnalysis => throw _privateConstructorUsedError;
  DateTime? get submittedAt => throw _privateConstructorUsedError;
  DateTime? get reviewedAt => throw _privateConstructorUsedError;
  DateTime? get resolvedAt => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  String? get reviewComment => throw _privateConstructorUsedError;
  String? get resolutionComment => throw _privateConstructorUsedError;
  int? get assignedToUserId => throw _privateConstructorUsedError;
  String? get assignedToUserName => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;
  int get viewCount => throw _privateConstructorUsedError;
  int get likeCount => throw _privateConstructorUsedError;
  bool get isLiked => throw _privateConstructorUsedError;
  bool get isBookmarked => throw _privateConstructorUsedError;

  /// Serializes this Report to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Report
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReportCopyWith<Report> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReportCopyWith<$Res> {
  factory $ReportCopyWith(Report value, $Res Function(Report) then) =
      _$ReportCopyWithImpl<$Res, Report>;
  @useResult
  $Res call(
      {String id,
      String title,
      String description,
      ReportType type,
      ReportStatus status,
      ReportLocation location,
      List<ReportImage> images,
      int userId,
      String? userFullName,
      Priority priority,
      AIAnalysisResult? aiAnalysis,
      DateTime? submittedAt,
      DateTime? reviewedAt,
      DateTime? resolvedAt,
      DateTime createdAt,
      DateTime? updatedAt,
      String? reviewComment,
      String? resolutionComment,
      int? assignedToUserId,
      String? assignedToUserName,
      Map<String, dynamic>? metadata,
      int viewCount,
      int likeCount,
      bool isLiked,
      bool isBookmarked});

  $ReportLocationCopyWith<$Res> get location;
  $AIAnalysisResultCopyWith<$Res>? get aiAnalysis;
}

/// @nodoc
class _$ReportCopyWithImpl<$Res, $Val extends Report>
    implements $ReportCopyWith<$Res> {
  _$ReportCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Report
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? type = null,
    Object? status = null,
    Object? location = null,
    Object? images = null,
    Object? userId = null,
    Object? userFullName = freezed,
    Object? priority = null,
    Object? aiAnalysis = freezed,
    Object? submittedAt = freezed,
    Object? reviewedAt = freezed,
    Object? resolvedAt = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? reviewComment = freezed,
    Object? resolutionComment = freezed,
    Object? assignedToUserId = freezed,
    Object? assignedToUserName = freezed,
    Object? metadata = freezed,
    Object? viewCount = null,
    Object? likeCount = null,
    Object? isLiked = null,
    Object? isBookmarked = null,
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
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ReportType,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as ReportStatus,
      location: null == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as ReportLocation,
      images: null == images
          ? _value.images
          : images // ignore: cast_nullable_to_non_nullable
              as List<ReportImage>,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as int,
      userFullName: freezed == userFullName
          ? _value.userFullName
          : userFullName // ignore: cast_nullable_to_non_nullable
              as String?,
      priority: null == priority
          ? _value.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as Priority,
      aiAnalysis: freezed == aiAnalysis
          ? _value.aiAnalysis
          : aiAnalysis // ignore: cast_nullable_to_non_nullable
              as AIAnalysisResult?,
      submittedAt: freezed == submittedAt
          ? _value.submittedAt
          : submittedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      reviewedAt: freezed == reviewedAt
          ? _value.reviewedAt
          : reviewedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      resolvedAt: freezed == resolvedAt
          ? _value.resolvedAt
          : resolvedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      reviewComment: freezed == reviewComment
          ? _value.reviewComment
          : reviewComment // ignore: cast_nullable_to_non_nullable
              as String?,
      resolutionComment: freezed == resolutionComment
          ? _value.resolutionComment
          : resolutionComment // ignore: cast_nullable_to_non_nullable
              as String?,
      assignedToUserId: freezed == assignedToUserId
          ? _value.assignedToUserId
          : assignedToUserId // ignore: cast_nullable_to_non_nullable
              as int?,
      assignedToUserName: freezed == assignedToUserName
          ? _value.assignedToUserName
          : assignedToUserName // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: freezed == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      viewCount: null == viewCount
          ? _value.viewCount
          : viewCount // ignore: cast_nullable_to_non_nullable
              as int,
      likeCount: null == likeCount
          ? _value.likeCount
          : likeCount // ignore: cast_nullable_to_non_nullable
              as int,
      isLiked: null == isLiked
          ? _value.isLiked
          : isLiked // ignore: cast_nullable_to_non_nullable
              as bool,
      isBookmarked: null == isBookmarked
          ? _value.isBookmarked
          : isBookmarked // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }

  /// Create a copy of Report
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ReportLocationCopyWith<$Res> get location {
    return $ReportLocationCopyWith<$Res>(_value.location, (value) {
      return _then(_value.copyWith(location: value) as $Val);
    });
  }

  /// Create a copy of Report
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AIAnalysisResultCopyWith<$Res>? get aiAnalysis {
    if (_value.aiAnalysis == null) {
      return null;
    }

    return $AIAnalysisResultCopyWith<$Res>(_value.aiAnalysis!, (value) {
      return _then(_value.copyWith(aiAnalysis: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ReportImplCopyWith<$Res> implements $ReportCopyWith<$Res> {
  factory _$$ReportImplCopyWith(
          _$ReportImpl value, $Res Function(_$ReportImpl) then) =
      __$$ReportImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      String description,
      ReportType type,
      ReportStatus status,
      ReportLocation location,
      List<ReportImage> images,
      int userId,
      String? userFullName,
      Priority priority,
      AIAnalysisResult? aiAnalysis,
      DateTime? submittedAt,
      DateTime? reviewedAt,
      DateTime? resolvedAt,
      DateTime createdAt,
      DateTime? updatedAt,
      String? reviewComment,
      String? resolutionComment,
      int? assignedToUserId,
      String? assignedToUserName,
      Map<String, dynamic>? metadata,
      int viewCount,
      int likeCount,
      bool isLiked,
      bool isBookmarked});

  @override
  $ReportLocationCopyWith<$Res> get location;
  @override
  $AIAnalysisResultCopyWith<$Res>? get aiAnalysis;
}

/// @nodoc
class __$$ReportImplCopyWithImpl<$Res>
    extends _$ReportCopyWithImpl<$Res, _$ReportImpl>
    implements _$$ReportImplCopyWith<$Res> {
  __$$ReportImplCopyWithImpl(
      _$ReportImpl _value, $Res Function(_$ReportImpl) _then)
      : super(_value, _then);

  /// Create a copy of Report
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? type = null,
    Object? status = null,
    Object? location = null,
    Object? images = null,
    Object? userId = null,
    Object? userFullName = freezed,
    Object? priority = null,
    Object? aiAnalysis = freezed,
    Object? submittedAt = freezed,
    Object? reviewedAt = freezed,
    Object? resolvedAt = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? reviewComment = freezed,
    Object? resolutionComment = freezed,
    Object? assignedToUserId = freezed,
    Object? assignedToUserName = freezed,
    Object? metadata = freezed,
    Object? viewCount = null,
    Object? likeCount = null,
    Object? isLiked = null,
    Object? isBookmarked = null,
  }) {
    return _then(_$ReportImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ReportType,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as ReportStatus,
      location: null == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as ReportLocation,
      images: null == images
          ? _value._images
          : images // ignore: cast_nullable_to_non_nullable
              as List<ReportImage>,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as int,
      userFullName: freezed == userFullName
          ? _value.userFullName
          : userFullName // ignore: cast_nullable_to_non_nullable
              as String?,
      priority: null == priority
          ? _value.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as Priority,
      aiAnalysis: freezed == aiAnalysis
          ? _value.aiAnalysis
          : aiAnalysis // ignore: cast_nullable_to_non_nullable
              as AIAnalysisResult?,
      submittedAt: freezed == submittedAt
          ? _value.submittedAt
          : submittedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      reviewedAt: freezed == reviewedAt
          ? _value.reviewedAt
          : reviewedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      resolvedAt: freezed == resolvedAt
          ? _value.resolvedAt
          : resolvedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      reviewComment: freezed == reviewComment
          ? _value.reviewComment
          : reviewComment // ignore: cast_nullable_to_non_nullable
              as String?,
      resolutionComment: freezed == resolutionComment
          ? _value.resolutionComment
          : resolutionComment // ignore: cast_nullable_to_non_nullable
              as String?,
      assignedToUserId: freezed == assignedToUserId
          ? _value.assignedToUserId
          : assignedToUserId // ignore: cast_nullable_to_non_nullable
              as int?,
      assignedToUserName: freezed == assignedToUserName
          ? _value.assignedToUserName
          : assignedToUserName // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: freezed == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      viewCount: null == viewCount
          ? _value.viewCount
          : viewCount // ignore: cast_nullable_to_non_nullable
              as int,
      likeCount: null == likeCount
          ? _value.likeCount
          : likeCount // ignore: cast_nullable_to_non_nullable
              as int,
      isLiked: null == isLiked
          ? _value.isLiked
          : isLiked // ignore: cast_nullable_to_non_nullable
              as bool,
      isBookmarked: null == isBookmarked
          ? _value.isBookmarked
          : isBookmarked // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ReportImpl implements _Report {
  const _$ReportImpl(
      {required this.id,
      required this.title,
      required this.description,
      required this.type,
      required this.status,
      required this.location,
      required final List<ReportImage> images,
      required this.userId,
      this.userFullName,
      this.priority = Priority.medium,
      this.aiAnalysis,
      this.submittedAt,
      this.reviewedAt,
      this.resolvedAt,
      required this.createdAt,
      this.updatedAt,
      this.reviewComment,
      this.resolutionComment,
      this.assignedToUserId,
      this.assignedToUserName,
      final Map<String, dynamic>? metadata,
      this.viewCount = 0,
      this.likeCount = 0,
      this.isLiked = false,
      this.isBookmarked = false})
      : _images = images,
        _metadata = metadata;

  factory _$ReportImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReportImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String description;
  @override
  final ReportType type;
  @override
  final ReportStatus status;
  @override
  final ReportLocation location;
  final List<ReportImage> _images;
  @override
  List<ReportImage> get images {
    if (_images is EqualUnmodifiableListView) return _images;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_images);
  }

  @override
  final int userId;
  @override
  final String? userFullName;
  @override
  @JsonKey()
  final Priority priority;
  @override
  final AIAnalysisResult? aiAnalysis;
  @override
  final DateTime? submittedAt;
  @override
  final DateTime? reviewedAt;
  @override
  final DateTime? resolvedAt;
  @override
  final DateTime createdAt;
  @override
  final DateTime? updatedAt;
  @override
  final String? reviewComment;
  @override
  final String? resolutionComment;
  @override
  final int? assignedToUserId;
  @override
  final String? assignedToUserName;
  final Map<String, dynamic>? _metadata;
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  @JsonKey()
  final int viewCount;
  @override
  @JsonKey()
  final int likeCount;
  @override
  @JsonKey()
  final bool isLiked;
  @override
  @JsonKey()
  final bool isBookmarked;

  @override
  String toString() {
    return 'Report(id: $id, title: $title, description: $description, type: $type, status: $status, location: $location, images: $images, userId: $userId, userFullName: $userFullName, priority: $priority, aiAnalysis: $aiAnalysis, submittedAt: $submittedAt, reviewedAt: $reviewedAt, resolvedAt: $resolvedAt, createdAt: $createdAt, updatedAt: $updatedAt, reviewComment: $reviewComment, resolutionComment: $resolutionComment, assignedToUserId: $assignedToUserId, assignedToUserName: $assignedToUserName, metadata: $metadata, viewCount: $viewCount, likeCount: $likeCount, isLiked: $isLiked, isBookmarked: $isBookmarked)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReportImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.location, location) ||
                other.location == location) &&
            const DeepCollectionEquality().equals(other._images, _images) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.userFullName, userFullName) ||
                other.userFullName == userFullName) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            (identical(other.aiAnalysis, aiAnalysis) ||
                other.aiAnalysis == aiAnalysis) &&
            (identical(other.submittedAt, submittedAt) ||
                other.submittedAt == submittedAt) &&
            (identical(other.reviewedAt, reviewedAt) ||
                other.reviewedAt == reviewedAt) &&
            (identical(other.resolvedAt, resolvedAt) ||
                other.resolvedAt == resolvedAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.reviewComment, reviewComment) ||
                other.reviewComment == reviewComment) &&
            (identical(other.resolutionComment, resolutionComment) ||
                other.resolutionComment == resolutionComment) &&
            (identical(other.assignedToUserId, assignedToUserId) ||
                other.assignedToUserId == assignedToUserId) &&
            (identical(other.assignedToUserName, assignedToUserName) ||
                other.assignedToUserName == assignedToUserName) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata) &&
            (identical(other.viewCount, viewCount) ||
                other.viewCount == viewCount) &&
            (identical(other.likeCount, likeCount) ||
                other.likeCount == likeCount) &&
            (identical(other.isLiked, isLiked) || other.isLiked == isLiked) &&
            (identical(other.isBookmarked, isBookmarked) ||
                other.isBookmarked == isBookmarked));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        title,
        description,
        type,
        status,
        location,
        const DeepCollectionEquality().hash(_images),
        userId,
        userFullName,
        priority,
        aiAnalysis,
        submittedAt,
        reviewedAt,
        resolvedAt,
        createdAt,
        updatedAt,
        reviewComment,
        resolutionComment,
        assignedToUserId,
        assignedToUserName,
        const DeepCollectionEquality().hash(_metadata),
        viewCount,
        likeCount,
        isLiked,
        isBookmarked
      ]);

  /// Create a copy of Report
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReportImplCopyWith<_$ReportImpl> get copyWith =>
      __$$ReportImplCopyWithImpl<_$ReportImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReportImplToJson(
      this,
    );
  }
}

abstract class _Report implements Report {
  const factory _Report(
      {required final String id,
      required final String title,
      required final String description,
      required final ReportType type,
      required final ReportStatus status,
      required final ReportLocation location,
      required final List<ReportImage> images,
      required final int userId,
      final String? userFullName,
      final Priority priority,
      final AIAnalysisResult? aiAnalysis,
      final DateTime? submittedAt,
      final DateTime? reviewedAt,
      final DateTime? resolvedAt,
      required final DateTime createdAt,
      final DateTime? updatedAt,
      final String? reviewComment,
      final String? resolutionComment,
      final int? assignedToUserId,
      final String? assignedToUserName,
      final Map<String, dynamic>? metadata,
      final int viewCount,
      final int likeCount,
      final bool isLiked,
      final bool isBookmarked}) = _$ReportImpl;

  factory _Report.fromJson(Map<String, dynamic> json) = _$ReportImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get description;
  @override
  ReportType get type;
  @override
  ReportStatus get status;
  @override
  ReportLocation get location;
  @override
  List<ReportImage> get images;
  @override
  int get userId;
  @override
  String? get userFullName;
  @override
  Priority get priority;
  @override
  AIAnalysisResult? get aiAnalysis;
  @override
  DateTime? get submittedAt;
  @override
  DateTime? get reviewedAt;
  @override
  DateTime? get resolvedAt;
  @override
  DateTime get createdAt;
  @override
  DateTime? get updatedAt;
  @override
  String? get reviewComment;
  @override
  String? get resolutionComment;
  @override
  int? get assignedToUserId;
  @override
  String? get assignedToUserName;
  @override
  Map<String, dynamic>? get metadata;
  @override
  int get viewCount;
  @override
  int get likeCount;
  @override
  bool get isLiked;
  @override
  bool get isBookmarked;

  /// Create a copy of Report
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReportImplCopyWith<_$ReportImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ReportComment _$ReportCommentFromJson(Map<String, dynamic> json) {
  return _ReportComment.fromJson(json);
}

/// @nodoc
mixin _$ReportComment {
  String get id => throw _privateConstructorUsedError;
  String get reportId => throw _privateConstructorUsedError;
  int get userId => throw _privateConstructorUsedError;
  String get userFullName => throw _privateConstructorUsedError;
  String? get userProfileImage => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  bool get isEdited => throw _privateConstructorUsedError;
  bool get isDeleted => throw _privateConstructorUsedError;

  /// Serializes this ReportComment to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ReportComment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReportCommentCopyWith<ReportComment> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReportCommentCopyWith<$Res> {
  factory $ReportCommentCopyWith(
          ReportComment value, $Res Function(ReportComment) then) =
      _$ReportCommentCopyWithImpl<$Res, ReportComment>;
  @useResult
  $Res call(
      {String id,
      String reportId,
      int userId,
      String userFullName,
      String? userProfileImage,
      String content,
      DateTime? createdAt,
      DateTime? updatedAt,
      bool isEdited,
      bool isDeleted});
}

/// @nodoc
class _$ReportCommentCopyWithImpl<$Res, $Val extends ReportComment>
    implements $ReportCommentCopyWith<$Res> {
  _$ReportCommentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReportComment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? reportId = null,
    Object? userId = null,
    Object? userFullName = null,
    Object? userProfileImage = freezed,
    Object? content = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? isEdited = null,
    Object? isDeleted = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      reportId: null == reportId
          ? _value.reportId
          : reportId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as int,
      userFullName: null == userFullName
          ? _value.userFullName
          : userFullName // ignore: cast_nullable_to_non_nullable
              as String,
      userProfileImage: freezed == userProfileImage
          ? _value.userProfileImage
          : userProfileImage // ignore: cast_nullable_to_non_nullable
              as String?,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isEdited: null == isEdited
          ? _value.isEdited
          : isEdited // ignore: cast_nullable_to_non_nullable
              as bool,
      isDeleted: null == isDeleted
          ? _value.isDeleted
          : isDeleted // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ReportCommentImplCopyWith<$Res>
    implements $ReportCommentCopyWith<$Res> {
  factory _$$ReportCommentImplCopyWith(
          _$ReportCommentImpl value, $Res Function(_$ReportCommentImpl) then) =
      __$$ReportCommentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String reportId,
      int userId,
      String userFullName,
      String? userProfileImage,
      String content,
      DateTime? createdAt,
      DateTime? updatedAt,
      bool isEdited,
      bool isDeleted});
}

/// @nodoc
class __$$ReportCommentImplCopyWithImpl<$Res>
    extends _$ReportCommentCopyWithImpl<$Res, _$ReportCommentImpl>
    implements _$$ReportCommentImplCopyWith<$Res> {
  __$$ReportCommentImplCopyWithImpl(
      _$ReportCommentImpl _value, $Res Function(_$ReportCommentImpl) _then)
      : super(_value, _then);

  /// Create a copy of ReportComment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? reportId = null,
    Object? userId = null,
    Object? userFullName = null,
    Object? userProfileImage = freezed,
    Object? content = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? isEdited = null,
    Object? isDeleted = null,
  }) {
    return _then(_$ReportCommentImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      reportId: null == reportId
          ? _value.reportId
          : reportId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as int,
      userFullName: null == userFullName
          ? _value.userFullName
          : userFullName // ignore: cast_nullable_to_non_nullable
              as String,
      userProfileImage: freezed == userProfileImage
          ? _value.userProfileImage
          : userProfileImage // ignore: cast_nullable_to_non_nullable
              as String?,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isEdited: null == isEdited
          ? _value.isEdited
          : isEdited // ignore: cast_nullable_to_non_nullable
              as bool,
      isDeleted: null == isDeleted
          ? _value.isDeleted
          : isDeleted // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ReportCommentImpl implements _ReportComment {
  const _$ReportCommentImpl(
      {required this.id,
      required this.reportId,
      required this.userId,
      required this.userFullName,
      this.userProfileImage,
      required this.content,
      this.createdAt,
      this.updatedAt,
      this.isEdited = false,
      this.isDeleted = false});

  factory _$ReportCommentImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReportCommentImplFromJson(json);

  @override
  final String id;
  @override
  final String reportId;
  @override
  final int userId;
  @override
  final String userFullName;
  @override
  final String? userProfileImage;
  @override
  final String content;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;
  @override
  @JsonKey()
  final bool isEdited;
  @override
  @JsonKey()
  final bool isDeleted;

  @override
  String toString() {
    return 'ReportComment(id: $id, reportId: $reportId, userId: $userId, userFullName: $userFullName, userProfileImage: $userProfileImage, content: $content, createdAt: $createdAt, updatedAt: $updatedAt, isEdited: $isEdited, isDeleted: $isDeleted)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReportCommentImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.reportId, reportId) ||
                other.reportId == reportId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.userFullName, userFullName) ||
                other.userFullName == userFullName) &&
            (identical(other.userProfileImage, userProfileImage) ||
                other.userProfileImage == userProfileImage) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.isEdited, isEdited) ||
                other.isEdited == isEdited) &&
            (identical(other.isDeleted, isDeleted) ||
                other.isDeleted == isDeleted));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      reportId,
      userId,
      userFullName,
      userProfileImage,
      content,
      createdAt,
      updatedAt,
      isEdited,
      isDeleted);

  /// Create a copy of ReportComment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReportCommentImplCopyWith<_$ReportCommentImpl> get copyWith =>
      __$$ReportCommentImplCopyWithImpl<_$ReportCommentImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReportCommentImplToJson(
      this,
    );
  }
}

abstract class _ReportComment implements ReportComment {
  const factory _ReportComment(
      {required final String id,
      required final String reportId,
      required final int userId,
      required final String userFullName,
      final String? userProfileImage,
      required final String content,
      final DateTime? createdAt,
      final DateTime? updatedAt,
      final bool isEdited,
      final bool isDeleted}) = _$ReportCommentImpl;

  factory _ReportComment.fromJson(Map<String, dynamic> json) =
      _$ReportCommentImpl.fromJson;

  @override
  String get id;
  @override
  String get reportId;
  @override
  int get userId;
  @override
  String get userFullName;
  @override
  String? get userProfileImage;
  @override
  String get content;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;
  @override
  bool get isEdited;
  @override
  bool get isDeleted;

  /// Create a copy of ReportComment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReportCommentImplCopyWith<_$ReportCommentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
