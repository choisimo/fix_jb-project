import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';

import '../../../core/api/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/utils/token_manager.dart';
import '../../../core/services/webhook_upload_service.dart';
import '../../../core/network/dio_client.dart';
import 'api/report_api_client.dart';
import 'api/ai_api_client.dart';
import '../domain/models/report.dart';
import '../presentation/controllers/create_report_controller.dart';

final reportApiClientProvider = Provider<ReportApiClient>((ref) {
  // Reports는 /api 없이 직접 /reports 경로를 사용하므로 별도 Dio 인스턴스 생성
  final dio = Dio(BaseOptions(
    baseUrl: ApiConstants.reportsBaseUrl, // http://10.0.2.2:8080
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));
  
  // 토큰 추가 인터셉터
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      // Add auth token if available
      final token = await TokenManager.getAccessToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      handler.next(options);
    },
  ));
  
  return ReportApiClient(dio);
});

final webhookUploadServiceProvider = Provider<WebhookUploadService>((ref) {
  // Dio 인스턴스를 직접 생성 (기존 패턴 따름)
  final dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 5),
    sendTimeout: const Duration(seconds: 10),
  ));
  return WebhookUploadService(dio);
});

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  final reportApiClient = ref.watch(reportApiClientProvider);
  final aiApiClient = ref.watch(aiApiClientProvider);
  final webhookUploadService = ref.watch(webhookUploadServiceProvider);
  return ReportRepository(reportApiClient, aiApiClient, webhookUploadService);
});

class ReportRepository {
  final ReportApiClient _reportApiClient;
  final AiApiClient _aiApiClient;
  final WebhookUploadService _webhookUploadService;
  
  ReportRepository(this._reportApiClient, this._aiApiClient, this._webhookUploadService);
  
