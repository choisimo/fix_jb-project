// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'report_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ReportListState {
  ReportListStatus get status => throw _privateConstructorUsedError;
  List<Report> get reports => throw _privateConstructorUsedError;
  int get currentPage => throw _privateConstructorUsedError;
  int get totalPages => throw _privateConstructorUsedError;
  int get totalElements => throw _privateConstructorUsedError;
  bool get hasNext => throw _privateConstructorUsedError;
  bool get isLoadingMore => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;
  ReportListRequest? get lastRequest => throw _privateConstructorUsedError;

  /// Create a copy of ReportListState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReportListStateCopyWith<ReportListState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReportListStateCopyWith<$Res> {
  factory $ReportListStateCopyWith(
          ReportListState value, $Res Function(ReportListState) then) =
      _$ReportListStateCopyWithImpl<$Res, ReportListState>;
  @useResult
  $Res call(
      {ReportListStatus status,
      List<Report> reports,
      int currentPage,
      int totalPages,
      int totalElements,
      bool hasNext,
      bool isLoadingMore,
      String? error,
      ReportListRequest? lastRequest});

  $ReportListRequestCopyWith<$Res>? get lastRequest;
}

/// @nodoc
class _$ReportListStateCopyWithImpl<$Res, $Val extends ReportListState>
    implements $ReportListStateCopyWith<$Res> {
  _$ReportListStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReportListState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? reports = null,
    Object? currentPage = null,
    Object? totalPages = null,
    Object? totalElements = null,
    Object? hasNext = null,
    Object? isLoadingMore = null,
    Object? error = freezed,
    Object? lastRequest = freezed,
  }) {
    return _then(_value.copyWith(
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as ReportListStatus,
      reports: null == reports
          ? _value.reports
          : reports // ignore: cast_nullable_to_non_nullable
              as List<Report>,
      currentPage: null == currentPage
          ? _value.currentPage
          : currentPage // ignore: cast_nullable_to_non_nullable
              as int,
      totalPages: null == totalPages
          ? _value.totalPages
          : totalPages // ignore: cast_nullable_to_non_nullable
              as int,
      totalElements: null == totalElements
          ? _value.totalElements
          : totalElements // ignore: cast_nullable_to_non_nullable
              as int,
      hasNext: null == hasNext
          ? _value.hasNext
          : hasNext // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoadingMore: null == isLoadingMore
          ? _value.isLoadingMore
          : isLoadingMore // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      lastRequest: freezed == lastRequest
          ? _value.lastRequest
          : lastRequest // ignore: cast_nullable_to_non_nullable
              as ReportListRequest?,
    ) as $Val);
  }

  /// Create a copy of ReportListState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ReportListRequestCopyWith<$Res>? get lastRequest {
    if (_value.lastRequest == null) {
      return null;
    }

    return $ReportListRequestCopyWith<$Res>(_value.lastRequest!, (value) {
      return _then(_value.copyWith(lastRequest: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ReportListStateImplCopyWith<$Res>
    implements $ReportListStateCopyWith<$Res> {
  factory _$$ReportListStateImplCopyWith(_$ReportListStateImpl value,
          $Res Function(_$ReportListStateImpl) then) =
      __$$ReportListStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {ReportListStatus status,
      List<Report> reports,
      int currentPage,
      int totalPages,
      int totalElements,
      bool hasNext,
      bool isLoadingMore,
      String? error,
      ReportListRequest? lastRequest});

  @override
  $ReportListRequestCopyWith<$Res>? get lastRequest;
}

/// @nodoc
class __$$ReportListStateImplCopyWithImpl<$Res>
    extends _$ReportListStateCopyWithImpl<$Res, _$ReportListStateImpl>
    implements _$$ReportListStateImplCopyWith<$Res> {
  __$$ReportListStateImplCopyWithImpl(
      _$ReportListStateImpl _value, $Res Function(_$ReportListStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of ReportListState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? reports = null,
    Object? currentPage = null,
    Object? totalPages = null,
    Object? totalElements = null,
    Object? hasNext = null,
    Object? isLoadingMore = null,
    Object? error = freezed,
    Object? lastRequest = freezed,
  }) {
    return _then(_$ReportListStateImpl(
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as ReportListStatus,
      reports: null == reports
          ? _value._reports
          : reports // ignore: cast_nullable_to_non_nullable
              as List<Report>,
      currentPage: null == currentPage
          ? _value.currentPage
          : currentPage // ignore: cast_nullable_to_non_nullable
              as int,
      totalPages: null == totalPages
          ? _value.totalPages
          : totalPages // ignore: cast_nullable_to_non_nullable
              as int,
      totalElements: null == totalElements
          ? _value.totalElements
          : totalElements // ignore: cast_nullable_to_non_nullable
              as int,
      hasNext: null == hasNext
          ? _value.hasNext
          : hasNext // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoadingMore: null == isLoadingMore
          ? _value.isLoadingMore
          : isLoadingMore // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      lastRequest: freezed == lastRequest
          ? _value.lastRequest
          : lastRequest // ignore: cast_nullable_to_non_nullable
              as ReportListRequest?,
    ));
  }
}

/// @nodoc

class _$ReportListStateImpl extends _ReportListState {
  const _$ReportListStateImpl(
      {this.status = ReportListStatus.initial,
      final List<Report> reports = const [],
      this.currentPage = 0,
      this.totalPages = 0,
      this.totalElements = 0,
      this.hasNext = false,
      this.isLoadingMore = false,
      this.error,
      this.lastRequest})
      : _reports = reports,
        super._();

  @override
  @JsonKey()
  final ReportListStatus status;
  final List<Report> _reports;
  @override
  @JsonKey()
  List<Report> get reports {
    if (_reports is EqualUnmodifiableListView) return _reports;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_reports);
  }

  @override
  @JsonKey()
  final int currentPage;
  @override
  @JsonKey()
  final int totalPages;
  @override
  @JsonKey()
  final int totalElements;
  @override
  @JsonKey()
  final bool hasNext;
  @override
  @JsonKey()
  final bool isLoadingMore;
  @override
  final String? error;
  @override
  final ReportListRequest? lastRequest;

  @override
  String toString() {
    return 'ReportListState(status: $status, reports: $reports, currentPage: $currentPage, totalPages: $totalPages, totalElements: $totalElements, hasNext: $hasNext, isLoadingMore: $isLoadingMore, error: $error, lastRequest: $lastRequest)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReportListStateImpl &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality().equals(other._reports, _reports) &&
            (identical(other.currentPage, currentPage) ||
                other.currentPage == currentPage) &&
            (identical(other.totalPages, totalPages) ||
                other.totalPages == totalPages) &&
            (identical(other.totalElements, totalElements) ||
                other.totalElements == totalElements) &&
            (identical(other.hasNext, hasNext) || other.hasNext == hasNext) &&
            (identical(other.isLoadingMore, isLoadingMore) ||
                other.isLoadingMore == isLoadingMore) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.lastRequest, lastRequest) ||
                other.lastRequest == lastRequest));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      status,
      const DeepCollectionEquality().hash(_reports),
      currentPage,
      totalPages,
      totalElements,
      hasNext,
      isLoadingMore,
      error,
      lastRequest);

  /// Create a copy of ReportListState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReportListStateImplCopyWith<_$ReportListStateImpl> get copyWith =>
      __$$ReportListStateImplCopyWithImpl<_$ReportListStateImpl>(
          this, _$identity);
}

