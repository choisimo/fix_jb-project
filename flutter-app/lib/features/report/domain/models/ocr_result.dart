import 'package:freezed_annotation/freezed_annotation.dart';

part 'ocr_result.freezed.dart';
part 'ocr_result.g.dart';

enum OcrEngine {
  @JsonValue('GOOGLE_ML_KIT')
  googleMLKit,
  @JsonValue('GOOGLE_VISION')
  googleVision,
  @JsonValue('QWEN_VL')
  qwenVL,
}

enum OcrStatus {
  @JsonValue('PROCESSING')
  processing,
  @JsonValue('SUCCESS')
  success,
  @JsonValue('FAILED')
  failed,
  @JsonValue('PARTIAL')
  partial,
}

@freezed
class TextBlock with _$TextBlock {
  const factory TextBlock({
    required String text,
    required double confidence,
    @Default([]) List<Point> boundingBox,
    String? language,
    Map<String, dynamic>? metadata,
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

@freezed
class OcrResult with _$OcrResult {
  const factory OcrResult({
    required String id,
    required OcrEngine engine,
    required OcrStatus status,
    required String extractedText,
    required double confidence,
    @Default([]) List<TextBlock> textBlocks,
    String? language,
    Map<String, dynamic>? metadata,
    DateTime? processedAt,
    int? processingTimeMs,
    String? errorMessage,
  }) = _OcrResult;

  factory OcrResult.fromJson(Map<String, dynamic> json) =>
      _$OcrResultFromJson(json);
}

@freezed
class OcrConfig with _$OcrConfig {
  const factory OcrConfig({
    @Default(OcrEngine.googleMLKit) OcrEngine preferredEngine,
    @Default(0.5) double confidenceThreshold,
    @Default(true) bool enableLanguageDetection,
    @Default(['ko', 'en']) List<String> supportedLanguages,
    @Default(5000) int timeoutMs,
    @Default(true) bool enableFallback,
    Map<String, dynamic>? engineSpecificConfig,
  }) = _OcrConfig;

  factory OcrConfig.fromJson(Map<String, dynamic> json) =>
      _$OcrConfigFromJson(json);
}