import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../../../report/domain/models/report.dart';

part 'ai_api_client.g.dart';

@RestApi()
abstract class AiApiClient {
  factory AiApiClient(Dio dio, {String baseUrl}) = _AiApiClient;

  @POST('/api/v1/ai/analyze/comprehensive')
  @MultiPart()
  Future<Map<String, dynamic>> analyzeImageComprehensive(
    @Part() MultipartFile image,
  );

  @GET('/api/v1/ai/health')
  Future<Map<String, dynamic>> getHealthStatus();

  @GET('/api/v1/ai/capabilities')
  Future<Map<String, dynamic>> getCapabilities();
}