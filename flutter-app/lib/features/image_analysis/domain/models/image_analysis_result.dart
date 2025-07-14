import 'package:freezed_annotation/freezed_annotation.dart';

part 'image_analysis_result.freezed.dart';
part 'image_analysis_result.g.dart';

@freezed
class ImageAnalysisResult with _$ImageAnalysisResult {
  const factory ImageAnalysisResult({
    OCRResult? ocrResult,
    AIAnalysisResult? aiResult,
    DateTime? analyzedAt,
  }) = _ImageAnalysisResult;
  
  factory ImageAnalysisResult.fromJson(Map<String, dynamic> json) =>
      _$ImageAnalysisResultFromJson(json);
}

@freezed
class OCRResult with _$OCRResult {
  const factory OCRResult({
    required String rawText,
    required Map<String, dynamic> extractedFields,
    required double confidence,
    List<TextBlock>? textBlocks,
  }) = _OCRResult;
  
  factory OCRResult.fromJson(Map<String, dynamic> json) =>
      _$OCRResultFromJson(json);
}

@freezed
class AIAnalysisResult with _$AIAnalysisResult {
  const factory AIAnalysisResult({
    required Map<String, dynamic> extractedData,
    required String analysisType,
    required double confidence,
    List<String>? detectedObjects,
    Map<String, dynamic>? metadata,
  }) = _AIAnalysisResult;
  
  factory AIAnalysisResult.fromJson(Map<String, dynamic> json) =>
      _$AIAnalysisResultFromJson(json);
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
