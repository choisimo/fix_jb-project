import 'dart:io';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/report_dto.dart';

part 'report_api_client.g.dart';

@RestApi(baseUrl: '/api/v1')
abstract class ReportApiClient {
  factory ReportApiClient(Dio dio, {String baseUrl}) = _ReportApiClient;

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
}