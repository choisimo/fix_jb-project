import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/api/api_client.dart';
import 'api/report_api_client.dart';
import '../domain/models/report.dart';
import '../domain/models/report_models.dart';

final reportApiClientProvider = Provider<ReportApiClient>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ReportApiClient(apiClient.dio);
});

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  final reportApiClient = ref.watch(reportApiClientProvider);
  return ReportRepository(reportApiClient);
});

class ReportRepository {
  final ReportApiClient _reportApiClient;
  
  ReportRepository(this._reportApiClient);
  
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
      
      // For now, we'll use a placeholder upload since we don't have the actual upload URL handling
      // In a real implementation, you'd use the upload URL directly with Dio
      // await _reportApiClient.uploadImage(uploadResponse.uploadUrl, bytes, mimeType);
      
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
    
    return uploadResponses;
  }
  
  Future<AIAnalysisResult> analyzeImage(String imageId, {ReportType? expectedType}) async {
    try {
      final request = AIAnalysisRequest(
        imageId: imageId,
        expectedType: expectedType,
      );
      return await _reportApiClient.analyzeImage(imageId, request.toJson());
    } on DioException catch (e) {
      throw _handleError(e);
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
}
