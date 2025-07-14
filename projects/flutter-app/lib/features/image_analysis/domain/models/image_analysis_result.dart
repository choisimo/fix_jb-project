import 'package:freezed_annotation/freezed_annotation.dart';

part 'image_analysis_result.freezed.dart';
part 'image_analysis_result.g.dart';

@freezed
class ImageAnalysisResult with _$ImageAnalysisResult {
  const factory ImageAnalysisResult({
    OCRResult? ocrResult,
    AIAnalysisResult? aiResult,
    DateTime? analyzedAt,
    String? imagePath,  // 이미지 파일 경로 추가
  }) = _ImageAnalysisResult;
  
  factory ImageAnalysisResult.fromJson(Map<String, dynamic> json) =>
      _$ImageAnalysisResultFromJson(json);
}

@freezed
class OCRResult with _$OCRResult {
  const factory OCRResult({
    required List<String> texts,
    @JsonKey(name: 'textCount') required int textCount,
    @JsonKey(name: 'hasText') required bool hasText,
  }) = _OCRResult;
  
  factory OCRResult.fromJson(Map<String, dynamic> json) =>
      _$OCRResultFromJson(json);
}

@freezed
class AIAnalysisResult with _$AIAnalysisResult {
  const factory AIAnalysisResult({
    String? summary,
    @JsonKey(name: 'scene_description') String? sceneDescription,
    @JsonKey(name: 'priority_recommendation') String? priorityRecommendation,
    @JsonKey(name: 'confidence_score') double? confidenceScore,
    @JsonKey(name: 'detected_objects') List<DetectedObject>? detectedObjects,
    @JsonKey(name: 'context_analysis') Map<String, dynamic>? contextAnalysis,
  }) = _AIAnalysisResult;
  
  factory AIAnalysisResult.fromJson(Map<String, dynamic> json) =>
      _$AIAnalysisResultFromJson(json);
}

@freezed
class DetectedObject with _$DetectedObject {
  const factory DetectedObject({
    required String type,
    required double confidence,
    String? severity,
    String? condition,
  }) = _DetectedObject;
  
  factory DetectedObject.fromJson(Map<String, dynamic> json) =>
      _$DetectedObjectFromJson(json);
}

// 통합 분석 결과를 위한 새로운 모델
@freezed
class ComprehensiveAnalysisResult with _$ComprehensiveAnalysisResult {
  const factory ComprehensiveAnalysisResult({
    required bool success,
    required String filename,
    @JsonKey(name: 'detectionCount') required int detectionCount,
    @JsonKey(name: 'processingTime') required int processingTime,
    required int timestamp,
    @JsonKey(name: 'overallConfidence') required double overallConfidence,
    required List<String> recommendations,
    required OCRResult ocr,
    required RoboflowResult roboflow,
    @JsonKey(name: 'aiAgent') required AIAgentResult aiAgent,
    @JsonKey(name: 'integratedAnalysis') required IntegratedAnalysisResult integratedAnalysis,
  }) = _ComprehensiveAnalysisResult;
  
  factory ComprehensiveAnalysisResult.fromJson(Map<String, dynamic> json) =>
      _$ComprehensiveAnalysisResultFromJson(json);
}

@freezed
class RoboflowResult with _$RoboflowResult {
  const factory RoboflowResult({
    required bool success,
    required int confidence,
    required int overlap,
    @JsonKey(name: 'detectionCount') required int detectionCount,
    @JsonKey(name: 'processingTime') required int processingTime,
    required int timestamp,
    required List<RoboflowPrediction> predictions,
  }) = _RoboflowResult;
  
  factory RoboflowResult.fromJson(Map<String, dynamic> json) =>
      _$RoboflowResultFromJson(json);
}

@freezed
class RoboflowPrediction with _$RoboflowPrediction {
  const factory RoboflowPrediction({
    @JsonKey(name: 'class') required String className,
    required double confidence,
    required double x,
    required double y,
    required double width,
    required double height,
  }) = _RoboflowPrediction;
  
  factory RoboflowPrediction.fromJson(Map<String, dynamic> json) =>
      _$RoboflowPredictionFromJson(json);
}

@freezed
class AIAgentResult with _$AIAgentResult {
  const factory AIAgentResult({
    @JsonKey(name: 'scene_description') required String sceneDescription,
    @JsonKey(name: 'priority_recommendation') required String priorityRecommendation,
    @JsonKey(name: 'processing_time') required int processingTime,
    @JsonKey(name: 'context_analysis') required Map<String, dynamic> contextAnalysis,
    @JsonKey(name: 'confidence_score') required double confidenceScore,
    @JsonKey(name: 'analysis_timestamp') required int analysisTimestamp,
    @JsonKey(name: 'detected_objects') required List<DetectedObject> detectedObjects,
  }) = _AIAgentResult;
  
  factory AIAgentResult.fromJson(Map<String, dynamic> json) =>
      _$AIAgentResultFromJson(json);
}

@freezed
class IntegratedAnalysisResult with _$IntegratedAnalysisResult {
  const factory IntegratedAnalysisResult({
    @JsonKey(name: 'scene_understanding') required String sceneUnderstanding,
    @JsonKey(name: 'text_elements_found') required int textElementsFound,
    @JsonKey(name: 'extracted_information') required Map<String, dynamic> extractedInformation,
    @JsonKey(name: 'visual_analysis') required List<DetectedObject> visualAnalysis,
    @JsonKey(name: 'analysis_confidence') required double analysisConfidence,
    @JsonKey(name: 'integrated_recommendations') required List<String> integratedRecommendations,
  }) = _IntegratedAnalysisResult;
  
  factory IntegratedAnalysisResult.fromJson(Map<String, dynamic> json) =>
      _$IntegratedAnalysisResultFromJson(json);
}

@freezed
class TextBlock with _$TextBlock {
  const factory TextBlock({
    required String text,
    required List<Point> boundingBox,
    required double confidence,
  }) = _TextBlock;
  
  factory TextBlock.fromJson(Map<String, dynamic> json) =>
      _$TextBlockFromJson(json);
}

@freezed
class Point with _$Point {
  const factory Point({
    required double x,
    required double y,
  }) = _Point;
  
  factory Point.fromJson(Map<String, dynamic> json) =>
      _$PointFromJson(json);
}
