import 'dart:io';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/api/report_api_client.dart';
import '../../data/models/report_dto.dart';
import '../../domain/models/report.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/utils/token_manager.dart';
import 'dart:developer' as developer;

/// Report Service: Handles all report-related API interactions
class ReportService {
  final Dio _dio;
  final ReportApiClient _apiClient;
  
  ReportService(this._dio) 
      : _apiClient = ReportApiClient(_dio, baseUrl: AppConfig.apiBaseUrl);
  
  /// Creates a new report with images
  Future<Report> createReport(ReportDto reportDto, List<XFile> images) async {
    try {
      developer.log('Creating report: ${reportDto.title}', name: 'REPORT_SERVICE');
      
      // 1. Create the report first
      final createdReport = await _apiClient.createReport(reportDto);
      developer.log('Report created with ID: ${createdReport.id}', name: 'REPORT_SERVICE');
      
      if (images.isNotEmpty) {
        developer.log('Uploading ${images.length} images', name: 'REPORT_SERVICE');
        
        // 2. Upload images one by one
        for (var i = 0; i < images.length; i++) {
          try {
            final imageFile = File(images[i].path);
            
            // Check if file exists before attempting to upload
            if (!await imageFile.exists()) {
              developer.log('Image file does not exist: ${images[i].path}', name: 'REPORT_SERVICE', error: true);
              continue;
            }
            
            await _apiClient.uploadReportFile(
              createdReport.id!, 
              imageFile,
              'image/jpeg', // Default type, consider detecting actual type
            );
            developer.log('Uploaded image ${i+1}/${images.length}', name: 'REPORT_SERVICE');
          } catch (e) {
            developer.log(
              'Error uploading image ${i+1}: $e', 
              name: 'REPORT_SERVICE', 
              error: true
            );
            // Continue with other images even if one fails
          }
        }
      }
      
      // 3. Get the final report with attached images
      final finalReport = await _apiClient.getReportById(createdReport.id!);
      return Report.fromDto(finalReport);
    } catch (e) {
      developer.log('Error creating report: $e', name: 'REPORT_SERVICE', error: true);
      throw _handleError(e);
    }
  }
  
  /// Get a list of reports
  Future<List<Report>> getReports({
    int page = 0,
    int size = 20,
    String? status,
  }) async {
    try {
      // 인증 토큰 가져오기
      final token = await TokenManager.getAccessToken();
      
      // 인증 헤더 설정
      if (token != null) {
        _dio.options.headers['Authorization'] = 'Bearer $token';
      } else {
        developer.log('⚠️ 토큰이 없습니다! 로그인이 필요할 수 있습니다.', name: 'REPORT_SERVICE');
      }
      
      final reports = await _apiClient.getReports(
        page: page,
        size: size,
        status: status,
      );
      return reports.map((dto) => Report.fromDto(dto)).toList();
    } catch (e) {
      developer.log('❌ 보고서 목록 가져오기 실패: $e', name: 'REPORT_SERVICE', error: true);
      throw _handleError(e);
    }
  }
  
  /// Get a report by ID
  Future<Report> getReportById(String id) async {
    try {
      final report = await _apiClient.getReportById(id);
      return Report.fromDto(report);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  /// Update a report
  Future<Report> updateReport(String id, ReportDto reportDto) async {
    try {
      final report = await _apiClient.updateReport(id, reportDto);
      return Report.fromDto(report);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  /// Delete a report
  Future<void> deleteReport(String id) async {
    try {
      await _apiClient.deleteReport(id);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  /// Handle API errors and provide meaningful error messages
  Exception _handleError(dynamic e) {
    if (e is DioException) {
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return Exception('Network timeout. Please check your internet connection.');
          
        case DioExceptionType.badResponse:
          final statusCode = e.response?.statusCode;
          final message = e.response?.data?['message'] ?? 'Server error occurred';
          
          if (statusCode == 404) {
            return Exception('Resource not found: $message');
          } else if (statusCode == 400) {
            return Exception('Invalid request: $message');
          } else if (statusCode == 401 || statusCode == 403) {
            return Exception('Authentication error: $message');
          } else {
            return Exception('Server error ($statusCode): $message');
          }
          
        case DioExceptionType.cancel:
          return Exception('Request was cancelled');
          
        case DioExceptionType.connectionError:
          return Exception('Connection error. Please check your internet connection.');
          
        case DioExceptionType.badCertificate:
          return Exception('SSL Certificate error');
          
        default:
          return Exception('Network error: ${e.message}');
      }
    }
    return Exception('An unexpected error occurred: $e');
  }
}