abstract class _ReportListState extends ReportListState {
  const factory _ReportListState(
      {final ReportListStatus status,
      final List<Report> reports,
      final int currentPage,
      final int totalPages,
      final int totalElements,
      final bool hasNext,
      final bool isLoadingMore,
      final String? error,
      final ReportListRequest? lastRequest}) = _$ReportListStateImpl;
  const _ReportListState._() : super._();

  @override
  ReportListStatus get status;
  @override
  List<Report> get reports;
  @override
  int get currentPage;
  @override
  int get totalPages;
  @override
  int get totalElements;
  @override
  bool get hasNext;
  @override
  bool get isLoadingMore;
  @override
  String? get error;
  @override
  ReportListRequest? get lastRequest;

  /// Create a copy of ReportListState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReportListStateImplCopyWith<_$ReportListStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$CreateReportState {
  String? get title => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  ReportType? get type => throw _privateConstructorUsedError;
  ReportLocation? get location => throw _privateConstructorUsedError;
  List<XFile> get selectedImages => throw _privateConstructorUsedError;
  List<ImageUploadResponse> get uploadedImages =>
      throw _privateConstructorUsedError;
  Priority get priority => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  bool get isSubmitting => throw _privateConstructorUsedError;
  bool get isUploadingImages => throw _privateConstructorUsedError;
  bool get isAnalyzing => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;
  AIAnalysisResult? get aiAnalysis => throw _privateConstructorUsedError;
  Map<String, String>? get fieldErrors => throw _privateConstructorUsedError;

