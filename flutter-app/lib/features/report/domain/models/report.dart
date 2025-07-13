import 'package:freezed_annotation/freezed_annotation.dart';

part 'report.freezed.dart';
part 'report.g.dart';

enum ReportStatus {
  @JsonValue('DRAFT')
  draft,
  @JsonValue('SUBMITTED')
  submitted,
  @JsonValue('IN_REVIEW')
  inReview,
  @JsonValue('APPROVED')
  approved,
  @JsonValue('REJECTED')
  rejected,
  @JsonValue('RESOLVED')
  resolved,
  @JsonValue('CLOSED')
  closed,
}

enum ReportType {
  @JsonValue('POTHOLE')
  pothole,
  @JsonValue('STREET_LIGHT')
  streetLight,
  @JsonValue('TRASH')
  trash,
  @JsonValue('GRAFFITI')
  graffiti,
  @JsonValue('ROAD_DAMAGE')
  roadDamage,
  @JsonValue('CONSTRUCTION')
  construction,
  @JsonValue('OTHER')
  other,
}

enum Priority {
  @JsonValue('LOW')
  low,
  @JsonValue('MEDIUM')
  medium,
  @JsonValue('HIGH')
  high,
  @JsonValue('URGENT')
  urgent,
}

@freezed
class ReportLocation with _$ReportLocation {
  const factory ReportLocation({
    required double latitude,
    required double longitude,
    String? address,
    String? city,
    String? district,
    String? postalCode,
    String? landmark,
  }) = _ReportLocation;

  factory ReportLocation.fromJson(Map<String, dynamic> json) =>
      _$ReportLocationFromJson(json);
}

@freezed
class ReportImage with _$ReportImage {
  const factory ReportImage({
    required String id,
    required String url,
    String? thumbnailUrl,
    String? filename,
    int? fileSize,
    String? mimeType,
    @Default(0) int order,
    DateTime? uploadedAt,
  }) = _ReportImage;

  factory ReportImage.fromJson(Map<String, dynamic> json) =>
      _$ReportImageFromJson(json);
}

@freezed
class AIAnalysisResult with _$AIAnalysisResult {
  const factory AIAnalysisResult({
    required String id,
    required ReportType detectedType,
    required double confidence,
    String? description,
    Map<String, dynamic>? metadata,
    List<String>? tags,
    @Default(Priority.medium) Priority suggestedPriority,
    DateTime? analyzedAt,
  }) = _AIAnalysisResult;

  factory AIAnalysisResult.fromJson(Map<String, dynamic> json) =>
      _$AIAnalysisResultFromJson(json);
}

@freezed
class Report with _$Report {
  const factory Report({
    required String id,
    required String title,
    required String description,
    required ReportType type,
    required ReportStatus status,
    required ReportLocation location,
    required List<ReportImage> images,
    required int userId,
    String? userFullName,
    @Default(Priority.medium) Priority priority,
    AIAnalysisResult? aiAnalysis,
    DateTime? submittedAt,
    DateTime? reviewedAt,
    DateTime? resolvedAt,
    required DateTime createdAt,
    DateTime? updatedAt,
    String? reviewComment,
    String? resolutionComment,
    int? assignedToUserId,
    String? assignedToUserName,
    Map<String, dynamic>? metadata,
    @Default(0) int viewCount,
    @Default(0) int likeCount,
    @Default(false) bool isLiked,
    @Default(false) bool isBookmarked,
  }) = _Report;

  factory Report.fromJson(Map<String, dynamic> json) => _$ReportFromJson(json);
}

@freezed
class ReportComment with _$ReportComment {
  const factory ReportComment({
    required String id,
    required String reportId,
    required int userId,
    required String userFullName,
    String? userProfileImage,
    required String content,
    DateTime? createdAt,
    DateTime? updatedAt,
    @Default(false) bool isEdited,
    @Default(false) bool isDeleted,
  }) = _ReportComment;

  factory ReportComment.fromJson(Map<String, dynamic> json) =>
      _$ReportCommentFromJson(json);
}