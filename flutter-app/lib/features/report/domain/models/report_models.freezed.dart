// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'report_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CreateReportRequest _$CreateReportRequestFromJson(Map<String, dynamic> json) {
  return _CreateReportRequest.fromJson(json);
}

/// @nodoc
mixin _$CreateReportRequest {
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  ReportType get type => throw _privateConstructorUsedError;
  ReportLocation get location => throw _privateConstructorUsedError;
  List<String> get imageIds => throw _privateConstructorUsedError;
  Priority get priority => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;

  /// Serializes this CreateReportRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CreateReportRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreateReportRequestCopyWith<CreateReportRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateReportRequestCopyWith<$Res> {
  factory $CreateReportRequestCopyWith(
          CreateReportRequest value, $Res Function(CreateReportRequest) then) =
      _$CreateReportRequestCopyWithImpl<$Res, CreateReportRequest>;
  @useResult
  $Res call(
      {String title,
      String description,
      ReportType type,
      ReportLocation location,
      List<String> imageIds,
      Priority priority,
      Map<String, dynamic>? metadata});

  $ReportLocationCopyWith<$Res> get location;
}

/// @nodoc
class _$CreateReportRequestCopyWithImpl<$Res, $Val extends CreateReportRequest>
    implements $CreateReportRequestCopyWith<$Res> {
  _$CreateReportRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreateReportRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? description = null,
    Object? type = null,
    Object? location = null,
    Object? imageIds = null,
    Object? priority = null,
    Object? metadata = freezed,
  }) {
    return _then(_value.copyWith(
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
      location: null == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as ReportLocation,
      imageIds: null == imageIds
          ? _value.imageIds
          : imageIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      priority: null == priority
          ? _value.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as Priority,
      metadata: freezed == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }

  /// Create a copy of CreateReportRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ReportLocationCopyWith<$Res> get location {
    return $ReportLocationCopyWith<$Res>(_value.location, (value) {
      return _then(_value.copyWith(location: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CreateReportRequestImplCopyWith<$Res>
    implements $CreateReportRequestCopyWith<$Res> {
  factory _$$CreateReportRequestImplCopyWith(_$CreateReportRequestImpl value,
          $Res Function(_$CreateReportRequestImpl) then) =
      __$$CreateReportRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String title,
      String description,
      ReportType type,
      ReportLocation location,
      List<String> imageIds,
      Priority priority,
      Map<String, dynamic>? metadata});

  @override
  $ReportLocationCopyWith<$Res> get location;
}

/// @nodoc
class __$$CreateReportRequestImplCopyWithImpl<$Res>
    extends _$CreateReportRequestCopyWithImpl<$Res, _$CreateReportRequestImpl>
    implements _$$CreateReportRequestImplCopyWith<$Res> {
  __$$CreateReportRequestImplCopyWithImpl(_$CreateReportRequestImpl _value,
      $Res Function(_$CreateReportRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of CreateReportRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? description = null,
    Object? type = null,
    Object? location = null,
    Object? imageIds = null,
    Object? priority = null,
    Object? metadata = freezed,
  }) {
    return _then(_$CreateReportRequestImpl(
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
      location: null == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as ReportLocation,
      imageIds: null == imageIds
          ? _value._imageIds
          : imageIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      priority: null == priority
          ? _value.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as Priority,
      metadata: freezed == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CreateReportRequestImpl implements _CreateReportRequest {
  const _$CreateReportRequestImpl(
      {required this.title,
      required this.description,
      required this.type,
      required this.location,
      final List<String> imageIds = const [],
      this.priority = Priority.medium,
      final Map<String, dynamic>? metadata})
      : _imageIds = imageIds,
        _metadata = metadata;

  factory _$CreateReportRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreateReportRequestImplFromJson(json);

  @override
  final String title;
  @override
  final String description;
  @override
  final ReportType type;
  @override
  final ReportLocation location;
  final List<String> _imageIds;
  @override
  @JsonKey()
  List<String> get imageIds {
    if (_imageIds is EqualUnmodifiableListView) return _imageIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_imageIds);
  }

  @override
  @JsonKey()
  final Priority priority;
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
  String toString() {
    return 'CreateReportRequest(title: $title, description: $description, type: $type, location: $location, imageIds: $imageIds, priority: $priority, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateReportRequestImpl &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.location, location) ||
                other.location == location) &&
            const DeepCollectionEquality().equals(other._imageIds, _imageIds) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      title,
      description,
      type,
      location,
      const DeepCollectionEquality().hash(_imageIds),
      priority,
      const DeepCollectionEquality().hash(_metadata));

  /// Create a copy of CreateReportRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateReportRequestImplCopyWith<_$CreateReportRequestImpl> get copyWith =>
      __$$CreateReportRequestImplCopyWithImpl<_$CreateReportRequestImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CreateReportRequestImplToJson(
      this,
    );
  }
}

abstract class _CreateReportRequest implements CreateReportRequest {
  const factory _CreateReportRequest(
      {required final String title,
      required final String description,
      required final ReportType type,
      required final ReportLocation location,
      final List<String> imageIds,
      final Priority priority,
      final Map<String, dynamic>? metadata}) = _$CreateReportRequestImpl;

  factory _CreateReportRequest.fromJson(Map<String, dynamic> json) =
      _$CreateReportRequestImpl.fromJson;

  @override
  String get title;
  @override
  String get description;
  @override
  ReportType get type;
  @override
  ReportLocation get location;
  @override
  List<String> get imageIds;
  @override
  Priority get priority;
  @override
  Map<String, dynamic>? get metadata;

  /// Create a copy of CreateReportRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreateReportRequestImplCopyWith<_$CreateReportRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UpdateReportRequest _$UpdateReportRequestFromJson(Map<String, dynamic> json) {
  return _UpdateReportRequest.fromJson(json);
}

/// @nodoc
mixin _$UpdateReportRequest {
  String? get title => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  ReportType? get type => throw _privateConstructorUsedError;
  ReportLocation? get location => throw _privateConstructorUsedError;
  List<String>? get imageIds => throw _privateConstructorUsedError;
  Priority? get priority => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;

  /// Serializes this UpdateReportRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UpdateReportRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UpdateReportRequestCopyWith<UpdateReportRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UpdateReportRequestCopyWith<$Res> {
  factory $UpdateReportRequestCopyWith(
          UpdateReportRequest value, $Res Function(UpdateReportRequest) then) =
      _$UpdateReportRequestCopyWithImpl<$Res, UpdateReportRequest>;
  @useResult
  $Res call(
      {String? title,
      String? description,
      ReportType? type,
      ReportLocation? location,
      List<String>? imageIds,
      Priority? priority,
      Map<String, dynamic>? metadata});

  $ReportLocationCopyWith<$Res>? get location;
}

/// @nodoc
class _$UpdateReportRequestCopyWithImpl<$Res, $Val extends UpdateReportRequest>
    implements $UpdateReportRequestCopyWith<$Res> {
  _$UpdateReportRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UpdateReportRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = freezed,
    Object? description = freezed,
    Object? type = freezed,
    Object? location = freezed,
    Object? imageIds = freezed,
    Object? priority = freezed,
    Object? metadata = freezed,
  }) {
    return _then(_value.copyWith(
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      type: freezed == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ReportType?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as ReportLocation?,
      imageIds: freezed == imageIds
          ? _value.imageIds
          : imageIds // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      priority: freezed == priority
          ? _value.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as Priority?,
      metadata: freezed == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }

  /// Create a copy of UpdateReportRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ReportLocationCopyWith<$Res>? get location {
    if (_value.location == null) {
      return null;
    }

    return $ReportLocationCopyWith<$Res>(_value.location!, (value) {
      return _then(_value.copyWith(location: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$UpdateReportRequestImplCopyWith<$Res>
    implements $UpdateReportRequestCopyWith<$Res> {
  factory _$$UpdateReportRequestImplCopyWith(_$UpdateReportRequestImpl value,
          $Res Function(_$UpdateReportRequestImpl) then) =
      __$$UpdateReportRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? title,
      String? description,
      ReportType? type,
      ReportLocation? location,
      List<String>? imageIds,
      Priority? priority,
      Map<String, dynamic>? metadata});

  @override
  $ReportLocationCopyWith<$Res>? get location;
}

/// @nodoc
class __$$UpdateReportRequestImplCopyWithImpl<$Res>
    extends _$UpdateReportRequestCopyWithImpl<$Res, _$UpdateReportRequestImpl>
    implements _$$UpdateReportRequestImplCopyWith<$Res> {
  __$$UpdateReportRequestImplCopyWithImpl(_$UpdateReportRequestImpl _value,
      $Res Function(_$UpdateReportRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of UpdateReportRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = freezed,
    Object? description = freezed,
    Object? type = freezed,
    Object? location = freezed,
    Object? imageIds = freezed,
    Object? priority = freezed,
    Object? metadata = freezed,
  }) {
    return _then(_$UpdateReportRequestImpl(
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      type: freezed == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ReportType?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as ReportLocation?,
      imageIds: freezed == imageIds
          ? _value._imageIds
          : imageIds // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      priority: freezed == priority
          ? _value.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as Priority?,
      metadata: freezed == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UpdateReportRequestImpl implements _UpdateReportRequest {
  const _$UpdateReportRequestImpl(
      {this.title,
      this.description,
      this.type,
      this.location,
      final List<String>? imageIds,
      this.priority,
      final Map<String, dynamic>? metadata})
      : _imageIds = imageIds,
        _metadata = metadata;

  factory _$UpdateReportRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$UpdateReportRequestImplFromJson(json);

  @override
  final String? title;
  @override
  final String? description;
  @override
  final ReportType? type;
  @override
  final ReportLocation? location;
  final List<String>? _imageIds;
  @override
  List<String>? get imageIds {
    final value = _imageIds;
    if (value == null) return null;
    if (_imageIds is EqualUnmodifiableListView) return _imageIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final Priority? priority;
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
  String toString() {
    return 'UpdateReportRequest(title: $title, description: $description, type: $type, location: $location, imageIds: $imageIds, priority: $priority, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UpdateReportRequestImpl &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.location, location) ||
                other.location == location) &&
            const DeepCollectionEquality().equals(other._imageIds, _imageIds) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      title,
      description,
      type,
      location,
      const DeepCollectionEquality().hash(_imageIds),
      priority,
      const DeepCollectionEquality().hash(_metadata));

  /// Create a copy of UpdateReportRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UpdateReportRequestImplCopyWith<_$UpdateReportRequestImpl> get copyWith =>
      __$$UpdateReportRequestImplCopyWithImpl<_$UpdateReportRequestImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UpdateReportRequestImplToJson(
      this,
    );
  }
}

abstract class _UpdateReportRequest implements UpdateReportRequest {
  const factory _UpdateReportRequest(
      {final String? title,
      final String? description,
      final ReportType? type,
      final ReportLocation? location,
      final List<String>? imageIds,
      final Priority? priority,
      final Map<String, dynamic>? metadata}) = _$UpdateReportRequestImpl;

  factory _UpdateReportRequest.fromJson(Map<String, dynamic> json) =
      _$UpdateReportRequestImpl.fromJson;

  @override
  String? get title;
  @override
  String? get description;
  @override
  ReportType? get type;
  @override
  ReportLocation? get location;
  @override
  List<String>? get imageIds;
  @override
  Priority? get priority;
  @override
  Map<String, dynamic>? get metadata;

  /// Create a copy of UpdateReportRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UpdateReportRequestImplCopyWith<_$UpdateReportRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ReportListRequest _$ReportListRequestFromJson(Map<String, dynamic> json) {
  return _ReportListRequest.fromJson(json);
}

/// @nodoc
mixin _$ReportListRequest {
  int get page => throw _privateConstructorUsedError;
  int get size => throw _privateConstructorUsedError;
  String? get search => throw _privateConstructorUsedError;
  ReportType? get type => throw _privateConstructorUsedError;
  ReportStatus? get status => throw _privateConstructorUsedError;
  Priority? get priority => throw _privateConstructorUsedError;
  int? get userId => throw _privateConstructorUsedError;
  String? get sortBy => throw _privateConstructorUsedError;
  String get sortDirection => throw _privateConstructorUsedError;
  double? get latitude => throw _privateConstructorUsedError;
  double? get longitude => throw _privateConstructorUsedError;
  double? get radius => throw _privateConstructorUsedError;

  /// Serializes this ReportListRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ReportListRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReportListRequestCopyWith<ReportListRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReportListRequestCopyWith<$Res> {
  factory $ReportListRequestCopyWith(
          ReportListRequest value, $Res Function(ReportListRequest) then) =
      _$ReportListRequestCopyWithImpl<$Res, ReportListRequest>;
  @useResult
  $Res call(
      {int page,
      int size,
      String? search,
      ReportType? type,
      ReportStatus? status,
      Priority? priority,
      int? userId,
      String? sortBy,
      String sortDirection,
      double? latitude,
      double? longitude,
      double? radius});
}

/// @nodoc
class _$ReportListRequestCopyWithImpl<$Res, $Val extends ReportListRequest>
    implements $ReportListRequestCopyWith<$Res> {
  _$ReportListRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReportListRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? page = null,
    Object? size = null,
    Object? search = freezed,
    Object? type = freezed,
    Object? status = freezed,
    Object? priority = freezed,
    Object? userId = freezed,
    Object? sortBy = freezed,
    Object? sortDirection = null,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? radius = freezed,
  }) {
    return _then(_value.copyWith(
      page: null == page
          ? _value.page
          : page // ignore: cast_nullable_to_non_nullable
              as int,
      size: null == size
          ? _value.size
          : size // ignore: cast_nullable_to_non_nullable
              as int,
      search: freezed == search
          ? _value.search
          : search // ignore: cast_nullable_to_non_nullable
              as String?,
      type: freezed == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ReportType?,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as ReportStatus?,
      priority: freezed == priority
          ? _value.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as Priority?,
      userId: freezed == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as int?,
      sortBy: freezed == sortBy
          ? _value.sortBy
          : sortBy // ignore: cast_nullable_to_non_nullable
              as String?,
      sortDirection: null == sortDirection
          ? _value.sortDirection
          : sortDirection // ignore: cast_nullable_to_non_nullable
              as String,
      latitude: freezed == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double?,
      longitude: freezed == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double?,
      radius: freezed == radius
          ? _value.radius
          : radius // ignore: cast_nullable_to_non_nullable
              as double?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ReportListRequestImplCopyWith<$Res>
    implements $ReportListRequestCopyWith<$Res> {
  factory _$$ReportListRequestImplCopyWith(_$ReportListRequestImpl value,
          $Res Function(_$ReportListRequestImpl) then) =
      __$$ReportListRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int page,
      int size,
      String? search,
      ReportType? type,
      ReportStatus? status,
      Priority? priority,
      int? userId,
      String? sortBy,
      String sortDirection,
      double? latitude,
      double? longitude,
      double? radius});
}

/// @nodoc
class __$$ReportListRequestImplCopyWithImpl<$Res>
    extends _$ReportListRequestCopyWithImpl<$Res, _$ReportListRequestImpl>
    implements _$$ReportListRequestImplCopyWith<$Res> {
  __$$ReportListRequestImplCopyWithImpl(_$ReportListRequestImpl _value,
      $Res Function(_$ReportListRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of ReportListRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? page = null,
    Object? size = null,
    Object? search = freezed,
    Object? type = freezed,
    Object? status = freezed,
    Object? priority = freezed,
    Object? userId = freezed,
    Object? sortBy = freezed,
    Object? sortDirection = null,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? radius = freezed,
  }) {
    return _then(_$ReportListRequestImpl(
      page: null == page
          ? _value.page
          : page // ignore: cast_nullable_to_non_nullable
              as int,
      size: null == size
          ? _value.size
          : size // ignore: cast_nullable_to_non_nullable
              as int,
      search: freezed == search
          ? _value.search
          : search // ignore: cast_nullable_to_non_nullable
              as String?,
      type: freezed == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ReportType?,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as ReportStatus?,
      priority: freezed == priority
          ? _value.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as Priority?,
      userId: freezed == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as int?,
      sortBy: freezed == sortBy
          ? _value.sortBy
          : sortBy // ignore: cast_nullable_to_non_nullable
              as String?,
      sortDirection: null == sortDirection
          ? _value.sortDirection
          : sortDirection // ignore: cast_nullable_to_non_nullable
              as String,
      latitude: freezed == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double?,
      longitude: freezed == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double?,
      radius: freezed == radius
          ? _value.radius
          : radius // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ReportListRequestImpl implements _ReportListRequest {
  const _$ReportListRequestImpl(
      {this.page = 0,
      this.size = 20,
      this.search,
      this.type,
      this.status,
      this.priority,
      this.userId,
      this.sortBy,
      this.sortDirection = 'desc',
      this.latitude,
      this.longitude,
      this.radius});

  factory _$ReportListRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReportListRequestImplFromJson(json);

  @override
  @JsonKey()
  final int page;
  @override
  @JsonKey()
  final int size;
  @override
  final String? search;
  @override
  final ReportType? type;
  @override
  final ReportStatus? status;
  @override
  final Priority? priority;
  @override
  final int? userId;
  @override
  final String? sortBy;
  @override
  @JsonKey()
  final String sortDirection;
  @override
  final double? latitude;
  @override
  final double? longitude;
  @override
  final double? radius;

  @override
  String toString() {
    return 'ReportListRequest(page: $page, size: $size, search: $search, type: $type, status: $status, priority: $priority, userId: $userId, sortBy: $sortBy, sortDirection: $sortDirection, latitude: $latitude, longitude: $longitude, radius: $radius)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReportListRequestImpl &&
            (identical(other.page, page) || other.page == page) &&
            (identical(other.size, size) || other.size == size) &&
            (identical(other.search, search) || other.search == search) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.sortBy, sortBy) || other.sortBy == sortBy) &&
            (identical(other.sortDirection, sortDirection) ||
                other.sortDirection == sortDirection) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.radius, radius) || other.radius == radius));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, page, size, search, type, status,
      priority, userId, sortBy, sortDirection, latitude, longitude, radius);

  /// Create a copy of ReportListRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReportListRequestImplCopyWith<_$ReportListRequestImpl> get copyWith =>
      __$$ReportListRequestImplCopyWithImpl<_$ReportListRequestImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReportListRequestImplToJson(
      this,
    );
  }
}

abstract class _ReportListRequest implements ReportListRequest {
  const factory _ReportListRequest(
      {final int page,
      final int size,
      final String? search,
      final ReportType? type,
      final ReportStatus? status,
      final Priority? priority,
      final int? userId,
      final String? sortBy,
      final String sortDirection,
      final double? latitude,
      final double? longitude,
      final double? radius}) = _$ReportListRequestImpl;

  factory _ReportListRequest.fromJson(Map<String, dynamic> json) =
      _$ReportListRequestImpl.fromJson;

  @override
  int get page;
  @override
  int get size;
  @override
  String? get search;
  @override
  ReportType? get type;
  @override
  ReportStatus? get status;
  @override
  Priority? get priority;
  @override
  int? get userId;
  @override
  String? get sortBy;
  @override
  String get sortDirection;
  @override
  double? get latitude;
  @override
  double? get longitude;
  @override
  double? get radius;

  /// Create a copy of ReportListRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReportListRequestImplCopyWith<_$ReportListRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ReportListResponse _$ReportListResponseFromJson(Map<String, dynamic> json) {
  return _ReportListResponse.fromJson(json);
}

/// @nodoc
mixin _$ReportListResponse {
  List<Report> get reports => throw _privateConstructorUsedError;
  int get totalElements => throw _privateConstructorUsedError;
  int get totalPages => throw _privateConstructorUsedError;
  int get currentPage => throw _privateConstructorUsedError;
  int get size => throw _privateConstructorUsedError;
  bool get hasNext => throw _privateConstructorUsedError;
  bool get hasPrevious => throw _privateConstructorUsedError;

  /// Serializes this ReportListResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ReportListResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReportListResponseCopyWith<ReportListResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReportListResponseCopyWith<$Res> {
  factory $ReportListResponseCopyWith(
          ReportListResponse value, $Res Function(ReportListResponse) then) =
      _$ReportListResponseCopyWithImpl<$Res, ReportListResponse>;
  @useResult
  $Res call(
      {List<Report> reports,
      int totalElements,
      int totalPages,
      int currentPage,
      int size,
      bool hasNext,
      bool hasPrevious});
}

/// @nodoc
class _$ReportListResponseCopyWithImpl<$Res, $Val extends ReportListResponse>
    implements $ReportListResponseCopyWith<$Res> {
  _$ReportListResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReportListResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? reports = null,
    Object? totalElements = null,
    Object? totalPages = null,
    Object? currentPage = null,
    Object? size = null,
    Object? hasNext = null,
    Object? hasPrevious = null,
  }) {
    return _then(_value.copyWith(
      reports: null == reports
          ? _value.reports
          : reports // ignore: cast_nullable_to_non_nullable
              as List<Report>,
      totalElements: null == totalElements
          ? _value.totalElements
          : totalElements // ignore: cast_nullable_to_non_nullable
              as int,
      totalPages: null == totalPages
          ? _value.totalPages
          : totalPages // ignore: cast_nullable_to_non_nullable
              as int,
      currentPage: null == currentPage
          ? _value.currentPage
          : currentPage // ignore: cast_nullable_to_non_nullable
              as int,
      size: null == size
          ? _value.size
          : size // ignore: cast_nullable_to_non_nullable
              as int,
      hasNext: null == hasNext
          ? _value.hasNext
          : hasNext // ignore: cast_nullable_to_non_nullable
              as bool,
      hasPrevious: null == hasPrevious
          ? _value.hasPrevious
          : hasPrevious // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ReportListResponseImplCopyWith<$Res>
    implements $ReportListResponseCopyWith<$Res> {
  factory _$$ReportListResponseImplCopyWith(_$ReportListResponseImpl value,
          $Res Function(_$ReportListResponseImpl) then) =
      __$$ReportListResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<Report> reports,
      int totalElements,
      int totalPages,
      int currentPage,
      int size,
      bool hasNext,
      bool hasPrevious});
}

/// @nodoc
class __$$ReportListResponseImplCopyWithImpl<$Res>
    extends _$ReportListResponseCopyWithImpl<$Res, _$ReportListResponseImpl>
    implements _$$ReportListResponseImplCopyWith<$Res> {
  __$$ReportListResponseImplCopyWithImpl(_$ReportListResponseImpl _value,
      $Res Function(_$ReportListResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of ReportListResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? reports = null,
    Object? totalElements = null,
    Object? totalPages = null,
    Object? currentPage = null,
    Object? size = null,
    Object? hasNext = null,
    Object? hasPrevious = null,
  }) {
    return _then(_$ReportListResponseImpl(
      reports: null == reports
          ? _value._reports
          : reports // ignore: cast_nullable_to_non_nullable
              as List<Report>,
      totalElements: null == totalElements
          ? _value.totalElements
          : totalElements // ignore: cast_nullable_to_non_nullable
              as int,
      totalPages: null == totalPages
          ? _value.totalPages
          : totalPages // ignore: cast_nullable_to_non_nullable
              as int,
      currentPage: null == currentPage
          ? _value.currentPage
          : currentPage // ignore: cast_nullable_to_non_nullable
              as int,
      size: null == size
          ? _value.size
          : size // ignore: cast_nullable_to_non_nullable
              as int,
      hasNext: null == hasNext
          ? _value.hasNext
          : hasNext // ignore: cast_nullable_to_non_nullable
              as bool,
      hasPrevious: null == hasPrevious
          ? _value.hasPrevious
          : hasPrevious // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ReportListResponseImpl implements _ReportListResponse {
  const _$ReportListResponseImpl(
      {required final List<Report> reports,
      required this.totalElements,
      required this.totalPages,
      required this.currentPage,
      required this.size,
      this.hasNext = false,
      this.hasPrevious = false})
      : _reports = reports;

  factory _$ReportListResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReportListResponseImplFromJson(json);

  final List<Report> _reports;
  @override
  List<Report> get reports {
    if (_reports is EqualUnmodifiableListView) return _reports;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_reports);
  }

  @override
  final int totalElements;
  @override
  final int totalPages;
  @override
  final int currentPage;
  @override
  final int size;
  @override
  @JsonKey()
  final bool hasNext;
  @override
  @JsonKey()
  final bool hasPrevious;

  @override
  String toString() {
    return 'ReportListResponse(reports: $reports, totalElements: $totalElements, totalPages: $totalPages, currentPage: $currentPage, size: $size, hasNext: $hasNext, hasPrevious: $hasPrevious)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReportListResponseImpl &&
            const DeepCollectionEquality().equals(other._reports, _reports) &&
            (identical(other.totalElements, totalElements) ||
                other.totalElements == totalElements) &&
            (identical(other.totalPages, totalPages) ||
                other.totalPages == totalPages) &&
            (identical(other.currentPage, currentPage) ||
                other.currentPage == currentPage) &&
            (identical(other.size, size) || other.size == size) &&
            (identical(other.hasNext, hasNext) || other.hasNext == hasNext) &&
            (identical(other.hasPrevious, hasPrevious) ||
                other.hasPrevious == hasPrevious));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_reports),
      totalElements,
      totalPages,
      currentPage,
      size,
      hasNext,
      hasPrevious);

  /// Create a copy of ReportListResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReportListResponseImplCopyWith<_$ReportListResponseImpl> get copyWith =>
      __$$ReportListResponseImplCopyWithImpl<_$ReportListResponseImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReportListResponseImplToJson(
      this,
    );
  }
}

abstract class _ReportListResponse implements ReportListResponse {
  const factory _ReportListResponse(
      {required final List<Report> reports,
      required final int totalElements,
      required final int totalPages,
      required final int currentPage,
      required final int size,
      final bool hasNext,
      final bool hasPrevious}) = _$ReportListResponseImpl;

  factory _ReportListResponse.fromJson(Map<String, dynamic> json) =
      _$ReportListResponseImpl.fromJson;

  @override
  List<Report> get reports;
  @override
  int get totalElements;
  @override
  int get totalPages;
  @override
  int get currentPage;
  @override
  int get size;
  @override
  bool get hasNext;
  @override
  bool get hasPrevious;

  /// Create a copy of ReportListResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReportListResponseImplCopyWith<_$ReportListResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ImageUploadRequest _$ImageUploadRequestFromJson(Map<String, dynamic> json) {
  return _ImageUploadRequest.fromJson(json);
}

/// @nodoc
mixin _$ImageUploadRequest {
  String get filename => throw _privateConstructorUsedError;
  String get mimeType => throw _privateConstructorUsedError;
  int get fileSize => throw _privateConstructorUsedError;

  /// Serializes this ImageUploadRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ImageUploadRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ImageUploadRequestCopyWith<ImageUploadRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ImageUploadRequestCopyWith<$Res> {
  factory $ImageUploadRequestCopyWith(
          ImageUploadRequest value, $Res Function(ImageUploadRequest) then) =
      _$ImageUploadRequestCopyWithImpl<$Res, ImageUploadRequest>;
  @useResult
  $Res call({String filename, String mimeType, int fileSize});
}

/// @nodoc
class _$ImageUploadRequestCopyWithImpl<$Res, $Val extends ImageUploadRequest>
    implements $ImageUploadRequestCopyWith<$Res> {
  _$ImageUploadRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ImageUploadRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? filename = null,
    Object? mimeType = null,
    Object? fileSize = null,
  }) {
    return _then(_value.copyWith(
      filename: null == filename
          ? _value.filename
          : filename // ignore: cast_nullable_to_non_nullable
              as String,
      mimeType: null == mimeType
          ? _value.mimeType
          : mimeType // ignore: cast_nullable_to_non_nullable
              as String,
      fileSize: null == fileSize
          ? _value.fileSize
          : fileSize // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ImageUploadRequestImplCopyWith<$Res>
    implements $ImageUploadRequestCopyWith<$Res> {
  factory _$$ImageUploadRequestImplCopyWith(_$ImageUploadRequestImpl value,
          $Res Function(_$ImageUploadRequestImpl) then) =
      __$$ImageUploadRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String filename, String mimeType, int fileSize});
}

/// @nodoc
class __$$ImageUploadRequestImplCopyWithImpl<$Res>
    extends _$ImageUploadRequestCopyWithImpl<$Res, _$ImageUploadRequestImpl>
    implements _$$ImageUploadRequestImplCopyWith<$Res> {
  __$$ImageUploadRequestImplCopyWithImpl(_$ImageUploadRequestImpl _value,
      $Res Function(_$ImageUploadRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of ImageUploadRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? filename = null,
    Object? mimeType = null,
    Object? fileSize = null,
  }) {
    return _then(_$ImageUploadRequestImpl(
      filename: null == filename
          ? _value.filename
          : filename // ignore: cast_nullable_to_non_nullable
              as String,
      mimeType: null == mimeType
          ? _value.mimeType
          : mimeType // ignore: cast_nullable_to_non_nullable
              as String,
      fileSize: null == fileSize
          ? _value.fileSize
          : fileSize // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ImageUploadRequestImpl implements _ImageUploadRequest {
  const _$ImageUploadRequestImpl(
      {required this.filename, required this.mimeType, required this.fileSize});

  factory _$ImageUploadRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$ImageUploadRequestImplFromJson(json);

  @override
  final String filename;
  @override
  final String mimeType;
  @override
  final int fileSize;

  @override
  String toString() {
    return 'ImageUploadRequest(filename: $filename, mimeType: $mimeType, fileSize: $fileSize)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ImageUploadRequestImpl &&
            (identical(other.filename, filename) ||
                other.filename == filename) &&
            (identical(other.mimeType, mimeType) ||
                other.mimeType == mimeType) &&
            (identical(other.fileSize, fileSize) ||
                other.fileSize == fileSize));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, filename, mimeType, fileSize);

  /// Create a copy of ImageUploadRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ImageUploadRequestImplCopyWith<_$ImageUploadRequestImpl> get copyWith =>
      __$$ImageUploadRequestImplCopyWithImpl<_$ImageUploadRequestImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ImageUploadRequestImplToJson(
      this,
    );
  }
}

abstract class _ImageUploadRequest implements ImageUploadRequest {
  const factory _ImageUploadRequest(
      {required final String filename,
      required final String mimeType,
      required final int fileSize}) = _$ImageUploadRequestImpl;

  factory _ImageUploadRequest.fromJson(Map<String, dynamic> json) =
      _$ImageUploadRequestImpl.fromJson;

  @override
  String get filename;
  @override
  String get mimeType;
  @override
  int get fileSize;

  /// Create a copy of ImageUploadRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ImageUploadRequestImplCopyWith<_$ImageUploadRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ImageUploadResponse _$ImageUploadResponseFromJson(Map<String, dynamic> json) {
  return _ImageUploadResponse.fromJson(json);
}

/// @nodoc
mixin _$ImageUploadResponse {
  String get imageId => throw _privateConstructorUsedError;
  String get uploadUrl => throw _privateConstructorUsedError;
  String get imageUrl => throw _privateConstructorUsedError;
  String? get thumbnailUrl => throw _privateConstructorUsedError;
  DateTime? get expiresAt => throw _privateConstructorUsedError;

  /// Serializes this ImageUploadResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ImageUploadResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ImageUploadResponseCopyWith<ImageUploadResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ImageUploadResponseCopyWith<$Res> {
  factory $ImageUploadResponseCopyWith(
          ImageUploadResponse value, $Res Function(ImageUploadResponse) then) =
      _$ImageUploadResponseCopyWithImpl<$Res, ImageUploadResponse>;
  @useResult
  $Res call(
      {String imageId,
      String uploadUrl,
      String imageUrl,
      String? thumbnailUrl,
      DateTime? expiresAt});
}

/// @nodoc
class _$ImageUploadResponseCopyWithImpl<$Res, $Val extends ImageUploadResponse>
    implements $ImageUploadResponseCopyWith<$Res> {
  _$ImageUploadResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ImageUploadResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? imageId = null,
    Object? uploadUrl = null,
    Object? imageUrl = null,
    Object? thumbnailUrl = freezed,
    Object? expiresAt = freezed,
  }) {
    return _then(_value.copyWith(
      imageId: null == imageId
          ? _value.imageId
          : imageId // ignore: cast_nullable_to_non_nullable
              as String,
      uploadUrl: null == uploadUrl
          ? _value.uploadUrl
          : uploadUrl // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: null == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      thumbnailUrl: freezed == thumbnailUrl
          ? _value.thumbnailUrl
          : thumbnailUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      expiresAt: freezed == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ImageUploadResponseImplCopyWith<$Res>
    implements $ImageUploadResponseCopyWith<$Res> {
  factory _$$ImageUploadResponseImplCopyWith(_$ImageUploadResponseImpl value,
          $Res Function(_$ImageUploadResponseImpl) then) =
      __$$ImageUploadResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String imageId,
      String uploadUrl,
      String imageUrl,
      String? thumbnailUrl,
      DateTime? expiresAt});
}

/// @nodoc
class __$$ImageUploadResponseImplCopyWithImpl<$Res>
    extends _$ImageUploadResponseCopyWithImpl<$Res, _$ImageUploadResponseImpl>
    implements _$$ImageUploadResponseImplCopyWith<$Res> {
  __$$ImageUploadResponseImplCopyWithImpl(_$ImageUploadResponseImpl _value,
      $Res Function(_$ImageUploadResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of ImageUploadResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? imageId = null,
    Object? uploadUrl = null,
    Object? imageUrl = null,
    Object? thumbnailUrl = freezed,
    Object? expiresAt = freezed,
  }) {
    return _then(_$ImageUploadResponseImpl(
      imageId: null == imageId
          ? _value.imageId
          : imageId // ignore: cast_nullable_to_non_nullable
              as String,
      uploadUrl: null == uploadUrl
          ? _value.uploadUrl
          : uploadUrl // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: null == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      thumbnailUrl: freezed == thumbnailUrl
          ? _value.thumbnailUrl
          : thumbnailUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      expiresAt: freezed == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ImageUploadResponseImpl implements _ImageUploadResponse {
  const _$ImageUploadResponseImpl(
      {required this.imageId,
      required this.uploadUrl,
      required this.imageUrl,
      this.thumbnailUrl,
      this.expiresAt});

  factory _$ImageUploadResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$ImageUploadResponseImplFromJson(json);

  @override
  final String imageId;
  @override
  final String uploadUrl;
  @override
  final String imageUrl;
  @override
  final String? thumbnailUrl;
  @override
  final DateTime? expiresAt;

  @override
  String toString() {
    return 'ImageUploadResponse(imageId: $imageId, uploadUrl: $uploadUrl, imageUrl: $imageUrl, thumbnailUrl: $thumbnailUrl, expiresAt: $expiresAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ImageUploadResponseImpl &&
            (identical(other.imageId, imageId) || other.imageId == imageId) &&
            (identical(other.uploadUrl, uploadUrl) ||
                other.uploadUrl == uploadUrl) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.thumbnailUrl, thumbnailUrl) ||
                other.thumbnailUrl == thumbnailUrl) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, imageId, uploadUrl, imageUrl, thumbnailUrl, expiresAt);

  /// Create a copy of ImageUploadResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ImageUploadResponseImplCopyWith<_$ImageUploadResponseImpl> get copyWith =>
      __$$ImageUploadResponseImplCopyWithImpl<_$ImageUploadResponseImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ImageUploadResponseImplToJson(
      this,
    );
  }
}

abstract class _ImageUploadResponse implements ImageUploadResponse {
  const factory _ImageUploadResponse(
      {required final String imageId,
      required final String uploadUrl,
      required final String imageUrl,
      final String? thumbnailUrl,
      final DateTime? expiresAt}) = _$ImageUploadResponseImpl;

  factory _ImageUploadResponse.fromJson(Map<String, dynamic> json) =
      _$ImageUploadResponseImpl.fromJson;

  @override
  String get imageId;
  @override
  String get uploadUrl;
  @override
  String get imageUrl;
  @override
  String? get thumbnailUrl;
  @override
  DateTime? get expiresAt;

  /// Create a copy of ImageUploadResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ImageUploadResponseImplCopyWith<_$ImageUploadResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AIAnalysisRequest _$AIAnalysisRequestFromJson(Map<String, dynamic> json) {
  return _AIAnalysisRequest.fromJson(json);
}

/// @nodoc
mixin _$AIAnalysisRequest {
  String get imageId => throw _privateConstructorUsedError;
  ReportType? get expectedType => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;

  /// Serializes this AIAnalysisRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AIAnalysisRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AIAnalysisRequestCopyWith<AIAnalysisRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AIAnalysisRequestCopyWith<$Res> {
  factory $AIAnalysisRequestCopyWith(
          AIAnalysisRequest value, $Res Function(AIAnalysisRequest) then) =
      _$AIAnalysisRequestCopyWithImpl<$Res, AIAnalysisRequest>;
  @useResult
  $Res call(
      {String imageId,
      ReportType? expectedType,
      Map<String, dynamic>? metadata});
}

/// @nodoc
class _$AIAnalysisRequestCopyWithImpl<$Res, $Val extends AIAnalysisRequest>
    implements $AIAnalysisRequestCopyWith<$Res> {
  _$AIAnalysisRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AIAnalysisRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? imageId = null,
    Object? expectedType = freezed,
    Object? metadata = freezed,
  }) {
    return _then(_value.copyWith(
      imageId: null == imageId
          ? _value.imageId
          : imageId // ignore: cast_nullable_to_non_nullable
              as String,
      expectedType: freezed == expectedType
          ? _value.expectedType
          : expectedType // ignore: cast_nullable_to_non_nullable
              as ReportType?,
      metadata: freezed == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AIAnalysisRequestImplCopyWith<$Res>
    implements $AIAnalysisRequestCopyWith<$Res> {
  factory _$$AIAnalysisRequestImplCopyWith(_$AIAnalysisRequestImpl value,
          $Res Function(_$AIAnalysisRequestImpl) then) =
      __$$AIAnalysisRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String imageId,
      ReportType? expectedType,
      Map<String, dynamic>? metadata});
}

/// @nodoc
class __$$AIAnalysisRequestImplCopyWithImpl<$Res>
    extends _$AIAnalysisRequestCopyWithImpl<$Res, _$AIAnalysisRequestImpl>
    implements _$$AIAnalysisRequestImplCopyWith<$Res> {
  __$$AIAnalysisRequestImplCopyWithImpl(_$AIAnalysisRequestImpl _value,
      $Res Function(_$AIAnalysisRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of AIAnalysisRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? imageId = null,
    Object? expectedType = freezed,
    Object? metadata = freezed,
  }) {
    return _then(_$AIAnalysisRequestImpl(
      imageId: null == imageId
          ? _value.imageId
          : imageId // ignore: cast_nullable_to_non_nullable
              as String,
      expectedType: freezed == expectedType
          ? _value.expectedType
          : expectedType // ignore: cast_nullable_to_non_nullable
              as ReportType?,
      metadata: freezed == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AIAnalysisRequestImpl implements _AIAnalysisRequest {
  const _$AIAnalysisRequestImpl(
      {required this.imageId,
      this.expectedType,
      final Map<String, dynamic>? metadata})
      : _metadata = metadata;

  factory _$AIAnalysisRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$AIAnalysisRequestImplFromJson(json);

  @override
  final String imageId;
  @override
  final ReportType? expectedType;
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
  String toString() {
    return 'AIAnalysisRequest(imageId: $imageId, expectedType: $expectedType, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AIAnalysisRequestImpl &&
            (identical(other.imageId, imageId) || other.imageId == imageId) &&
            (identical(other.expectedType, expectedType) ||
                other.expectedType == expectedType) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, imageId, expectedType,
      const DeepCollectionEquality().hash(_metadata));

  /// Create a copy of AIAnalysisRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AIAnalysisRequestImplCopyWith<_$AIAnalysisRequestImpl> get copyWith =>
      __$$AIAnalysisRequestImplCopyWithImpl<_$AIAnalysisRequestImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AIAnalysisRequestImplToJson(
      this,
    );
  }
}

abstract class _AIAnalysisRequest implements AIAnalysisRequest {
  const factory _AIAnalysisRequest(
      {required final String imageId,
      final ReportType? expectedType,
      final Map<String, dynamic>? metadata}) = _$AIAnalysisRequestImpl;

  factory _AIAnalysisRequest.fromJson(Map<String, dynamic> json) =
      _$AIAnalysisRequestImpl.fromJson;

  @override
  String get imageId;
  @override
  ReportType? get expectedType;
  @override
  Map<String, dynamic>? get metadata;

  /// Create a copy of AIAnalysisRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AIAnalysisRequestImplCopyWith<_$AIAnalysisRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ReportStatsResponse _$ReportStatsResponseFromJson(Map<String, dynamic> json) {
  return _ReportStatsResponse.fromJson(json);
}

/// @nodoc
mixin _$ReportStatsResponse {
  int get totalReports => throw _privateConstructorUsedError;
  int get submittedReports => throw _privateConstructorUsedError;
  int get inReviewReports => throw _privateConstructorUsedError;
  int get approvedReports => throw _privateConstructorUsedError;
  int get resolvedReports => throw _privateConstructorUsedError;
  int get rejectedReports => throw _privateConstructorUsedError;
  Map<String, int> get reportsByType => throw _privateConstructorUsedError;
  Map<String, int> get reportsByPriority => throw _privateConstructorUsedError;
  Map<String, int> get reportsByMonth => throw _privateConstructorUsedError;

  /// Serializes this ReportStatsResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ReportStatsResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReportStatsResponseCopyWith<ReportStatsResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReportStatsResponseCopyWith<$Res> {
  factory $ReportStatsResponseCopyWith(
          ReportStatsResponse value, $Res Function(ReportStatsResponse) then) =
      _$ReportStatsResponseCopyWithImpl<$Res, ReportStatsResponse>;
  @useResult
  $Res call(
      {int totalReports,
      int submittedReports,
      int inReviewReports,
      int approvedReports,
      int resolvedReports,
      int rejectedReports,
      Map<String, int> reportsByType,
      Map<String, int> reportsByPriority,
      Map<String, int> reportsByMonth});
}

/// @nodoc
class _$ReportStatsResponseCopyWithImpl<$Res, $Val extends ReportStatsResponse>
    implements $ReportStatsResponseCopyWith<$Res> {
  _$ReportStatsResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReportStatsResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalReports = null,
    Object? submittedReports = null,
    Object? inReviewReports = null,
    Object? approvedReports = null,
    Object? resolvedReports = null,
    Object? rejectedReports = null,
    Object? reportsByType = null,
    Object? reportsByPriority = null,
    Object? reportsByMonth = null,
  }) {
    return _then(_value.copyWith(
      totalReports: null == totalReports
          ? _value.totalReports
          : totalReports // ignore: cast_nullable_to_non_nullable
              as int,
      submittedReports: null == submittedReports
          ? _value.submittedReports
          : submittedReports // ignore: cast_nullable_to_non_nullable
              as int,
      inReviewReports: null == inReviewReports
          ? _value.inReviewReports
          : inReviewReports // ignore: cast_nullable_to_non_nullable
              as int,
      approvedReports: null == approvedReports
          ? _value.approvedReports
          : approvedReports // ignore: cast_nullable_to_non_nullable
              as int,
      resolvedReports: null == resolvedReports
          ? _value.resolvedReports
          : resolvedReports // ignore: cast_nullable_to_non_nullable
              as int,
      rejectedReports: null == rejectedReports
          ? _value.rejectedReports
          : rejectedReports // ignore: cast_nullable_to_non_nullable
              as int,
      reportsByType: null == reportsByType
          ? _value.reportsByType
          : reportsByType // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
      reportsByPriority: null == reportsByPriority
          ? _value.reportsByPriority
          : reportsByPriority // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
      reportsByMonth: null == reportsByMonth
          ? _value.reportsByMonth
          : reportsByMonth // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ReportStatsResponseImplCopyWith<$Res>
    implements $ReportStatsResponseCopyWith<$Res> {
  factory _$$ReportStatsResponseImplCopyWith(_$ReportStatsResponseImpl value,
          $Res Function(_$ReportStatsResponseImpl) then) =
      __$$ReportStatsResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int totalReports,
      int submittedReports,
      int inReviewReports,
      int approvedReports,
      int resolvedReports,
      int rejectedReports,
      Map<String, int> reportsByType,
      Map<String, int> reportsByPriority,
      Map<String, int> reportsByMonth});
}

/// @nodoc
class __$$ReportStatsResponseImplCopyWithImpl<$Res>
    extends _$ReportStatsResponseCopyWithImpl<$Res, _$ReportStatsResponseImpl>
    implements _$$ReportStatsResponseImplCopyWith<$Res> {
  __$$ReportStatsResponseImplCopyWithImpl(_$ReportStatsResponseImpl _value,
      $Res Function(_$ReportStatsResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of ReportStatsResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalReports = null,
    Object? submittedReports = null,
    Object? inReviewReports = null,
    Object? approvedReports = null,
    Object? resolvedReports = null,
    Object? rejectedReports = null,
    Object? reportsByType = null,
    Object? reportsByPriority = null,
    Object? reportsByMonth = null,
  }) {
    return _then(_$ReportStatsResponseImpl(
      totalReports: null == totalReports
          ? _value.totalReports
          : totalReports // ignore: cast_nullable_to_non_nullable
              as int,
      submittedReports: null == submittedReports
          ? _value.submittedReports
          : submittedReports // ignore: cast_nullable_to_non_nullable
              as int,
      inReviewReports: null == inReviewReports
          ? _value.inReviewReports
          : inReviewReports // ignore: cast_nullable_to_non_nullable
              as int,
      approvedReports: null == approvedReports
          ? _value.approvedReports
          : approvedReports // ignore: cast_nullable_to_non_nullable
              as int,
      resolvedReports: null == resolvedReports
          ? _value.resolvedReports
          : resolvedReports // ignore: cast_nullable_to_non_nullable
              as int,
      rejectedReports: null == rejectedReports
          ? _value.rejectedReports
          : rejectedReports // ignore: cast_nullable_to_non_nullable
              as int,
      reportsByType: null == reportsByType
          ? _value._reportsByType
          : reportsByType // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
      reportsByPriority: null == reportsByPriority
          ? _value._reportsByPriority
          : reportsByPriority // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
      reportsByMonth: null == reportsByMonth
          ? _value._reportsByMonth
          : reportsByMonth // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ReportStatsResponseImpl implements _ReportStatsResponse {
  const _$ReportStatsResponseImpl(
      {required this.totalReports,
      required this.submittedReports,
      required this.inReviewReports,
      required this.approvedReports,
      required this.resolvedReports,
      required this.rejectedReports,
      required final Map<String, int> reportsByType,
      required final Map<String, int> reportsByPriority,
      required final Map<String, int> reportsByMonth})
      : _reportsByType = reportsByType,
        _reportsByPriority = reportsByPriority,
        _reportsByMonth = reportsByMonth;

  factory _$ReportStatsResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReportStatsResponseImplFromJson(json);

  @override
  final int totalReports;
  @override
  final int submittedReports;
  @override
  final int inReviewReports;
  @override
  final int approvedReports;
  @override
  final int resolvedReports;
  @override
  final int rejectedReports;
  final Map<String, int> _reportsByType;
  @override
  Map<String, int> get reportsByType {
    if (_reportsByType is EqualUnmodifiableMapView) return _reportsByType;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_reportsByType);
  }

  final Map<String, int> _reportsByPriority;
  @override
  Map<String, int> get reportsByPriority {
    if (_reportsByPriority is EqualUnmodifiableMapView)
      return _reportsByPriority;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_reportsByPriority);
  }

  final Map<String, int> _reportsByMonth;
  @override
  Map<String, int> get reportsByMonth {
    if (_reportsByMonth is EqualUnmodifiableMapView) return _reportsByMonth;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_reportsByMonth);
  }

  @override
  String toString() {
    return 'ReportStatsResponse(totalReports: $totalReports, submittedReports: $submittedReports, inReviewReports: $inReviewReports, approvedReports: $approvedReports, resolvedReports: $resolvedReports, rejectedReports: $rejectedReports, reportsByType: $reportsByType, reportsByPriority: $reportsByPriority, reportsByMonth: $reportsByMonth)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReportStatsResponseImpl &&
            (identical(other.totalReports, totalReports) ||
                other.totalReports == totalReports) &&
            (identical(other.submittedReports, submittedReports) ||
                other.submittedReports == submittedReports) &&
            (identical(other.inReviewReports, inReviewReports) ||
                other.inReviewReports == inReviewReports) &&
            (identical(other.approvedReports, approvedReports) ||
                other.approvedReports == approvedReports) &&
            (identical(other.resolvedReports, resolvedReports) ||
                other.resolvedReports == resolvedReports) &&
            (identical(other.rejectedReports, rejectedReports) ||
                other.rejectedReports == rejectedReports) &&
            const DeepCollectionEquality()
                .equals(other._reportsByType, _reportsByType) &&
            const DeepCollectionEquality()
                .equals(other._reportsByPriority, _reportsByPriority) &&
            const DeepCollectionEquality()
                .equals(other._reportsByMonth, _reportsByMonth));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      totalReports,
      submittedReports,
      inReviewReports,
      approvedReports,
      resolvedReports,
      rejectedReports,
      const DeepCollectionEquality().hash(_reportsByType),
      const DeepCollectionEquality().hash(_reportsByPriority),
      const DeepCollectionEquality().hash(_reportsByMonth));

  /// Create a copy of ReportStatsResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReportStatsResponseImplCopyWith<_$ReportStatsResponseImpl> get copyWith =>
      __$$ReportStatsResponseImplCopyWithImpl<_$ReportStatsResponseImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReportStatsResponseImplToJson(
      this,
    );
  }
}

abstract class _ReportStatsResponse implements ReportStatsResponse {
  const factory _ReportStatsResponse(
          {required final int totalReports,
          required final int submittedReports,
          required final int inReviewReports,
          required final int approvedReports,
          required final int resolvedReports,
          required final int rejectedReports,
          required final Map<String, int> reportsByType,
          required final Map<String, int> reportsByPriority,
          required final Map<String, int> reportsByMonth}) =
      _$ReportStatsResponseImpl;

  factory _ReportStatsResponse.fromJson(Map<String, dynamic> json) =
      _$ReportStatsResponseImpl.fromJson;

  @override
  int get totalReports;
  @override
  int get submittedReports;
  @override
  int get inReviewReports;
  @override
  int get approvedReports;
  @override
  int get resolvedReports;
  @override
  int get rejectedReports;
  @override
  Map<String, int> get reportsByType;
  @override
  Map<String, int> get reportsByPriority;
  @override
  Map<String, int> get reportsByMonth;

  /// Create a copy of ReportStatsResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReportStatsResponseImplCopyWith<_$ReportStatsResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AddCommentRequest _$AddCommentRequestFromJson(Map<String, dynamic> json) {
  return _AddCommentRequest.fromJson(json);
}

/// @nodoc
mixin _$AddCommentRequest {
  String get content => throw _privateConstructorUsedError;

  /// Serializes this AddCommentRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AddCommentRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AddCommentRequestCopyWith<AddCommentRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AddCommentRequestCopyWith<$Res> {
  factory $AddCommentRequestCopyWith(
          AddCommentRequest value, $Res Function(AddCommentRequest) then) =
      _$AddCommentRequestCopyWithImpl<$Res, AddCommentRequest>;
  @useResult
  $Res call({String content});
}

/// @nodoc
class _$AddCommentRequestCopyWithImpl<$Res, $Val extends AddCommentRequest>
    implements $AddCommentRequestCopyWith<$Res> {
  _$AddCommentRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AddCommentRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? content = null,
  }) {
    return _then(_value.copyWith(
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AddCommentRequestImplCopyWith<$Res>
    implements $AddCommentRequestCopyWith<$Res> {
  factory _$$AddCommentRequestImplCopyWith(_$AddCommentRequestImpl value,
          $Res Function(_$AddCommentRequestImpl) then) =
      __$$AddCommentRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String content});
}

/// @nodoc
class __$$AddCommentRequestImplCopyWithImpl<$Res>
    extends _$AddCommentRequestCopyWithImpl<$Res, _$AddCommentRequestImpl>
    implements _$$AddCommentRequestImplCopyWith<$Res> {
  __$$AddCommentRequestImplCopyWithImpl(_$AddCommentRequestImpl _value,
      $Res Function(_$AddCommentRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of AddCommentRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? content = null,
  }) {
    return _then(_$AddCommentRequestImpl(
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AddCommentRequestImpl implements _AddCommentRequest {
  const _$AddCommentRequestImpl({required this.content});

  factory _$AddCommentRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$AddCommentRequestImplFromJson(json);

  @override
  final String content;

  @override
  String toString() {
    return 'AddCommentRequest(content: $content)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AddCommentRequestImpl &&
            (identical(other.content, content) || other.content == content));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, content);

  /// Create a copy of AddCommentRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AddCommentRequestImplCopyWith<_$AddCommentRequestImpl> get copyWith =>
      __$$AddCommentRequestImplCopyWithImpl<_$AddCommentRequestImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AddCommentRequestImplToJson(
      this,
    );
  }
}

abstract class _AddCommentRequest implements AddCommentRequest {
  const factory _AddCommentRequest({required final String content}) =
      _$AddCommentRequestImpl;

  factory _AddCommentRequest.fromJson(Map<String, dynamic> json) =
      _$AddCommentRequestImpl.fromJson;

  @override
  String get content;

  /// Create a copy of AddCommentRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AddCommentRequestImplCopyWith<_$AddCommentRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UpdateCommentRequest _$UpdateCommentRequestFromJson(Map<String, dynamic> json) {
  return _UpdateCommentRequest.fromJson(json);
}

/// @nodoc
mixin _$UpdateCommentRequest {
  String get content => throw _privateConstructorUsedError;

  /// Serializes this UpdateCommentRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UpdateCommentRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UpdateCommentRequestCopyWith<UpdateCommentRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UpdateCommentRequestCopyWith<$Res> {
  factory $UpdateCommentRequestCopyWith(UpdateCommentRequest value,
          $Res Function(UpdateCommentRequest) then) =
      _$UpdateCommentRequestCopyWithImpl<$Res, UpdateCommentRequest>;
  @useResult
  $Res call({String content});
}

/// @nodoc
class _$UpdateCommentRequestCopyWithImpl<$Res,
        $Val extends UpdateCommentRequest>
    implements $UpdateCommentRequestCopyWith<$Res> {
  _$UpdateCommentRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UpdateCommentRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? content = null,
  }) {
    return _then(_value.copyWith(
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UpdateCommentRequestImplCopyWith<$Res>
    implements $UpdateCommentRequestCopyWith<$Res> {
  factory _$$UpdateCommentRequestImplCopyWith(_$UpdateCommentRequestImpl value,
          $Res Function(_$UpdateCommentRequestImpl) then) =
      __$$UpdateCommentRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String content});
}

/// @nodoc
class __$$UpdateCommentRequestImplCopyWithImpl<$Res>
    extends _$UpdateCommentRequestCopyWithImpl<$Res, _$UpdateCommentRequestImpl>
    implements _$$UpdateCommentRequestImplCopyWith<$Res> {
  __$$UpdateCommentRequestImplCopyWithImpl(_$UpdateCommentRequestImpl _value,
      $Res Function(_$UpdateCommentRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of UpdateCommentRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? content = null,
  }) {
    return _then(_$UpdateCommentRequestImpl(
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UpdateCommentRequestImpl implements _UpdateCommentRequest {
  const _$UpdateCommentRequestImpl({required this.content});

  factory _$UpdateCommentRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$UpdateCommentRequestImplFromJson(json);

  @override
  final String content;

  @override
  String toString() {
    return 'UpdateCommentRequest(content: $content)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UpdateCommentRequestImpl &&
            (identical(other.content, content) || other.content == content));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, content);

  /// Create a copy of UpdateCommentRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UpdateCommentRequestImplCopyWith<_$UpdateCommentRequestImpl>
      get copyWith =>
          __$$UpdateCommentRequestImplCopyWithImpl<_$UpdateCommentRequestImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UpdateCommentRequestImplToJson(
      this,
    );
  }
}

abstract class _UpdateCommentRequest implements UpdateCommentRequest {
  const factory _UpdateCommentRequest({required final String content}) =
      _$UpdateCommentRequestImpl;

  factory _UpdateCommentRequest.fromJson(Map<String, dynamic> json) =
      _$UpdateCommentRequestImpl.fromJson;

  @override
  String get content;

  /// Create a copy of UpdateCommentRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UpdateCommentRequestImplCopyWith<_$UpdateCommentRequestImpl>
      get copyWith => throw _privateConstructorUsedError;
}
