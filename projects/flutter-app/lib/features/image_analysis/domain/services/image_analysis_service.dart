import 'dart:io';
import 'dart:typed_data';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import '../models/image_analysis_result.dart';
import '../../../../core/services/webhook_service.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/utils/token_manager.dart';
import '../../../../core/constants/api_constants.dart';
import 'dart:developer' as developer;

class ImageAnalysisService {
  final Dio _dio;
  final WebhookService? _webhookService;
  final _uuid = const Uuid();
  
  // 재시도 설정
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 1);
  
  // 서버 상태 캐싱
  static bool? _isServerAvailable;
  static DateTime? _lastServerCheck;
  
  ImageAnalysisService(this._dio, {WebhookService? webhookService}) 
      : _webhookService = webhookService;
  
  Future<OCRResult> performOCR(File imageFile) async {
    final imageId = _uuid.v4();
    
    // 서버 상태 확인
    final isServerAvailable = await checkServerHealth();
    if (!isServerAvailable) {
      final errorMessage = 'AI 서버에 연결할 수 없습니다. 서버가 실행 중인지 확인하세요 (포트: 8081)';
      developer.log('❌ $errorMessage', name: 'IMAGE_ANALYSIS');
      await _notifyAnalysisFailed(imageId, errorMessage);
      throw Exception(errorMessage);
    }
    
    // 재시도 로직
    int attempts = 0;
    DioException? lastDioError;
    
    while (attempts < _maxRetries) {
      try {
        // 첫 시도가 아니면 지연
        if (attempts > 0) {
          developer.log('🔄 OCR 분석 재시도 중... (${attempts+1}/$_maxRetries)', name: 'IMAGE_ANALYSIS');
          await Future.delayed(_retryDelay * attempts);
        }
        
        attempts++;
        
        // 웹훅 - OCR 시작 알림
        await _notifyAnalysisStarted(imageFile, imageId, 'ocr');
        
        // 이미지 파일 검증
        if (!await imageFile.exists()) {
          throw Exception('이미지 파일이 존재하지 않습니다');
        }
        
        // 이미지 처리 (필요시)
        final processedFile = await _preprocessImage(imageFile);
        
        // Form data 생성 - MultipartFile.fromFile 사용
        final formData = FormData.fromMap({
          'image': await MultipartFile.fromFile(
            processedFile.path,
            filename: path.basename(processedFile.path),
          ),
          'language': 'ko+en',
          'detect_orientation': true,
        });
        
        // 인증 토큰 가져오기
        final token = await TokenManager.getAccessToken();
        
        // API 호출 - AI 서버 URL 사용 (후행 슬래시 포함)
        final response = await _dio.post(
          '${AppConfig.aiServerUrl}/analyze/image/',
          data: formData,
          options: Options(
            headers: {
              'Content-Type': 'multipart/form-data',
              if (token != null) 'Authorization': 'Bearer $token',
            },
            sendTimeout: const Duration(seconds: 30),  // 타임아웃 감소
            receiveTimeout: const Duration(seconds: 30),
          ),
        );
        
        if (response.statusCode == 200) {
          final result = OCRResult.fromJson(response.data);
          
          // 웹훅 - OCR 완료 알림
          await _notifyAnalysisCompleted(imageId, {
            'type': 'ocr',
            'result': response.data,
          });
          
          developer.log('✅ OCR 분석 성공', name: 'IMAGE_ANALYSIS');
          return result;
        } else {
          await _notifyAnalysisFailed(imageId, 'OCR 실패: ${response.statusCode}');
          throw Exception('OCR 실패: ${response.statusCode}');
        }
      } on DioException catch (e) {
        lastDioError = e;
        
        // 즉시 재시도하지 않아야 하는 오류 (인증 오류 등)
        if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
          String errorMessage = '이미지 분석 서버 인증 오류 (${e.response?.statusCode}) - 로그인이 필요하거나 토큰이 만료되었을 수 있습니다';
          developer.log('❌ 인증 오류: ${e.response?.statusCode} - ${e.response?.data}', name: 'IMAGE_ANALYSIS');
          await _notifyAnalysisFailed(imageId, errorMessage);
          throw Exception(errorMessage);
        }
        
        // 마지막 시도였으면 실패로 처리
        if (attempts >= _maxRetries) {
          break;
        }
        
        // 연결 문제는 재시도 로그 출력
        if (e.type == DioExceptionType.connectionTimeout || 
            e.type == DioExceptionType.connectionError) {
          developer.log('⏱️ 연결 문제 발생, 재시도 중... (${attempts}/$_maxRetries): ${e.message}', 
                       name: 'IMAGE_ANALYSIS');
        }
      } catch (e) {
        await _notifyAnalysisFailed(imageId, 'OCR 오류: $e');
        throw Exception('OCR 오류: $e');
      }
    }
    
    // 모든 재시도 실패
    String errorMessage;
    if (lastDioError != null) {
      if (lastDioError.type == DioExceptionType.connectionTimeout) {
        errorMessage = 'OCR 서버 연결 시간 초과 - 서버가 실행 중인지 확인하세요';
      } else if (lastDioError.type == DioExceptionType.connectionError) {
        errorMessage = 'OCR 서버 연결 실패 - 서버 주소(포트: 8081)가 올바른지 확인하세요';
      } else {
        errorMessage = 'OCR 네트워크 오류: ${lastDioError.message ?? "알 수 없는 오류"}';
      }
      developer.log('❌ 재시도 후 최종 실패: $errorMessage', name: 'IMAGE_ANALYSIS');
    } else {
      errorMessage = '알 수 없는 오류로 OCR 분석에 실패했습니다';
    }
    
    await _notifyAnalysisFailed(imageId, errorMessage);
    throw Exception(errorMessage);
  }
  
  // 서버 상태 확인 메서드
  Future<bool> checkServerHealth() async {
    // 최근 30초 이내 확인한 경우 캐시된 상태 반환
    if (_lastServerCheck != null && 
        DateTime.now().difference(_lastServerCheck!) < const Duration(seconds: 30) &&
        _isServerAvailable != null) {
      developer.log('🔄 서버 상태 캐시 사용: ${_isServerAvailable! ? '정상' : '오류'}', name: 'SERVER_HEALTH');
      return _isServerAvailable!;
    }
    
    try {
      final response = await _dio.get(
        '${AppConfig.aiServerUrl}/actuator/health',
        options: Options(
          headers: ApiConstants.baseHeaders,
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );
      
      _lastServerCheck = DateTime.now();
      _isServerAvailable = response.statusCode == 200 && 
                         response.data['status'] == 'UP';
                         
      developer.log('✅ AI 서버 상태 확인: ${_isServerAvailable! ? '정상' : '오류'}', 
                  name: 'SERVER_HEALTH');
      return _isServerAvailable!;
    } catch (e) {
      _lastServerCheck = DateTime.now();
      _isServerAvailable = false;
      developer.log('❌ AI 서버 상태 확인 실패: $e', name: 'SERVER_HEALTH');
      return false;
    }
  }
  
  Future<ComprehensiveAnalysisResult> analyzeImageComprehensive(File imageFile) async {
    return await performComprehensiveAnalysis(imageFile);
  }
  
  Future<ComprehensiveAnalysisResult> performComprehensiveAnalysis(File imageFile) async {
    final imageId = _uuid.v4();
    final startTime = DateTime.now();
    
    try {
      print('🔍 Starting comprehensive analysis for image: $imageId');
      developer.log('🔍 Starting comprehensive analysis for image: $imageId', name: 'IMAGE_ANALYSIS');
      
      // 웹훅 - 분석 시작 알림
      await _notifyAnalysisStarted(imageFile, imageId, 'comprehensive');
      
      // 이미지 파일 검증
      print('📂 Checking if image file exists: ${imageFile.path}');
      if (!await imageFile.exists()) {
        throw Exception('Image file does not exist');
      }
      
      // 파일 크기 검증 (10MB 제한)
      final fileSize = await imageFile.length();
      print('📏 Image file size: ${fileSize} bytes');
      if (fileSize > 10 * 1024 * 1024) {
        throw Exception('Image file size too large (max 10MB)');
      }
      
      // 이미지 크기 최적화
      print('🔧 Optimizing image for upload...');
      final optimizedFile = await _optimizeImageForUpload(imageFile);
      
      // Form data 생성
      print('📦 Creating form data...');
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          optimizedFile.path,
          filename: path.basename(optimizedFile.path),
        ),
      });
      
      print('📤 Sending comprehensive analysis request to: ${AppConfig.aiServerUrl}/analyze/image/');
      print('🌐 Using AI server URL from AppConfig');
      developer.log('📤 Sending comprehensive analysis request...', name: 'IMAGE_ANALYSIS');
      
      // 인증 토큰 가져오기
      final token = await TokenManager.getAccessToken();
      
      // 통합 AI 분석 API 호출 - AI 서버 URL 사용 (후행 슬래시 포함)
      final response = await _dio.post(
        '${AppConfig.aiServerUrl}/analyze/image/', // 후행 슬래시(/) 추가
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
            if (token != null) 'Authorization': 'Bearer $token',
          },
          sendTimeout: const Duration(minutes: 2),
          receiveTimeout: const Duration(minutes: 2),
        ),
      );
      
      if (response.statusCode == 200) {
        final endTime = DateTime.now();
        final processingTime = endTime.difference(startTime).inMilliseconds;
        
        print('✅ Comprehensive analysis completed in ${processingTime}ms');
        print('📋 Raw response data: ${response.data}');
        developer.log('✅ Comprehensive analysis completed in ${processingTime}ms', name: 'IMAGE_ANALYSIS');
        
        try {
          print('🔧 Attempting to parse response data...');
          final result = ComprehensiveAnalysisResult.fromJson(response.data);
          print('✅ Successfully parsed response data');
          
          // 웹훅 - 분석 완료 알림
          await _notifyAnalysisCompleted(imageId, {
            'type': 'comprehensive',
            'result': response.data,
            'processingTimeMs': processingTime,
            'imageId': imageId,
          });
          
          return result;
        } catch (parseError, stackTrace) {
          print('❌ Failed to parse response data: $parseError');
          print('❌ Stack trace: $stackTrace');
          print('❌ Response data type: ${response.data.runtimeType}');
          if (response.data is Map) {
            print('❌ Response data keys: ${(response.data as Map).keys}');
          }
          throw Exception('Failed to parse API response: $parseError');
        }
      } else {
        print('❌ Server returned error: ${response.statusCode} - ${response.statusMessage}');
        await _notifyAnalysisFailed(imageId, 'Comprehensive analysis failed: ${response.statusCode} - ${response.statusMessage}');
        throw Exception('Comprehensive analysis failed: ${response.statusCode} - ${response.statusMessage}');
      }
    } on DioException catch (e) {
      String errorMessage;
      print('❌ DioException details:');
      print('   Type: ${e.type}');
      print('   Message: ${e.message}');
      print('   RequestOptions.uri: ${e.requestOptions.uri}');
      print('   RequestOptions.method: ${e.requestOptions.method}');
      print('   RequestOptions.headers: ${e.requestOptions.headers}');
      print('   Response status: ${e.response?.statusCode}');
      print('   Response data: ${e.response?.data}');
      print('   Error: ${e.error}');
      
      if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.sendTimeout) {
        errorMessage = 'Connection timeout - please check your internet connection';
        print('❌ Connection timeout error: ${e.message}');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Server response timeout - please try again';
        print('❌ Receive timeout error: ${e.message}');
      } else if (e.type == DioExceptionType.unknown) {
        errorMessage = 'Unknown network error - ${e.error?.toString() ?? e.message ?? 'Connection failed'}';
        print('❌ Unknown error details: ${e.error}');
      } else if (e.response?.statusCode == 404) {
        errorMessage = 'Analysis service not found - please check server configuration';
        print('❌ 404 error: ${e.response?.data}');
      } else if (e.response?.statusCode == 413) {
        errorMessage = 'Image file too large';
        print('❌ File too large error: ${e.response?.data}');
      } else if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        errorMessage = '이미지 분석 서버 인증 오류 (${e.response?.statusCode}) - 로그인이 필요하거나 토큰이 만료되었을 수 있습니다';
        developer.log('❌ 인증 오류: ${e.response?.statusCode} - ${e.response?.data}', name: 'IMAGE_ANALYSIS', error: true);
      } else {
        errorMessage = 'Network error: ${e.message ?? 'Unknown error'}';
        print('❌ Network error: ${e.type} - ${e.message}');
        print('❌ Response: ${e.response?.statusCode} - ${e.response?.data}');
      }
      
      developer.log('❌ Network error during comprehensive analysis: ${e.type} - ${e.message}', name: 'IMAGE_ANALYSIS');
      await _notifyAnalysisFailed(imageId, errorMessage);
      throw Exception(errorMessage);
    } catch (e) {
      print('❌ Unexpected error: $e');
      developer.log('❌ Comprehensive analysis error: $e', name: 'IMAGE_ANALYSIS');
      await _notifyAnalysisFailed(imageId, 'Comprehensive analysis error: $e');
      throw Exception('Comprehensive analysis error: $e');
    }
  }
  
  // 웹훅 알림 메서드들
  Future<void> _notifyAnalysisStarted(File imageFile, String imageId, String analysisType) async {
    if (_webhookService == null) return;
    
    try {
      final fileStats = await imageFile.stat();
      final mimeType = _getMimeType(imageFile.path);
      
      await _webhookService!.notifyImageAnalysisStarted(
        imageId: imageId,
        imagePath: imageFile.path,
        fileSize: fileStats.size,
        mimeType: mimeType,
        metadata: {
          'analysisType': analysisType,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      developer.log('⚠️ Failed to send webhook for analysis start: $e', name: 'WEBHOOK');
    }
  }
  
  Future<void> _notifyAnalysisCompleted(String imageId, Map<String, dynamic> result) async {
    if (_webhookService == null) return;
    
    try {
      await _webhookService!.notifyImageAnalysisCompleted(
        imageId: imageId,
        analysisResult: result,
      );
    } catch (e) {
      developer.log('⚠️ Failed to send webhook for analysis completion: $e', name: 'WEBHOOK');
    }
  }
  
  Future<void> _notifyAnalysisFailed(String imageId, String error) async {
    if (_webhookService == null) return;
    
    try {
      await _webhookService!.notifyImageAnalysisFailed(
        imageId: imageId,
        error: error,
      );
    } catch (e) {
      developer.log('⚠️ Failed to send webhook for analysis failure: $e', name: 'WEBHOOK');
    }
  }
  
  String _getMimeType(String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    switch (extension) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.webp':
        return 'image/webp';
      case '.gif':
        return 'image/gif';
      default:
        return 'image/jpeg';
    }
  }
  
  // 이미지 전처리 (OCR 정확도 향상)
  Future<File> _preprocessImage(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      var image = img.decodeImage(bytes);
      
      if (image == null) {
        return imageFile; // 디코딩 실패시 원본 반환
      }
      
      // 이미지 처리: 그레이스케일 변환, 대비 향상
      image = img.grayscale(image);
      image = img.adjustColor(image, contrast: 1.2);
      
      // 처리된 이미지를 파일로 저장
      final tempDir = await getTemporaryDirectory();
      final processedPath = path.join(
        tempDir.path, 
        'processed_${DateTime.now().millisecondsSinceEpoch}.jpg'
      );
      
      final processedFile = File(processedPath);
      await processedFile.writeAsBytes(img.encodeJpg(image, quality: 95));
      
      return processedFile;
    } catch (e) {
      // 전처리 실패시 원본 반환
      return imageFile;
    }
  }
  
  // 이미지 크기 최적화 (업로드 속도 향상)
  Future<File> _optimizeImageForUpload(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      var image = img.decodeImage(bytes);
      
      if (image == null) {
        return imageFile;
      }
      
      // 이미지가 너무 크면 리사이즈
      const maxDimension = 2048;
      if (image.width > maxDimension || image.height > maxDimension) {
        if (image.width > image.height) {
          image = img.copyResize(image, width: maxDimension);
        } else {
          image = img.copyResize(image, height: maxDimension);
        }
      }
      
      // 최적화된 이미지를 파일로 저장
      final tempDir = await getTemporaryDirectory();
      final optimizedPath = path.join(
        tempDir.path,
        'optimized_${DateTime.now().millisecondsSinceEpoch}.jpg'
      );
      
      final optimizedFile = File(optimizedPath);
      await optimizedFile.writeAsBytes(img.encodeJpg(image, quality: 85));
      
      return optimizedFile;
    } catch (e) {
      // 최적화 실패시 원본 반환
      return imageFile;
    }
  }
  
  Future<Map<String, dynamic>> performAIAnalysis(File imageFile, {String analysisType = 'both'}) async {
    // performComprehensiveAnalysis 호출하여 호환성 유지
    final result = await performComprehensiveAnalysis(imageFile);
    return {
      'success': true,
      'result': result,
      'analysisType': analysisType,
    };
  }
  
  // 처리된 파일 정리
  Future<void> cleanupTempFiles() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final files = tempDir.listSync();
      
      for (final file in files) {
        if (file is File && 
            (file.path.contains('processed_') || file.path.contains('optimized_'))) {
          await file.delete();
        }
      }
    } catch (e) {
      // 정리 실패는 무시
    }
  }
  
  // Field extraction logic
  Map<String, dynamic> extractFieldsFromText(String text) {
    final fields = <String, dynamic>{};
    
    // Extract common patterns
    fields.addAll(_extractPersonalInfo(text));
    fields.addAll(_extractDates(text));
    fields.addAll(_extractAmounts(text));
    fields.addAll(_extractAddresses(text));
    
    return fields;
  }
  
  Map<String, dynamic> _extractPersonalInfo(String text) {
    final fields = <String, dynamic>{};
    
    // Name patterns
    final nameRegex = RegExp(r'(?:이름|성명|Name)[\s:]*([가-힣\s]+|[A-Za-z\s]+)');
    final nameMatch = nameRegex.firstMatch(text);
    if (nameMatch != null) {
      fields['name'] = nameMatch.group(1)?.trim();
    }
    
    // Email patterns
    final emailRegex = RegExp(r'[\w\.-]+@[\w\.-]+\.\w+');
    final emailMatch = emailRegex.firstMatch(text);
    if (emailMatch != null) {
      fields['email'] = emailMatch.group(0);
    }
    
    // Phone patterns (Korean)
    final phoneRegex = RegExp(r'(?:010|011|016|017|018|019)-?\d{3,4}-?\d{4}');
    final phoneMatch = phoneRegex.firstMatch(text);
    if (phoneMatch != null) {
      fields['phone'] = phoneMatch.group(0);
    }
    
    // ID number patterns (partial for privacy)
    final idRegex = RegExp(r'\d{6}-[1-4]\d{6}');
    final idMatch = idRegex.firstMatch(text);
    if (idMatch != null) {
      final id = idMatch.group(0)!;
      fields['id_number'] = '${id.substring(0, 8)}******';
    }
    
    return fields;
  }
  
  Map<String, dynamic> _extractDates(String text) {
    final fields = <String, dynamic>{};
    
    // Various date patterns
    final datePatterns = [
      RegExp(r'(\d{4})[-./](\d{1,2})[-./](\d{1,2})'), // YYYY-MM-DD
      RegExp(r'(\d{1,2})[-./](\d{1,2})[-./](\d{4})'), // DD-MM-YYYY
      RegExp(r'(\d{4})년\s*(\d{1,2})월\s*(\d{1,2})일'), // Korean format
    ];
    
    for (final pattern in datePatterns) {
      final matches = pattern.allMatches(text);
      int index = 0;
      for (final match in matches) {
        final key = index == 0 ? 'date' : 'date_$index';
        fields[key] = match.group(0);
        index++;
      }
    }
    
    return fields;
  }
  
  Map<String, dynamic> _extractAmounts(String text) {
    final fields = <String, dynamic>{};
    
    // Amount patterns with Korean won
    final amountPatterns = [
      RegExp(r'(\d{1,3}(?:,\d{3})*(?:\.\d+)?)\s*원'), // Korean won
      RegExp(r'₩\s*(\d{1,3}(?:,\d{3})*(?:\.\d+)?)'), // Won symbol
      RegExp(r'\$\s*(\d{1,3}(?:,\d{3})*(?:\.\d+)?)'), // Dollar
      RegExp(r'(?:금액|총액|Total)[\s:]*(\d{1,3}(?:,\d{3})*(?:\.\d+)?)'), // With label
    ];
    
    for (final pattern in amountPatterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        final amount = match.group(1)?.replaceAll(',', '');
        if (amount != null) {
          fields['amount'] = double.tryParse(amount) ?? amount;
          break;
        }
      }
    }
    
    return fields;
  }
  
  Map<String, dynamic> _extractAddresses(String text) {
    final fields = <String, dynamic>{};
    
    // Korean address patterns
    final addressPatterns = [
      RegExp(r'(?:서울|부산|대구|인천|광주|대전|울산|세종|경기|강원|충북|충남|전북|전남|경북|경남|제주)(?:특별시|광역시|특별자치시|도|특별자치도)?\s+[\s\S]+?(?:구|군)\s+[\s\S]+?(?:로|길)\s*\d+'), // New address system
      RegExp(r'(?:서울|부산|대구|인천|광주|대전|울산|세종|경기|강원|충북|충남|전북|전남|경북|경남|제주)(?:특별시|광역시|특별자치시|도|특별자치도)?\s+[\s\S]+?(?:구|군)\s+[\s\S]+?(?:동|읍|면)\s*\d+'), // Old address system
    ];
    
    for (final pattern in addressPatterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        fields['address'] = match.group(0)?.trim();
        break;
      }
    }
    
    // Postal code
    final postalRegex = RegExp(r'\d{5}');
    final postalMatch = postalRegex.firstMatch(text);
    if (postalMatch != null) {
      fields['postal_code'] = postalMatch.group(0);
    }
    
    return fields;
  }
}
