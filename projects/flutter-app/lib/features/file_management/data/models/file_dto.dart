import 'package:json_annotation/json_annotation.dart';
import 'analysis_result.dart';

part 'file_dto.g.dart';

@JsonSerializable()
class FileDto {
  final String fileId;
  final String filename;
  final String fileUrl;
  final String? thumbnailUrl;
  final int size;
  final String contentType;
  final String? analysisTaskId;
  final List<String> tags;

  FileDto({
    required this.fileId,
    required this.filename,
    required this.fileUrl,
    this.thumbnailUrl,
    required this.size,
    required this.contentType,
    this.analysisTaskId,
    this.tags = const [],
  });

  factory FileDto.fromJson(Map<String, dynamic> json) => _$FileDtoFromJson(json);
  Map<String, dynamic> toJson() => _$FileDtoToJson(this);
}

@JsonSerializable()
class FileUploadResponse {
  final bool success;
  final String fileId;
  final String fileUrl;
  final String? thumbnailUrl;
  final String filename;
  final int size;
  final String contentType;
  final String? analysisTaskId;

  FileUploadResponse({
    required this.success,
    required this.fileId,
    required this.fileUrl,
    this.thumbnailUrl,
    required this.filename,
    required this.size,
    required this.contentType,
    this.analysisTaskId,
  });

  factory FileUploadResponse.fromJson(Map<String, dynamic> json) =>
      _$FileUploadResponseFromJson(json);
  Map<String, dynamic> toJson() => _$FileUploadResponseToJson(this);
}

@JsonSerializable()
class AnalysisStatusResponse {
  final String taskId;
  final String status;
  final dynamic result; // Can be Map<String, dynamic> or AnalysisResult
  final String? error;
  final double? progress;

  AnalysisStatusResponse({
    required this.taskId,
    required this.status,
    this.result,
    this.error,
    this.progress,
  });
  
  /// Get the analysis result as a properly typed object if available
  AnalysisResult? get typedResult {
    if (result == null) return null;
    if (result is Map<String, dynamic>) {
      return AnalysisResult.fromJson(result as Map<String, dynamic>);
    } else if (result is AnalysisResult) {
      return result as AnalysisResult;
    }
    return null;
  }

  factory AnalysisStatusResponse.fromJson(Map<String, dynamic> json) =>
      _$AnalysisStatusResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AnalysisStatusResponseToJson(this);
}