  /// Create a copy of CreateReportState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreateReportStateCopyWith<CreateReportState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateReportStateCopyWith<$Res> {
  factory $CreateReportStateCopyWith(
          CreateReportState value, $Res Function(CreateReportState) then) =
      _$CreateReportStateCopyWithImpl<$Res, CreateReportState>;
  @useResult
  $Res call(
      {String? title,
      String? description,
      ReportType? type,
      ReportLocation? location,
      List<XFile> selectedImages,
      List<ImageUploadResponse> uploadedImages,
      Priority priority,
      bool isLoading,
      bool isSubmitting,
      bool isUploadingImages,
      bool isAnalyzing,
      String? error,
      AIAnalysisResult? aiAnalysis,
      Map<String, String>? fieldErrors});

  $ReportLocationCopyWith<$Res>? get location;
  $AIAnalysisResultCopyWith<$Res>? get aiAnalysis;
}

/// @nodoc
class _$CreateReportStateCopyWithImpl<$Res, $Val extends CreateReportState>
    implements $CreateReportStateCopyWith<$Res> {
  _$CreateReportStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreateReportState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = freezed,
    Object? description = freezed,
    Object? type = freezed,
    Object? location = freezed,
    Object? selectedImages = null,
    Object? uploadedImages = null,
    Object? priority = null,
    Object? isLoading = null,
    Object? isSubmitting = null,
    Object? isUploadingImages = null,
    Object? isAnalyzing = null,
    Object? error = freezed,
    Object? aiAnalysis = freezed,
    Object? fieldErrors = freezed,
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
      selectedImages: null == selectedImages
          ? _value.selectedImages
          : selectedImages // ignore: cast_nullable_to_non_nullable
              as List<XFile>,
      uploadedImages: null == uploadedImages
          ? _value.uploadedImages
          : uploadedImages // ignore: cast_nullable_to_non_nullable
              as List<ImageUploadResponse>,
      priority: null == priority
          ? _value.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as Priority,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isSubmitting: null == isSubmitting
          ? _value.isSubmitting
          : isSubmitting // ignore: cast_nullable_to_non_nullable
              as bool,
      isUploadingImages: null == isUploadingImages
          ? _value.isUploadingImages
          : isUploadingImages // ignore: cast_nullable_to_non_nullable
              as bool,
      isAnalyzing: null == isAnalyzing
          ? _value.isAnalyzing
          : isAnalyzing // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      aiAnalysis: freezed == aiAnalysis
          ? _value.aiAnalysis
          : aiAnalysis // ignore: cast_nullable_to_non_nullable
              as AIAnalysisResult?,
      fieldErrors: freezed == fieldErrors
          ? _value.fieldErrors
          : fieldErrors // ignore: cast_nullable_to_non_nullable
              as Map<String, String>?,
    ) as $Val);
  }

  /// Create a copy of CreateReportState
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

  /// Create a copy of CreateReportState
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
abstract class _$$CreateReportStateImplCopyWith<$Res>
    implements $CreateReportStateCopyWith<$Res> {
  factory _$$CreateReportStateImplCopyWith(_$CreateReportStateImpl value,
          $Res Function(_$CreateReportStateImpl) then) =
      __$$CreateReportStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? title,
      String? description,
      ReportType? type,
      ReportLocation? location,
      List<XFile> selectedImages,
      List<ImageUploadResponse> uploadedImages,
      Priority priority,
      bool isLoading,
      bool isSubmitting,
      bool isUploadingImages,
      bool isAnalyzing,
      String? error,
      AIAnalysisResult? aiAnalysis,
      Map<String, String>? fieldErrors});

  @override
  $ReportLocationCopyWith<$Res>? get location;
  @override
  $AIAnalysisResultCopyWith<$Res>? get aiAnalysis;
}

