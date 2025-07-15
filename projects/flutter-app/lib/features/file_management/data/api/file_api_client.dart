import 'dart:io';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/file_dto.dart';
import '../models/file_search_response.dart';
import '../../../../core/config/app_config.dart';

part 'file_api_client.g.dart';

@RestApi()
abstract class FileApiClient {
  factory FileApiClient(Dio dio, {String? baseUrl}) = _FileApiClient;

  static String get defaultBaseUrl => AppConfig.fileServerUrl;

  @POST('/upload/')
  @MultiPart()
  Future<FileUploadResponse> uploadFile(
    @Part(name: 'file') File file,
    @Part(name: 'analyze') bool analyze,
    @Part(name: 'tags') List<String>? tags,
  );

  @GET('/files/{fileId}')
  Future<FileDto> getFile(@Path('fileId') String fileId);

  @DELETE('/files/{fileId}')
  Future<void> deleteFile(@Path('fileId') String fileId);

  @GET('/status/{taskId}')
  Future<AnalysisStatusResponse> getAnalysisStatus(@Path('taskId') String taskId);
  
  @POST('/batch-upload/')
  @MultiPart()
  Future<List<FileUploadResponse>> batchUploadFiles(
    @Part(name: 'files') List<File> files,
    @Part(name: 'analyze') bool analyze,
  );
  
  @GET('/health')
  Future<Map<String, dynamic>> checkHealth();
  
  @GET('/files/search/')
  Future<FileSearchResponse> searchFilesByTag(@Query('tag') String tag);
  
  @GET('/files/search/')
  Future<FileSearchResponse> searchFilesByTags(@Query('tags') List<String> tags);
}
