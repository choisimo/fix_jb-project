import 'package:freezed_annotation/freezed_annotation.dart';

part 'report.freezed.dart';
part 'report.g.dart';

enum ReportStatus {
  @JsonValue('DRAFT')
  draft,
  @JsonValue('SUBMITTED')
  submitted,
  @JsonValue('IN_PROGRESS')
  inProgress,
  @JsonValue('RESOLVED')
  resolved,
  @JsonValue('REJECTED')
  rejected,
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
    @Default(false) bool isPrimary,
  }) = _ReportImage;

  factory ReportImage.fromJson(Map<String, dynamic> json) =>
      _$ReportImageFromJson(json);
}

@freezed
class ReportComment with _$ReportComment {
  const factory ReportComment({
    required String id,
    required String reportId,
    required String authorId,
    required String authorName,
    String? authorProfileImage,
    required String content,
    required DateTime createdAt,
    DateTime? updatedAt,
    String? parentCommentId,
    @Default(0) int likesCount,
    @Default(false) bool isLiked,
    @Default(false) bool canEdit,
    @Default(false) bool canDelete,
    @Default(false) bool isEdited,
  }) = _ReportComment;

  factory ReportComment.fromJson(Map<String, dynamic> json) =>
      _$ReportCommentFromJson(json);
}

@freezed
class DetectedObject with _$DetectedObject {
  const factory DetectedObject({
    required String type,
    required double confidence,
    String? severity,
    String? condition,
    String? amount,
  }) = _DetectedObject;

  factory DetectedObject.fromJson(Map<String, dynamic> json) =>
      _$DetectedObjectFromJson(json);
}

@freezed
class OCRAnalysisResult with _$OCRAnalysisResult {
  const factory OCRAnalysisResult({
    required bool hasText,
    required int textCount,
    required List<String> texts,
  }) = _OCRAnalysisResult;

  factory OCRAnalysisResult.fromJson(Map<String, dynamic> json) =>
      _$OCRAnalysisResultFromJson(json);
}

@freezed
class AIAgentAnalysisResult with _$AIAgentAnalysisResult {
  const factory AIAgentAnalysisResult({
    required String sceneDescription,
    required String priorityRecommendation,
    required int processingTime,
    required double confidenceScore,
    required int analysisTimestamp,
    required List<DetectedObject> detectedObjects,
    required Map<String, dynamic> contextAnalysis,
    String? estimatedRepairCost,
  }) = _AIAgentAnalysisResult;

  factory AIAgentAnalysisResult.fromJson(Map<String, dynamic> json) =>
      _$AIAgentAnalysisResultFromJson(json);
}

@freezed
class IntegratedAnalysisResult with _$IntegratedAnalysisResult {
  const factory IntegratedAnalysisResult({
    required List<String> integratedRecommendations,
    required String sceneUnderstanding,
    required int textElementsFound,
    required Map<String, dynamic> extractedInformation,
    required List<DetectedObject> visualAnalysis,
    required double analysisConfidence,
  }) = _IntegratedAnalysisResult;

  factory IntegratedAnalysisResult.fromJson(Map<String, dynamic> json) =>
      _$IntegratedAnalysisResultFromJson(json);
}

@freezed
class ComprehensiveAIAnalysisResult with _$ComprehensiveAIAnalysisResult {
  const factory ComprehensiveAIAnalysisResult({
    required bool success,
    required String filename,
    required int processingTime,
    required DateTime timestamp,
    required double overallConfidence,
    required List<String> recommendations,
    
    // Roboflow 결과
    Map<String, dynamic>? roboflow,
    
    // OCR 결과  
    OCRAnalysisResult? ocr,
    
    // AI Agent 결과
    AIAgentAnalysisResult? aiAgent,
    
    // 통합 분석 결과
    IntegratedAnalysisResult? integratedAnalysis,
    
    // 전체 감지 개수
    @Default(0) int detectionCount,
    
    // AI가 제안하는 필드들
    String? suggestedTitle,
    String? suggestedDescription,
    ReportType? suggestedType,
    Priority? suggestedPriority,
  }) = _ComprehensiveAIAnalysisResult;

  factory ComprehensiveAIAnalysisResult.fromJson(Map<String, dynamic> json) =>
      _$ComprehensiveAIAnalysisResultFromJson(json);
}

@freezed
class Report with _$Report {
  const factory Report({
    required String id,
    required String title,
    required String description,
    required ReportType type,
    required ReportStatus status,
    required String authorId,
    required String authorName,
    String? authorProfileImage,
    ReportLocation? location,
    @Default([]) List<ReportImage> images,
    @Default([]) List<ReportComment> comments,
    @Default(Priority.medium) Priority priority,
    ComprehensiveAIAnalysisResult? comprehensiveAiAnalysis,
    DateTime? submittedAt,
    DateTime? reviewedAt,
    DateTime? resolvedAt,
    required DateTime createdAt,
    DateTime? updatedAt,
    String? reviewComment,
    String? resolutionComment,
    String? assignedToUserId,
    String? assignedToUserName,
    Map<String, dynamic>? metadata,
    @Default(0) int viewCount,
    @Default(0) int likeCount,
    @Default(0) int commentsCount,
    @Default(false) bool isLiked,
    @Default(false) bool isBookmarked,
    @Default(false) bool canEdit,
    @Default(false) bool canDelete,
  }) = _Report;

  factory Report.fromJson(Map<String, dynamic> json) => _$ReportFromJson(json);
}