/// @nodoc
class __$$CreateReportStateImplCopyWithImpl<$Res>
    extends _$CreateReportStateCopyWithImpl<$Res, _$CreateReportStateImpl>
    implements _$$CreateReportStateImplCopyWith<$Res> {
  __$$CreateReportStateImplCopyWithImpl(_$CreateReportStateImpl _value,
      $Res Function(_$CreateReportStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of CreateReportState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = freezed,
    Object? description = freezed,
    Object? type = freezed,
    Object? location = freezed,
    Object? selectedImages = null,
    Object? uploadedImages = null,
    Object? priority = null,
    Object? isLoading = null,
    Object? isSubmitting = null,
    Object? isUploadingImages = null,
    Object? isAnalyzing = null,
    Object? error = freezed,
    Object? aiAnalysis = freezed,
    Object? fieldErrors = freezed,
  }) {
    return _then(_$CreateReportStateImpl(
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
      selectedImages: null == selectedImages
          ? _value._selectedImages
          : selectedImages // ignore: cast_nullable_to_non_nullable
              as List<XFile>,
      uploadedImages: null == uploadedImages
          ? _value._uploadedImages
          : uploadedImages // ignore: cast_nullable_to_non_nullable
              as List<ImageUploadResponse>,
      priority: null == priority
          ? _value.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as Priority,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isSubmitting: null == isSubmitting
          ? _value.isSubmitting
          : isSubmitting // ignore: cast_nullable_to_non_nullable
              as bool,
      isUploadingImages: null == isUploadingImages
          ? _value.isUploadingImages
          : isUploadingImages // ignore: cast_nullable_to_non_nullable
              as bool,
      isAnalyzing: null == isAnalyzing
          ? _value.isAnalyzing
          : isAnalyzing // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      aiAnalysis: freezed == aiAnalysis
          ? _value.aiAnalysis
          : aiAnalysis // ignore: cast_nullable_to_non_nullable
              as AIAnalysisResult?,
      fieldErrors: freezed == fieldErrors
          ? _value._fieldErrors
          : fieldErrors // ignore: cast_nullable_to_non_nullable
              as Map<String, String>?,
    ));
  }
}

/// @nodoc

class _$CreateReportStateImpl extends _CreateReportState {
  const _$CreateReportStateImpl(
      {this.title,
      this.description,
      this.type,
      this.location,
      final List<XFile> selectedImages = const [],
      final List<ImageUploadResponse> uploadedImages = const [],
      this.priority = Priority.medium,
      this.isLoading = false,
      this.isSubmitting = false,
      this.isUploadingImages = false,
      this.isAnalyzing = false,
      this.error,
      this.aiAnalysis,
      final Map<String, String>? fieldErrors})
      : _selectedImages = selectedImages,
        _uploadedImages = uploadedImages,
        _fieldErrors = fieldErrors,
        super._();

  @override
  final String? title;
  @override
  final String? description;
  @override
  final ReportType? type;
  @override
  final ReportLocation? location;
  final List<XFile> _selectedImages;
  @override
  @JsonKey()
  List<XFile> get selectedImages {
    if (_selectedImages is EqualUnmodifiableListView) return _selectedImages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_selectedImages);
  }

  final List<ImageUploadResponse> _uploadedImages;
  @override
  @JsonKey()
  List<ImageUploadResponse> get uploadedImages {
    if (_uploadedImages is EqualUnmodifiableListView) return _uploadedImages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_uploadedImages);
  }

  @override
  @JsonKey()
  final Priority priority;
  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final bool isSubmitting;
  @override
  @JsonKey()
  final bool isUploadingImages;
  @override
  @JsonKey()
  final bool isAnalyzing;
  @override
  final String? error;
  @override
  final AIAnalysisResult? aiAnalysis;
  final Map<String, String>? _fieldErrors;
  @override
  Map<String, String>? get fieldErrors {
    final value = _fieldErrors;
    if (value == null) return null;
    if (_fieldErrors is EqualUnmodifiableMapView) return _fieldErrors;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'CreateReportState(title: $title, description: $description, type: $type, location: $location, selectedImages: $selectedImages, uploadedImages: $uploadedImages, priority: $priority, isLoading: $isLoading, isSubmitting: $isSubmitting, isUploadingImages: $isUploadingImages, isAnalyzing: $isAnalyzing, error: $error, aiAnalysis: $aiAnalysis, fieldErrors: $fieldErrors)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateReportStateImpl &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.location, location) ||
                other.location == location) &&
            const DeepCollectionEquality()
                .equals(other._selectedImages, _selectedImages) &&
            const DeepCollectionEquality()
                .equals(other._uploadedImages, _uploadedImages) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.isSubmitting, isSubmitting) ||
                other.isSubmitting == isSubmitting) &&
            (identical(other.isUploadingImages, isUploadingImages) ||
                other.isUploadingImages == isUploadingImages) &&
            (identical(other.isAnalyzing, isAnalyzing) ||
                other.isAnalyzing == isAnalyzing) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.aiAnalysis, aiAnalysis) ||
                other.aiAnalysis == aiAnalysis) &&
            const DeepCollectionEquality()
                .equals(other._fieldErrors, _fieldErrors));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      title,
      description,
      type,
      location,
      const DeepCollectionEquality().hash(_selectedImages),
      const DeepCollectionEquality().hash(_uploadedImages),
      priority,
      isLoading,
      isSubmitting,
      isUploadingImages,
      isAnalyzing,
      error,
      aiAnalysis,
      const DeepCollectionEquality().hash(_fieldErrors));

  /// Create a copy of CreateReportState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateReportStateImplCopyWith<_$CreateReportStateImpl> get copyWith =>
      __$$CreateReportStateImplCopyWithImpl<_$CreateReportStateImpl>(
          this, _$identity);
}

