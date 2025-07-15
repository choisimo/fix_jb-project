import 'package:json_annotation/json_annotation.dart';

part 'analysis_result.g.dart';

@JsonSerializable()
class AnalysisResult {
  final bool success;
  final String fileId;
  final Map<String, dynamic> predictions;
  final List<String> detectedLabels;
  final List<String> suggestedTags;
  final double confidence;
  final DateTime analysisTime;

  AnalysisResult({
    required this.success,
    required this.fileId,
    required this.predictions,
    required this.detectedLabels,
    required this.suggestedTags,
    required this.confidence,
    required this.analysisTime,
  });

  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    // Handle DateTime conversion from string
    final timestamp = json['analysisTime'] ?? DateTime.now().toIso8601String();
    final dateTime = timestamp is String 
        ? DateTime.parse(timestamp) 
        : DateTime.now();
    
    // Handle missing fields
    final detectedLabels = (json['detectedLabels'] as List?)
        ?.map((e) => e as String)
        .toList() ?? [];
        
    final suggestedTags = (json['suggestedTags'] as List?)
        ?.map((e) => e as String)
        .toList() ?? [];
    
    return AnalysisResult(
      success: json['success'] as bool? ?? false,
      fileId: json['fileId'] as String? ?? '',
      predictions: json['predictions'] as Map<String, dynamic>? ?? {},
      detectedLabels: detectedLabels,
      suggestedTags: suggestedTags,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      analysisTime: dateTime,
    );
  }

  Map<String, dynamic> toJson() => _$AnalysisResultToJson(this);
}