  Future<ReportListResponse> getReports(ReportListRequest request) async {
    try {
      final queryParams = request.toJson();
      queryParams.removeWhere((key, value) => value == null);
      return await _reportApiClient.getReports(queryParams);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<Report> getReport(String id) async {
    try {
      return await _reportApiClient.getReport(id);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<Report> createReport(CreateReportRequest request) async {
    try {
      return await _reportApiClient.createReport(request.toJson());
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // 이미지 업로드 메서드 추가
  Future<ImageUploadResponse> uploadImage(XFile image) async {
    try {
      final multipartFile = await MultipartFile.fromFile(
        image.path,
        filename: image.name,
        contentType: MediaType('image', _getImageExtension(image.path)),
      );
      
      final response = await _reportApiClient.uploadImage(multipartFile);
      return ImageUploadResponse.fromJson(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // 복합 AI 분석
  Future<ComprehensiveAIAnalysisResult> analyzeImageComprehensive(XFile image) async {
    try {
      final multipartFile = await MultipartFile.fromFile(
        image.path,
        filename: image.name,
        contentType: MediaType('image', _getImageExtension(image.path)),
      );
      
      return await _aiApiClient.analyzeImageComprehensive(multipartFile);
    } on DioException catch (e) {
      debugPrint('Comprehensive AI Analysis error: ${e.toString()}');
      throw Exception('Comprehensive AI analysis failed: $e');
    }
  }

  String _getImageExtension(String path) {
    final extension = path.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'jpeg';
      case 'png':
        return 'png';
      case 'gif':
        return 'gif';
      case 'webp':
        return 'webp';
      default:
        return 'jpeg';
    }
  }
  
  Future<Report> updateReport(String id, UpdateReportRequest request) async {
    try {
      final requestData = request.toJson();
      requestData.removeWhere((key, value) => value == null);
      return await _reportApiClient.updateReport(id, requestData);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<void> deleteReport(String id) async {
    try {
      await _reportApiClient.deleteReport(id);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<Report> submitReport(String id) async {
    try {
      return await _reportApiClient.submitReport(id);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<void> likeReport(String id) async {
    try {
      await _reportApiClient.likeReport(id);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<void> unlikeReport(String id) async {
    try {
      await _reportApiClient.unlikeReport(id);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<void> bookmarkReport(String id) async {
    try {
      await _reportApiClient.bookmarkReport(id);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<void> unbookmarkReport(String id) async {
    try {
      await _reportApiClient.unbookmarkReport(id);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<List<ReportComment>> getReportComments(String reportId) async {
    try {
      return await _reportApiClient.getReportComments(reportId);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<ReportComment> addComment(String reportId, AddCommentRequest request) async {
    try {
      return await _reportApiClient.addComment(reportId, request.toJson());
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<ReportComment> updateComment(String commentId, UpdateCommentRequest request) async {
    try {
      return await _reportApiClient.updateComment(commentId, request.toJson());
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<void> deleteComment(String commentId) async {
    try {
      await _reportApiClient.deleteComment(commentId);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<ImageUploadResponse> uploadImage(XFile imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final filename = imageFile.name;
      final mimeType = imageFile.mimeType ?? 'image/jpeg';
      
      final uploadRequest = ImageUploadRequest(
        filename: filename,
        mimeType: mimeType,
        fileSize: bytes.length,
      );
      
      final uploadResponse = await _reportApiClient.requestImageUpload(uploadRequest.toJson());
      
      // 실제 이미지 업로드 수행
      await _uploadImageToUrl(uploadResponse.uploadUrl, bytes, mimeType);
      
      // 웹훅으로 추가 업로드 (비동기, 실패해도 무시)
      _webhookUploadService.uploadImageToWebhook(imageFile);
      
      return uploadResponse;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<List<ImageUploadResponse>> uploadImages(List<XFile> imageFiles) async {
    final List<ImageUploadResponse> uploadResponses = [];
    
    for (final imageFile in imageFiles) {
      final response = await uploadImage(imageFile);
      uploadResponses.add(response);
    }
    
    // 웹훅으로 추가 업로드 (비동기, 실패해도 무시)
    _webhookUploadService.uploadImagesToWebhook(imageFiles);
    
    return uploadResponses;
  }
  
  Future<AIAnalysisResult> analyzeImage(String imageId, {ReportType? expectedType}) async {
    try {
      // 이미지 ID로 이미지를 가져와서 분석하는 기능은 향후 구현 예정
      
      throw UnimplementedError('analyzeImage with imageId is not implemented. Use analyzeImageFile instead.');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<AIAnalysisResult> analyzeImageFile(XFile imageFile, {ReportType? expectedType}) async {
    try {
      final bytes = await imageFile.readAsBytes();
      
      // FormData 생성
      final formData = FormData.fromMap({
        'image': MultipartFile.fromBytes(
          bytes,
          filename: imageFile.name,
          contentType: MediaType.parse(imageFile.mimeType ?? 'image/jpeg'),
        ),
        'confidence': 50,
        'overlap': 30,
      });
      
      // AI Analysis Server에 직접 요청
      final aiDio = Dio(BaseOptions(
        baseUrl: 'http://10.0.2.2:8081', // AI Analysis Server
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
      ));
      
      // 토큰 추가
      final token = await TokenManager.getAccessToken();
      if (token != null) {
        aiDio.options.headers['Authorization'] = 'Bearer $token';
      }
      
      final response = await aiDio.post(
        'ai/analyze/image',
        data: formData,
      );
      
      // AI Analysis Server의 응답을 우리가 원하는 형태로 변환
      final analysisData = response.data;
      
      // 감지된 객체가 있는지 확인
      if (analysisData['success'] == true && analysisData['detections'] != null) {
        final detections = analysisData['detections'] as List;
        
        if (detections.isNotEmpty) {
          // 첫 번째 감지 결과를 사용
          final firstDetection = detections.first;
          final className = firstDetection['class'] as String? ?? 'other';
          final confidence = (firstDetection['confidence'] as num?)?.toDouble() ?? 0.5;
          
          // 클래스 이름을 ReportType으로 변환
          ReportType detectedType = _mapClassNameToReportType(className);
          Priority suggestedPriority = _determinePriorityFromConfidence(confidence);
          
          return AIAnalysisResult(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            detectedType: detectedType,
            confidence: confidence,
            description: '${className} 감지됨 (신뢰도: ${(confidence * 100).toStringAsFixed(1)}%)',
            suggestedPriority: suggestedPriority,
            analyzedAt: DateTime.now(),
            metadata: {
              'originalClass': className,
              'allDetections': detections,
              'processingTime': analysisData['processingTime'],
            },
          );
        }
      }
      
      // 감지된 객체가 없는 경우 기본값 반환
      return AIAnalysisResult(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        detectedType: ReportType.other,
        confidence: 0.3,
        description: '특정 문제를 식별할 수 없음',
        suggestedPriority: Priority.low,
        analyzedAt: DateTime.now(),
        metadata: {
          'message': 'No objects detected',
          'response': analysisData,
        },
      );
      
    } on DioException catch (e) {
      debugPrint('AI Analysis DioException: ${e.toString()}');
      debugPrint('Response data: ${e.response?.data}');
      throw _handleError(e);
    } catch (e) {
      debugPrint('AI Analysis error: ${e.toString()}');
      throw Exception('AI analysis failed: $e');
    }
  }

  Future<ComprehensiveAIAnalysisResult> analyzeImageFileComprehensive(
    XFile imageFile, {
    int confidence = 75,
    int overlap = 30,
  }) async {
    try {
      final bytes = await imageFile.readAsBytes();
      
      // FormData 생성
      final formData = FormData.fromMap({
        'image': MultipartFile.fromBytes(
          bytes,
          filename: imageFile.name,
          contentType: MediaType.parse(imageFile.mimeType ?? 'image/jpeg'),
        ),
        'confidence': confidence,
        'overlap': overlap,
      });
      
      // AI Analysis Server에 직접 요청 (통합 분석 엔드포인트)
      final aiDio = Dio(BaseOptions(
        baseUrl: 'http://10.0.2.2:8081', // AI Analysis Server
        connectTimeout: const Duration(seconds: 90),
        receiveTimeout: const Duration(seconds: 90),
      ));
      
      // 토큰 추가
      final token = await TokenManager.getAccessToken();
      if (token != null) {
        aiDio.options.headers['Authorization'] = 'Bearer $token';
      }
      
      final response = await aiDio.post(
        '/api/v1/ai/analyze/comprehensive',
        data: formData,
      );
      
      final data = response.data;
      
      // 응답 데이터를 ComprehensiveAIAnalysisResult로 변환
      return ComprehensiveAIAnalysisResult(
        success: data['success'] ?? false,
        filename: data['filename'] ?? imageFile.name,
        processingTime: data['processingTime'] ?? 0,
        timestamp: DateTime.fromMillisecondsSinceEpoch(data['timestamp'] ?? DateTime.now().millisecondsSinceEpoch),
        overallConfidence: (data['overallConfidence'] ?? 0.5).toDouble(),
        recommendations: List<String>.from(data['recommendations'] ?? []),
        roboflow: data['roboflow'],
        ocr: data['ocr'] != null ? OCRAnalysisResult.fromJson(data['ocr']) : null,
        aiAgent: data['aiAgent'] != null ? AIAgentAnalysisResult.fromJson(data['aiAgent']) : null,
        integratedAnalysis: data['integratedAnalysis'] != null 
            ? IntegratedAnalysisResult.fromJson(data['integratedAnalysis']) 
            : null,
        detectionCount: data['detectionCount'] ?? 0,
      );
      
    } on DioException catch (e) {
      debugPrint('Comprehensive AI Analysis DioException: ${e.toString()}');
      debugPrint('Response data: ${e.response?.data}');
      throw _handleError(e);
    } catch (e) {
      debugPrint('Comprehensive AI Analysis error: ${e.toString()}');
      throw Exception('Comprehensive AI analysis failed: $e');
    }
  }
  
  // 클래스 이름을 ReportType으로 변환하는 헬퍼 메서드
  ReportType _mapClassNameToReportType(String className) {
    switch (className.toLowerCase()) {
      case 'pothole':
      case 'hole':
        return ReportType.pothole;
      case 'streetlight':
      case 'light':
      case 'lamp':
        return ReportType.streetLight;
      case 'trash':
      case 'garbage':
      case 'waste':
        return ReportType.trash;
      case 'graffiti':
      case 'vandalism':
        return ReportType.graffiti;
      case 'road_damage':
      case 'crack':
      case 'damage':
        return ReportType.roadDamage;
      case 'construction':
      case 'work':
        return ReportType.construction;
      default:
        return ReportType.other;
    }
  }
  
  // 신뢰도에 따라 우선순위를 결정하는 헬퍼 메서드
  Priority _determinePriorityFromConfidence(double confidence) {
    if (confidence >= 0.8) {
      return Priority.high;
    } else if (confidence >= 0.6) {
      return Priority.medium;
    } else {
      return Priority.low;
    }
  }
  
  Future<ReportStatsResponse> getReportStats() async {
    try {
      return await _reportApiClient.getReportStats();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<List<Report>> getNearbyReports({
    required double latitude,
    required double longitude,
    double radius = 1.0,
  }) async {
    try {
      return await _reportApiClient.getNearbyReports(latitude, longitude, radius);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<ReportListResponse> getUserReports(int userId, ReportListRequest request) async {
    try {
      final queryParams = request.toJson();
      queryParams.removeWhere((key, value) => value == null);
      return await _reportApiClient.getUserReports(userId, queryParams);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<ReportListResponse> getBookmarkedReports(ReportListRequest request) async {
    try {
      final queryParams = request.toJson();
      queryParams.removeWhere((key, value) => value == null);
      return await _reportApiClient.getBookmarkedReports(queryParams);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Exception _handleError(DioException error) {
    if (error.response != null) {
      final data = error.response!.data;
      if (data is Map<String, dynamic>) {
        final message = data['message'] ?? 'Unknown error occurred';
        final code = data['code'] ?? 'UNKNOWN_ERROR';
        return Exception('$code: $message');
      }
    }
    
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('Network timeout. Please check your connection.');
      case DioExceptionType.connectionError:
        return Exception('Connection error. Please check your internet connection.');
      default:
        return Exception('Network error occurred');
    }
  }
  
  /// 실제 업로드 URL로 이미지 업로드
  Future<void> _uploadImageToUrl(String uploadUrl, Uint8List imageBytes, String mimeType) async {
    try {
      final dio = Dio();
      
      // Content-Type 헤더 설정
      final options = Options(
        headers: {
          'Content-Type': mimeType,
          'Content-Length': imageBytes.length.toString(),
        },
        responseType: ResponseType.json,
      );
      
      // PUT 또는 POST 방식으로 업로드 (서버 설정에 따라)
      final response = await dio.put(
        uploadUrl,
        data: imageBytes,
        options: options,
        onSendProgress: (sent, total) {
          final progress = (sent / total * 100).toStringAsFixed(1);
          debugPrint('Upload progress: $progress%');
        },
      );
      
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Image upload failed with status: ${response.statusCode}');
      }
      
      debugPrint('Image uploaded successfully to: $uploadUrl');
      
    } catch (e) {
      debugPrint('Image upload failed: $e');
      throw Exception('Failed to upload image: $e');
    }
  }
  
  /// Presigned URL 방식의 이미지 업로드 (AWS S3 등)
  Future<void> _uploadImageToPresignedUrl(String presignedUrl, Uint8List imageBytes, String mimeType) async {
    try {
      final dio = Dio();
      
      // AWS S3 업로드용 헤더 설정
      final options = Options(
        headers: {
          'Content-Type': mimeType,
        },
        validateStatus: (status) => status! < 400, // 400 미만을 성공으로 간주
      );
      
      final response = await dio.put(
        presignedUrl,
        data: imageBytes,
        options: options,
        onSendProgress: (sent, total) {
          final progress = (sent / total * 100).toStringAsFixed(1);
          debugPrint('Upload progress: $progress%');
        },
      );
      
      debugPrint('Image uploaded successfully. Status: ${response.statusCode}');
      
    } catch (e) {
      debugPrint('Presigned URL upload failed: $e');
      throw Exception('Failed to upload image to presigned URL: $e');
    }
  }
  
  /// Multipart form data 방식의 이미지 업로드
  Future<void> _uploadImageMultipart(String uploadUrl, Uint8List imageBytes, String mimeType, String fileName) async {
    try {
      final dio = Dio();
      
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(
          imageBytes,
          filename: fileName,
          contentType: MediaType.parse(mimeType),
        ),
      });
      
      final response = await dio.post(
        uploadUrl,
        data: formData,
        onSendProgress: (sent, total) {
          final progress = (sent / total * 100).toStringAsFixed(1);
          debugPrint('Upload progress: $progress%');
        },
      );
      
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Multipart upload failed with status: ${response.statusCode}');
      }
      
      debugPrint('Multipart upload successful');
      
    } catch (e) {
      debugPrint('Multipart upload failed: $e');
      throw Exception('Failed to upload image via multipart: $e');
    }
  }
}
