import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:image_picker/image_picker.dart';
import 'report.dart';
import 'report_models.dart';

part 'report_state.freezed.dart';

enum ReportListStatus {
  initial,
  loading,
  loaded,
  error,
}

@freezed
class ReportListState with _$ReportListState {
  const factory ReportListState({
    @Default(ReportListStatus.initial) ReportListStatus status,
    @Default([]) List<Report> reports,
    @Default(0) int currentPage,
    @Default(0) int totalPages,
    @Default(0) int totalElements,
    @Default(false) bool hasNext,
    @Default(false) bool isLoadingMore,
    String? error,
    ReportListRequest? lastRequest,
  }) = _ReportListState;

  const ReportListState._();

  bool get isEmpty => reports.isEmpty;
  bool get isNotEmpty => reports.isNotEmpty;
  bool get canLoadMore => hasNext && !isLoadingMore;
}

@freezed
class CreateReportState with _$CreateReportState {
  const factory CreateReportState({
    String? title,
    String? description,
    ReportType? type,
    ReportLocation? location,
    @Default([]) List<XFile> selectedImages,
    @Default([]) List<ImageUploadResponse> uploadedImages,
    @Default(Priority.medium) Priority priority,
    @Default(false) bool isLoading,
    @Default(false) bool isSubmitting,
    @Default(false) bool isUploadingImages,
    @Default(false) bool isAnalyzing,
    String? error,
    AIAnalysisResult? aiAnalysis,
    Map<String, String>? fieldErrors,
  }) = _CreateReportState;

  const CreateReportState._();

  bool get isFormValid =>
      title != null &&
      title!.isNotEmpty &&
      description != null &&
      description!.isNotEmpty &&
      type != null &&
      location != null &&
      selectedImages.isNotEmpty;

  bool get hasImages => selectedImages.isNotEmpty || uploadedImages.isNotEmpty;
  int get totalImages => selectedImages.length + uploadedImages.length;
}

@freezed
class ReportDetailState with _$ReportDetailState {
  const factory ReportDetailState({
    Report? report,
    @Default([]) List<ReportComment> comments,
    @Default(false) bool isLoading,
    @Default(false) bool isLoadingComments,
    @Default(false) bool isSubmittingComment,
    @Default(false) bool isLiking,
    @Default(false) bool isBookmarking,
    String? error,
    String? commentError,
  }) = _ReportDetailState;
}

@freezed
class ReportFilterState with _$ReportFilterState {
  const factory ReportFilterState({
    String? search,
    ReportType? type,
    ReportStatus? status,
    Priority? priority,
    String? sortBy,
    @Default('desc') String sortDirection,
    ReportLocation? location,
    @Default(1.0) double radius,
    @Default(false) bool nearbyOnly,
  }) = _ReportFilterState;

  const ReportFilterState._();

  bool get hasActiveFilters =>
      search != null ||
      type != null ||
      status != null ||
      priority != null ||
      nearbyOnly;

  ReportListRequest toRequest({int page = 0, int size = 20}) {
    return ReportListRequest(
      page: page,
      size: size,
      search: search,
      type: type,
      status: status,
      priority: priority,
      sortBy: sortBy,
      sortDirection: sortDirection,
      latitude: nearbyOnly ? location?.latitude : null,
      longitude: nearbyOnly ? location?.longitude : null,
      radius: nearbyOnly ? radius : null,
    );
  }
}