abstract class _CreateReportState extends CreateReportState {
  const factory _CreateReportState(
      {final String? title,
      final String? description,
      final ReportType? type,
      final ReportLocation? location,
      final List<XFile> selectedImages,
      final List<ImageUploadResponse> uploadedImages,
      final Priority priority,
      final bool isLoading,
      final bool isSubmitting,
      final bool isUploadingImages,
      final bool isAnalyzing,
      final String? error,
      final AIAnalysisResult? aiAnalysis,
      final Map<String, String>? fieldErrors}) = _$CreateReportStateImpl;
  const _CreateReportState._() : super._();

  @override
  String? get title;
  @override
  String? get description;
  @override
  ReportType? get type;
  @override
  ReportLocation? get location;
  @override
  List<XFile> get selectedImages;
  @override
  List<ImageUploadResponse> get uploadedImages;
  @override
  Priority get priority;
  @override
  bool get isLoading;
  @override
  bool get isSubmitting;
  @override
  bool get isUploadingImages;
  @override
  bool get isAnalyzing;
  @override
  String? get error;
  @override
  AIAnalysisResult? get aiAnalysis;
  @override
  Map<String, String>? get fieldErrors;

  /// Create a copy of CreateReportState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreateReportStateImplCopyWith<_$CreateReportStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ReportDetailState {
  Report? get report => throw _privateConstructorUsedError;
  List<ReportComment> get comments => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  bool get isLoadingComments => throw _privateConstructorUsedError;
  bool get isSubmittingComment => throw _privateConstructorUsedError;
  bool get isLiking => throw _privateConstructorUsedError;
  bool get isBookmarking => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;
  String? get commentError => throw _privateConstructorUsedError;

  /// Create a copy of ReportDetailState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReportDetailStateCopyWith<ReportDetailState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReportDetailStateCopyWith<$Res> {
  factory $ReportDetailStateCopyWith(
          ReportDetailState value, $Res Function(ReportDetailState) then) =
      _$ReportDetailStateCopyWithImpl<$Res, ReportDetailState>;
  @useResult
  $Res call(
      {Report? report,
      List<ReportComment> comments,
      bool isLoading,
      bool isLoadingComments,
      bool isSubmittingComment,
      bool isLiking,
      bool isBookmarking,
      String? error,
      String? commentError});

  $ReportCopyWith<$Res>? get report;
}

