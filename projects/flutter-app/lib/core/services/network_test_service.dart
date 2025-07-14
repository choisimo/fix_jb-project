import 'package:dio/dio.dart';
import 'dart:developer' as developer;
import '../constants/api_constants.dart';

class NetworkDiagnosticService {
  final Dio _dio;
  
  NetworkDiagnosticService(this._dio);
  
  /// AI 서버 연결 상태 확인
  Future<Map<String, dynamic>> checkAIServerConnection() async {
    try {
      developer.log('🔍 Checking AI server connection...', name: 'NETWORK_DIAGNOSTIC');
      
      final response = await _dio.get('/api/v1/ai/health');
      
      developer.log('✅ AI server connection successful', name: 'NETWORK_DIAGNOSTIC');
      return {
        'success': true,
        'statusCode': response.statusCode,
        'data': response.data,
        'message': 'AI server is reachable and healthy'
      };
    } on DioException catch (e) {
      developer.log('❌ AI server connection failed: ${e.type} - ${e.message}', name: 'NETWORK_DIAGNOSTIC');
      return {
        'success': false,
        'error': e.type.toString(),
        'message': e.message ?? 'Unknown network error',
        'statusCode': e.response?.statusCode,
        'responseData': e.response?.data,
      };
    } catch (e) {
      developer.log('❌ Unexpected error: $e', name: 'NETWORK_DIAGNOSTIC');
      return {
        'success': false,
        'error': 'UnexpectedException',
        'message': e.toString(),
      };
    }
  }
  
  /// 이미지 업로드 연결 확인
  Future<Map<String, dynamic>> checkImageUpload() async {
    try {
      developer.log('🔍 Checking image upload to AI server...', name: 'NETWORK_DIAGNOSTIC');
      
      // Create a small sample image data
      final sampleImageData = List.generate(100, (index) => index % 256);
      
      final formData = FormData.fromMap({
        'image': MultipartFile.fromBytes(
          sampleImageData,
          filename: 'sample_image.jpg',
        ),
      });
      
      final response = await _dio.post(
        '/api/v1/ai/analyze/comprehensive',
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
        ),
      );
      
      developer.log('✅ Image upload check successful', name: 'NETWORK_DIAGNOSTIC');
      return {
        'success': true,
        'statusCode': response.statusCode,
        'message': 'Image upload endpoint is reachable'
      };
    } on DioException catch (e) {
      developer.log('❌ Image upload check failed: ${e.type} - ${e.message}', name: 'NETWORK_DIAGNOSTIC');
      return {
        'success': false,
        'error': e.type.toString(),
        'message': e.message ?? 'Unknown network error',
        'statusCode': e.response?.statusCode,
        'responseData': e.response?.data,
      };
    } catch (e) {
      developer.log('❌ Unexpected error during image upload check: $e', name: 'NETWORK_DIAGNOSTIC');
      return {
        'success': false,
        'error': 'UnexpectedException',
        'message': e.toString(),
      };
    }
  }
  
  /// 전체 네트워크 진단
  Future<Map<String, dynamic>> runComprehensiveDiagnostic() async {
    developer.log('🔧 Running comprehensive network diagnostic...', name: 'NETWORK_TEST');
    
    final results = <String, dynamic>{};
    
    // 1. AI 서버 연결 확인
    results['healthCheck'] = await checkAIServerConnection();
    
    // 2. 이미지 업로드 확인 (헬스 체크가 성공한 경우에만)
    if (results['healthCheck']['success'] == true) {
      results['imageUploadTest'] = await checkImageUpload();
    } else {
      results['imageUploadTest'] = {
        'success': false,
        'message': 'Skipped due to health check failure'
      };
    }
    
    // 3. 전체 진단 결과
    final bool overallSuccess = results['healthCheck']['success'] == true;
    
    results['overall'] = {
      'success': overallSuccess,
      'timestamp': DateTime.now().toIso8601String(),
      'aiServerUrl': ApiConstants.aiBaseUrl,
    };
    
    developer.log(
      overallSuccess ? '✅ Network diagnostic completed successfully' : '❌ Network diagnostic found issues',
      name: 'NETWORK_DIAGNOSTIC'
    );
    
    return results;
  }
}