import 'dart:io';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../../../../core/config/app_config.dart';
import '../models/ai_analysis_dto.dart';

part 'ai_api_client.g.dart';

@RestApi()
abstract class AiApiClient {
  factory AiApiClient(Dio dio, {String? baseUrl}) = _AiApiClient;

  static String get defaultBaseUrl => AppConfig.aiServerUrl;

  @POST('/ai/analyze/comprehensive')
  @MultiPart()
  Future<AiAnalysisDto> analyzeDocument(
    @Part(name: 'image') File file,  // MultipartFile 대신 File 사용
    @Part(name: 'options') String analysisOptions,
  );

  @POST('/ai/analyze/batch')
  @MultiPart()
  Future<List<AiAnalysisDto>> batchAnalyze(
    @Part(name: 'files') List<File> files,  // MultipartFile 대신 File 사용
    @Part(name: 'options') String analysisOptions,
  );

  @GET('/analysis/{id}')
  Future<AiAnalysisDto> getAnalysisResult(@Path('id') String id);

  @GET('/ai/analysis/report/{reportId}')
  Future<List<AiAnalysisDto>> getAnalysisByReportId(
    @Path('reportId') String reportId,
  );

  @POST('/ai/extract-text')
  @MultiPart()
  Future<Map<String, dynamic>> extractText(
    @Part(name: 'file') File file,  // MultipartFile 대신 File 사용
  );

  @GET('/ai/health')
  Future<Map<String, dynamic>> checkHealth();

  @POST('/ai/validate')
  @MultiPart()
  Future<Map<String, dynamic>> validateDocument(
    @Part(name: 'file') File file,  // MultipartFile 대신 File 사용
    @Part(name: 'rules') String validationRules,
  );
}