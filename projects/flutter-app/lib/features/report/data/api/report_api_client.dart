import 'dart:io';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../../../../core/config/app_config.dart';
import '../models/report_dto.dart';

part 'report_api_client.g.dart';

@RestApi()
abstract class ReportApiClient {
  factory ReportApiClient(Dio dio, {String? baseUrl}) = _ReportApiClient;

  static String get defaultBaseUrl => AppConfig.apiBaseUrl;

  @GET('/reports')
  Future<List<ReportDto>> getReports({
    @Query('page') int? page,
    @Query('size') int? size,
    @Query('status') String? status,
  });

  @GET('/reports/{id}')
  Future<ReportDto> getReportById(@Path('id') String id);

  @POST('/reports')
  Future<ReportDto> createReport(@Body() ReportDto report);

  @PUT('/reports/{id}')
  Future<ReportDto> updateReport(
    @Path('id') String id,
    @Body() ReportDto report,
  );

  @DELETE('/reports/{id}')
  Future<void> deleteReport(@Path('id') String id);

  @POST('/reports/{id}/upload')
  @MultiPart()
  Future<ReportDto> uploadReportFile(
    @Path('id') String id,
    @Part(name: 'file') File file, // MultipartFile 대신 File 사용
    @Part(name: 'type') String fileType,
  );

  @POST('/reports/batch-upload')
  @MultiPart()
  Future<List<ReportDto>> batchUploadReports(
    @Part(name: 'files') List<File> files, // MultipartFile 대신 File 사용
    @Part(name: 'metadata') String metadata,
  );
  
  // 파일 서버와의 통합을 위한 메서드
  @POST('/reports/{id}/attach-file')
  Future<ReportDto> attachFileToReport(
    @Path('id') String id,
    @Field('fileId') String fileId,
    @Field('fileUrl') String fileUrl,
    @Field('thumbnailUrl') String? thumbnailUrl,
  );
  
  @DELETE('/reports/{id}/detach-file/{fileId}')
  Future<ReportDto> detachFileFromReport(
    @Path('id') String id,
    @Path('fileId') String fileId,
  );
  
  @GET('/reports/{id}/files')
  Future<List<String>> getReportFileIds(@Path('id') String id);
}