/// @nodoc
class _$ReportDetailStateCopyWithImpl<$Res, $Val extends ReportDetailState>
    implements $ReportDetailStateCopyWith<$Res> {
  _$ReportDetailStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReportDetailState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? report = freezed,
    Object? comments = null,
    Object? isLoading = null,
    Object? isLoadingComments = null,
    Object? isSubmittingComment = null,
    Object? isLiking = null,
    Object? isBookmarking = null,
    Object? error = freezed,
    Object? commentError = freezed,
  }) {
    return _then(_value.copyWith(
      report: freezed == report
          ? _value.report
          : report // ignore: cast_nullable_to_non_nullable
              as Report?,
      comments: null == comments
          ? _value.comments
          : comments // ignore: cast_nullable_to_non_nullable
              as List<ReportComment>,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoadingComments: null == isLoadingComments
          ? _value.isLoadingComments
          : isLoadingComments // ignore: cast_nullable_to_non_nullable
              as bool,
      isSubmittingComment: null == isSubmittingComment
          ? _value.isSubmittingComment
          : isSubmittingComment // ignore: cast_nullable_to_non_nullable
              as bool,
      isLiking: null == isLiking
          ? _value.isLiking
          : isLiking // ignore: cast_nullable_to_non_nullable
              as bool,
      isBookmarking: null == isBookmarking
          ? _value.isBookmarking
          : isBookmarking // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      commentError: freezed == commentError
          ? _value.commentError
          : commentError // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  /// Create a copy of ReportDetailState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ReportCopyWith<$Res>? get report {
    if (_value.report == null) {
      return null;
    }

    return $ReportCopyWith<$Res>(_value.report!, (value) {
      return _then(_value.copyWith(report: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ReportDetailStateImplCopyWith<$Res>
    implements $ReportDetailStateCopyWith<$Res> {
  factory _$$ReportDetailStateImplCopyWith(_$ReportDetailStateImpl value,
          $Res Function(_$ReportDetailStateImpl) then) =
      __$$ReportDetailStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {Report? report,
      List<ReportComment> comments,
      bool isLoading,
      bool isLoadingComments,
      bool isSubmittingComment,
      bool isLiking,
      bool isBookmarking,
      String? error,
      String? commentError});

  @override
  $ReportCopyWith<$Res>? get report;
}

/// @nodoc
class __$$ReportDetailStateImplCopyWithImpl<$Res>
    extends _$ReportDetailStateCopyWithImpl<$Res, _$ReportDetailStateImpl>
    implements _$$ReportDetailStateImplCopyWith<$Res> {
  __$$ReportDetailStateImplCopyWithImpl(_$ReportDetailStateImpl _value,
      $Res Function(_$ReportDetailStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of ReportDetailState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? report = freezed,
    Object? comments = null,
    Object? isLoading = null,
    Object? isLoadingComments = null,
    Object? isSubmittingComment = null,
    Object? isLiking = null,
    Object? isBookmarking = null,
    Object? error = freezed,
    Object? commentError = freezed,
  }) {
    return _then(_$ReportDetailStateImpl(
      report: freezed == report
          ? _value.report
          : report // ignore: cast_nullable_to_non_nullable
              as Report?,
      comments: null == comments
          ? _value._comments
          : comments // ignore: cast_nullable_to_non_nullable
              as List<ReportComment>,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoadingComments: null == isLoadingComments
          ? _value.isLoadingComments
          : isLoadingComments // ignore: cast_nullable_to_non_nullable
              as bool,
      isSubmittingComment: null == isSubmittingComment
          ? _value.isSubmittingComment
          : isSubmittingComment // ignore: cast_nullable_to_non_nullable
              as bool,
      isLiking: null == isLiking
          ? _value.isLiking
          : isLiking // ignore: cast_nullable_to_non_nullable
              as bool,
      isBookmarking: null == isBookmarking
          ? _value.isBookmarking
          : isBookmarking // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      commentError: freezed == commentError
          ? _value.commentError
          : commentError // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$ReportDetailStateImpl implements _ReportDetailState {
  const _$ReportDetailStateImpl(
      {this.report,
      final List<ReportComment> comments = const [],
      this.isLoading = false,
      this.isLoadingComments = false,
      this.isSubmittingComment = false,
      this.isLiking = false,
      this.isBookmarking = false,
      this.error,
      this.commentError})
      : _comments = comments;

  @override
  final Report? report;
  final List<ReportComment> _comments;
  @override
  @JsonKey()
  List<ReportComment> get comments {
    if (_comments is EqualUnmodifiableListView) return _comments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_comments);
  }

  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final bool isLoadingComments;
  @override
  @JsonKey()
  final bool isSubmittingComment;
  @override
  @JsonKey()
  final bool isLiking;
  @override
  @JsonKey()
  final bool isBookmarking;
  @override
  final String? error;
  @override
  final String? commentError;

  @override
  String toString() {
    return 'ReportDetailState(report: $report, comments: $comments, isLoading: $isLoading, isLoadingComments: $isLoadingComments, isSubmittingComment: $isSubmittingComment, isLiking: $isLiking, isBookmarking: $isBookmarking, error: $error, commentError: $commentError)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReportDetailStateImpl &&
            (identical(other.report, report) || other.report == report) &&
            const DeepCollectionEquality().equals(other._comments, _comments) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.isLoadingComments, isLoadingComments) ||
                other.isLoadingComments == isLoadingComments) &&
            (identical(other.isSubmittingComment, isSubmittingComment) ||
                other.isSubmittingComment == isSubmittingComment) &&
            (identical(other.isLiking, isLiking) ||
                other.isLiking == isLiking) &&
            (identical(other.isBookmarking, isBookmarking) ||
                other.isBookmarking == isBookmarking) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.commentError, commentError) ||
                other.commentError == commentError));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      report,
      const DeepCollectionEquality().hash(_comments),
      isLoading,
      isLoadingComments,
      isSubmittingComment,
      isLiking,
      isBookmarking,
      error,
      commentError);

  /// Create a copy of ReportDetailState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReportDetailStateImplCopyWith<_$ReportDetailStateImpl> get copyWith =>
      __$$ReportDetailStateImplCopyWithImpl<_$ReportDetailStateImpl>(
          this, _$identity);
}

abstract class _ReportDetailState implements ReportDetailState {
  const factory _ReportDetailState(
      {final Report? report,
      final List<ReportComment> comments,
      final bool isLoading,
      final bool isLoadingComments,
      final bool isSubmittingComment,
      final bool isLiking,
      final bool isBookmarking,
      final String? error,
      final String? commentError}) = _$ReportDetailStateImpl;

  @override
  Report? get report;
  @override
  List<ReportComment> get comments;
  @override
  bool get isLoading;
  @override
  bool get isLoadingComments;
  @override
  bool get isSubmittingComment;
  @override
  bool get isLiking;
  @override
  bool get isBookmarking;
  @override
  String? get error;
  @override
  String? get commentError;

  /// Create a copy of ReportDetailState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReportDetailStateImplCopyWith<_$ReportDetailStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ReportFilterState {
  String? get search => throw _privateConstructorUsedError;
  ReportType? get type => throw _privateConstructorUsedError;
  ReportStatus? get status => throw _privateConstructorUsedError;
  Priority? get priority => throw _privateConstructorUsedError;
  String? get sortBy => throw _privateConstructorUsedError;
  String get sortDirection => throw _privateConstructorUsedError;
  ReportLocation? get location => throw _privateConstructorUsedError;
  double get radius => throw _privateConstructorUsedError;
  bool get nearbyOnly => throw _privateConstructorUsedError;

  /// Create a copy of ReportFilterState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReportFilterStateCopyWith<ReportFilterState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReportFilterStateCopyWith<$Res> {
  factory $ReportFilterStateCopyWith(
          ReportFilterState value, $Res Function(ReportFilterState) then) =
      _$ReportFilterStateCopyWithImpl<$Res, ReportFilterState>;
  @useResult
  $Res call(
      {String? search,
      ReportType? type,
      ReportStatus? status,
      Priority? priority,
      String? sortBy,
      String sortDirection,
      ReportLocation? location,
      double radius,
      bool nearbyOnly});

  $ReportLocationCopyWith<$Res>? get location;
}

/// @nodoc
class _$ReportFilterStateCopyWithImpl<$Res, $Val extends ReportFilterState>
    implements $ReportFilterStateCopyWith<$Res> {
  _$ReportFilterStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReportFilterState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? search = freezed,
    Object? type = freezed,
    Object? status = freezed,
    Object? priority = freezed,
    Object? sortBy = freezed,
    Object? sortDirection = null,
    Object? location = freezed,
    Object? radius = null,
    Object? nearbyOnly = null,
  }) {
    return _then(_value.copyWith(
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
      sortBy: freezed == sortBy
          ? _value.sortBy
          : sortBy // ignore: cast_nullable_to_non_nullable
              as String?,
      sortDirection: null == sortDirection
          ? _value.sortDirection
          : sortDirection // ignore: cast_nullable_to_non_nullable
              as String,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as ReportLocation?,
      radius: null == radius
          ? _value.radius
          : radius // ignore: cast_nullable_to_non_nullable
              as double,
      nearbyOnly: null == nearbyOnly
          ? _value.nearbyOnly
          : nearbyOnly // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }

  /// Create a copy of ReportFilterState
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
abstract class _$$ReportFilterStateImplCopyWith<$Res>
    implements $ReportFilterStateCopyWith<$Res> {
  factory _$$ReportFilterStateImplCopyWith(_$ReportFilterStateImpl value,
          $Res Function(_$ReportFilterStateImpl) then) =
      __$$ReportFilterStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? search,
      ReportType? type,
      ReportStatus? status,
      Priority? priority,
      String? sortBy,
      String sortDirection,
      ReportLocation? location,
      double radius,
      bool nearbyOnly});

  @override
  $ReportLocationCopyWith<$Res>? get location;
}

/// @nodoc
class __$$ReportFilterStateImplCopyWithImpl<$Res>
    extends _$ReportFilterStateCopyWithImpl<$Res, _$ReportFilterStateImpl>
    implements _$$ReportFilterStateImplCopyWith<$Res> {
  __$$ReportFilterStateImplCopyWithImpl(_$ReportFilterStateImpl _value,
      $Res Function(_$ReportFilterStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of ReportFilterState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? search = freezed,
    Object? type = freezed,
    Object? status = freezed,
    Object? priority = freezed,
    Object? sortBy = freezed,
    Object? sortDirection = null,
    Object? location = freezed,
    Object? radius = null,
    Object? nearbyOnly = null,
  }) {
    return _then(_$ReportFilterStateImpl(
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
      sortBy: freezed == sortBy
          ? _value.sortBy
          : sortBy // ignore: cast_nullable_to_non_nullable
              as String?,
      sortDirection: null == sortDirection
          ? _value.sortDirection
          : sortDirection // ignore: cast_nullable_to_non_nullable
              as String,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as ReportLocation?,
      radius: null == radius
          ? _value.radius
          : radius // ignore: cast_nullable_to_non_nullable
              as double,
      nearbyOnly: null == nearbyOnly
          ? _value.nearbyOnly
          : nearbyOnly // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$ReportFilterStateImpl extends _ReportFilterState {
  const _$ReportFilterStateImpl(
      {this.search,
      this.type,
      this.status,
      this.priority,
      this.sortBy,
      this.sortDirection = 'desc',
      this.location,
      this.radius = 1.0,
      this.nearbyOnly = false})
      : super._();

  @override
  final String? search;
  @override
  final ReportType? type;
  @override
  final ReportStatus? status;
  @override
  final Priority? priority;
  @override
  final String? sortBy;
  @override
  @JsonKey()
  final String sortDirection;
  @override
  final ReportLocation? location;
  @override
  @JsonKey()
  final double radius;
  @override
  @JsonKey()
  final bool nearbyOnly;

  @override
  String toString() {
    return 'ReportFilterState(search: $search, type: $type, status: $status, priority: $priority, sortBy: $sortBy, sortDirection: $sortDirection, location: $location, radius: $radius, nearbyOnly: $nearbyOnly)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReportFilterStateImpl &&
            (identical(other.search, search) || other.search == search) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            (identical(other.sortBy, sortBy) || other.sortBy == sortBy) &&
            (identical(other.sortDirection, sortDirection) ||
                other.sortDirection == sortDirection) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.radius, radius) || other.radius == radius) &&
            (identical(other.nearbyOnly, nearbyOnly) ||
                other.nearbyOnly == nearbyOnly));
  }

  @override
  int get hashCode => Object.hash(runtimeType, search, type, status, priority,
      sortBy, sortDirection, location, radius, nearbyOnly);

  /// Create a copy of ReportFilterState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReportFilterStateImplCopyWith<_$ReportFilterStateImpl> get copyWith =>
      __$$ReportFilterStateImplCopyWithImpl<_$ReportFilterStateImpl>(
          this, _$identity);
}

abstract class _ReportFilterState extends ReportFilterState {
  const factory _ReportFilterState(
      {final String? search,
      final ReportType? type,
      final ReportStatus? status,
      final Priority? priority,
      final String? sortBy,
      final String sortDirection,
      final ReportLocation? location,
      final double radius,
      final bool nearbyOnly}) = _$ReportFilterStateImpl;
  const _ReportFilterState._() : super._();

  @override
  String? get search;
  @override
  ReportType? get type;
  @override
  ReportStatus? get status;
  @override
  Priority? get priority;
  @override
  String? get sortBy;
  @override
  String get sortDirection;
  @override
  ReportLocation? get location;
  @override
  double get radius;
  @override
  bool get nearbyOnly;

  /// Create a copy of ReportFilterState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReportFilterStateImplCopyWith<_$ReportFilterStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
