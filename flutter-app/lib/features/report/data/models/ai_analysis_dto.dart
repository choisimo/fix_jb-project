import 'package:freezed_annotation/freezed_annotation.dart';

part 'ai_analysis_dto.freezed.dart';
part 'ai_analysis_dto.g.dart';

@freezed
class AiAnalysisDto with _$AiAnalysisDto {
  const factory AiAnalysisDto({
    String? id,
    required String reportId,
    required String analysisType,
    Map<String, dynamic>? results,
    double? confidence,
    List<String>? detectedIssues,
    Map<String, dynamic>? suggestions,
    DateTime? analyzedAt,
    String? status,
    String? errorMessage,
  }) = _AiAnalysisDto;

  factory AiAnalysisDto.fromJson(Map<String, dynamic> json) =>
      _$AiAnalysisDtoFromJson(json);
}
