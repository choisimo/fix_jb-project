import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../../domain/models/report.dart';

part 'report_api_client.g.dart';

@RestApi()
abstract class ReportApiClient {
  factory ReportApiClient(Dio dio, {String baseUrl}) = _ReportApiClient;

  @GET('/reports')
  Future<Map<String, dynamic>> getReports(@Queries() Map<String, dynamic> queries);

  @GET('/reports/{id}')
  Future<Map<String, dynamic>> getReport(@Path() String id);

  @POST('/reports')
  Future<Map<String, dynamic>> createReport(@Body() Map<String, dynamic> request);

  @PUT('/reports/{id}')
  Future<Map<String, dynamic>> updateReport(
    @Path() String id,
    @Body() Map<String, dynamic> request,
  );

  @DELETE('/reports/{id}')
  Future<void> deleteReport(@Path() String id);

  @POST('/reports/{id}/submit')
  Future<Map<String, dynamic>> submitReport(@Path() String id);

  @POST('/reports/{id}/like')
  Future<void> likeReport(@Path() String id);

  @DELETE('/reports/{id}/like')
  Future<void> unlikeReport(@Path() String id);

  @POST('/reports/{id}/bookmark')
  Future<void> bookmarkReport(@Path() String id);

  @DELETE('/reports/{id}/bookmark')
  Future<void> unbookmarkReport(@Path() String id);

  @GET('/reports/{id}/comments')
  Future<List<Map<String, dynamic>>> getReportComments(@Path() String id);

  @POST('/reports/{id}/comments')
  Future<Map<String, dynamic>> addComment(
    @Path() String id,
    @Body() Map<String, dynamic> request,
  );

  @PUT('/comments/{id}')
  Future<Map<String, dynamic>> updateComment(
    @Path() String id,
    @Body() Map<String, dynamic> request,
  );

  @DELETE('/comments/{id}')
  Future<void> deleteComment(@Path() String id);

  @POST('/files/upload')
  @MultiPart()
  Future<Map<String, dynamic>> uploadImage(@Part() MultipartFile file);
}