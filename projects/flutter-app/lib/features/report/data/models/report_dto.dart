import 'package:freezed_annotation/freezed_annotation.dart';

part 'report_dto.freezed.dart';
part 'report_dto.g.dart';

@freezed
class ReportDto with _$ReportDto {
  const factory ReportDto({
    String? id,
    required String title,
    required String type,
    String? description,
    String? status,
    String? priority,
    String? location,
    Map<String, dynamic>? metadata,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? fileUrl,
    int? fileSize,
  }) = _ReportDto;

  factory ReportDto.fromJson(Map<String, dynamic> json) =>
      _$ReportDtoFromJson(json);
}
