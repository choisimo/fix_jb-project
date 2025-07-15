import 'package:json_annotation/json_annotation.dart';
import 'file_dto.dart';

part 'file_search_response.g.dart';

@JsonSerializable()
class FileSearchResponse {
  final List<FileDto> files;
  final int total;
  final String? nextCursor;

  FileSearchResponse({
    required this.files,
    required this.total,
    this.nextCursor,
  });

  factory FileSearchResponse.fromJson(Map<String, dynamic> json) => 
      _$FileSearchResponseFromJson(json);
  
  Map<String, dynamic> toJson() => _$FileSearchResponseToJson(this);
}
