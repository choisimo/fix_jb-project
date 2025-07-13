import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../../domain/models/report.dart';
import '../../domain/models/report_models.dart';

part 'report_api_client.g.dart';

@RestApi()
abstract class ReportApiClient {
  factory ReportApiClient(Dio dio, {String baseUrl}) = _ReportApiClient;

  @GET('/reports')
  Future<ReportListResponse> getReports(@Queries() Map<String, dynamic> queries);

  @GET('/reports/{id}')
  Future<Report> getReport(@Path() String id);

  @POST('/reports')
  Future<Report> createReport(@Body() Map<String, dynamic> request);

  @PUT('/reports/{id}')
  Future<Report> updateReport(
    @Path() String id,
    @Body() Map<String, dynamic> request,
  );

  @DELETE('/reports/{id}')
  Future<void> deleteReport(@Path() String id);

  @POST('/reports/{id}/submit')
  Future<Report> submitReport(@Path() String id);

  @POST('/reports/{id}/like')
  Future<void> likeReport(@Path() String id);

  @DELETE('/reports/{id}/like')
  Future<void> unlikeReport(@Path() String id);

  @POST('/reports/{id}/bookmark')
  Future<void> bookmarkReport(@Path() String id);

  @DELETE('/reports/{id}/bookmark')
  Future<void> unbookmarkReport(@Path() String id);

  @GET('/reports/{id}/comments')
  Future<List<ReportComment>> getReportComments(@Path() String id);

  @POST('/reports/{id}/comments')
  Future<ReportComment> addComment(
    @Path() String id,
    @Body() Map<String, dynamic> request,
  );

  @PUT('/comments/{id}')
  Future<ReportComment> updateComment(
    @Path() String id,
    @Body() Map<String, dynamic> request,
  );

  @DELETE('/comments/{id}')
  Future<void> deleteComment(@Path() String id);

  @POST('/images/upload')
  Future<ImageUploadResponse> requestImageUpload(@Body() Map<String, dynamic> request);

  @PUT('{uploadUrl}')
  Future<void> uploadImage(
    @Path('uploadUrl') String uploadUrl,
    @Body() List<int> imageData,
    @Header('Content-Type') String contentType,
  );

  @POST('/images/{id}/analyze')
  Future<AIAnalysisResult> analyzeImage(
    @Path() String id,
    @Body() Map<String, dynamic> request,
  );

  @GET('/reports/stats')
  Future<ReportStatsResponse> getReportStats();

  @GET('/reports/nearby')
  Future<List<Report>> getNearbyReports(
    @Query('latitude') double latitude,
    @Query('longitude') double longitude,
    @Query('radius') double radius,
  );

  @GET('/reports/user/{userId}')
  Future<ReportListResponse> getUserReports(
    @Path() int userId,
    @Queries() Map<String, dynamic> queries,
  );

  @GET('/reports/bookmarked')
  Future<ReportListResponse> getBookmarkedReports(@Queries() Map<String, dynamic> queries);
}