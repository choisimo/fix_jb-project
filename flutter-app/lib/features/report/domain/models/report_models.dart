import 'package:freezed_annotation/freezed_annotation.dart';
import 'report.dart';

part 'report_models.freezed.dart';
part 'report_models.g.dart';

@freezed
class CreateReportRequest with _$CreateReportRequest {
  const factory CreateReportRequest({
    required String title,
    required String description,
    required ReportType type,
    required ReportLocation location,
    @Default([]) List<String> imageIds,
    @Default(Priority.medium) Priority priority,
    Map<String, dynamic>? metadata,
  }) = _CreateReportRequest;

  factory CreateReportRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateReportRequestFromJson(json);
}

@freezed
class UpdateReportRequest with _$UpdateReportRequest {
  const factory UpdateReportRequest({
    String? title,
    String? description,
    ReportType? type,
    ReportLocation? location,
    List<String>? imageIds,
    Priority? priority,
    Map<String, dynamic>? metadata,
  }) = _UpdateReportRequest;

  factory UpdateReportRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateReportRequestFromJson(json);
}

@freezed
class ReportListRequest with _$ReportListRequest {
  const factory ReportListRequest({
    @Default(0) int page,
    @Default(20) int size,
    String? search,
    ReportType? type,
    ReportStatus? status,
    Priority? priority,
    int? userId,
    String? sortBy,
    @Default('desc') String sortDirection,
    double? latitude,
    double? longitude,
    double? radius,
  }) = _ReportListRequest;

  factory ReportListRequest.fromJson(Map<String, dynamic> json) =>
      _$ReportListRequestFromJson(json);
}

@freezed
class ReportListResponse with _$ReportListResponse {
  const factory ReportListResponse({
    required List<Report> reports,
    required int totalElements,
    required int totalPages,
    required int currentPage,
    required int size,
    @Default(false) bool hasNext,
    @Default(false) bool hasPrevious,
  }) = _ReportListResponse;

  factory ReportListResponse.fromJson(Map<String, dynamic> json) =>
      _$ReportListResponseFromJson(json);
}

@freezed
class ImageUploadRequest with _$ImageUploadRequest {
  const factory ImageUploadRequest({
    required String filename,
    required String mimeType,
    required int fileSize,
  }) = _ImageUploadRequest;

  factory ImageUploadRequest.fromJson(Map<String, dynamic> json) =>
      _$ImageUploadRequestFromJson(json);
}

@freezed
class ImageUploadResponse with _$ImageUploadResponse {
  const factory ImageUploadResponse({
    required String imageId,
    required String uploadUrl,
    required String imageUrl,
    String? thumbnailUrl,
    DateTime? expiresAt,
  }) = _ImageUploadResponse;

  factory ImageUploadResponse.fromJson(Map<String, dynamic> json) =>
      _$ImageUploadResponseFromJson(json);
}

@freezed
class AIAnalysisRequest with _$AIAnalysisRequest {
  const factory AIAnalysisRequest({
    required String imageId,
    ReportType? expectedType,
    Map<String, dynamic>? metadata,
  }) = _AIAnalysisRequest;

  factory AIAnalysisRequest.fromJson(Map<String, dynamic> json) =>
      _$AIAnalysisRequestFromJson(json);
}

@freezed
class ReportStatsResponse with _$ReportStatsResponse {
  const factory ReportStatsResponse({
    required int totalReports,
    required int submittedReports,
    required int inReviewReports,
    required int approvedReports,
    required int resolvedReports,
    required int rejectedReports,
    required Map<String, int> reportsByType,
    required Map<String, int> reportsByPriority,
    required Map<String, int> reportsByMonth,
  }) = _ReportStatsResponse;

  factory ReportStatsResponse.fromJson(Map<String, dynamic> json) =>
      _$ReportStatsResponseFromJson(json);
}

@freezed
class AddCommentRequest with _$AddCommentRequest {
  const factory AddCommentRequest({
    required String content,
  }) = _AddCommentRequest;

  factory AddCommentRequest.fromJson(Map<String, dynamic> json) =>
      _$AddCommentRequestFromJson(json);
}

@freezed
class UpdateCommentRequest with _$UpdateCommentRequest {
  const factory UpdateCommentRequest({
    required String content,
  }) = _UpdateCommentRequest;

  factory UpdateCommentRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateCommentRequestFromJson(json);
}