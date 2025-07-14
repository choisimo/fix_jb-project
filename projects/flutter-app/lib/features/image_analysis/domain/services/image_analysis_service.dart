import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import '../models/image_analysis_result.dart';
import '../../../../core/services/webhook_service.dart';
import 'dart:developer' as developer;

class ImageAnalysisService {
  final Dio _dio;
  final WebhookService? _webhookService;
  final _uuid = const Uuid();
  
  ImageAnalysisService(this._dio, {WebhookService? webhookService}) 
      : _webhookService = webhookService;
  
  Future<OCRResult> performOCR(File imageFile) async {
    final imageId = _uuid.v4();
    
    try {
      // 웹훅 - OCR 시작 알림
      await _notifyAnalysisStarted(imageFile, imageId, 'ocr');
      
      // 이미지 파일 검증
      if (!await imageFile.exists()) {
        throw Exception('Image file does not exist');
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
      
      // API 호출 - 완전한 URL 직접 사용
      final response = await _dio.post(
        'http://localhost:8085/api/v1/ai/analyze/image',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );
      
      if (response.statusCode == 200) {
        final result = OCRResult.fromJson(response.data);
        
        // 웹훅 - OCR 완료 알림
        await _notifyAnalysisCompleted(imageId, {
          'type': 'ocr',
          'result': response.data,
        });
        
        return result;
      } else {
        await _notifyAnalysisFailed(imageId, 'OCR failed: ${response.statusCode}');
        throw Exception('OCR failed: ${response.statusCode}');
      }
    } on DioException catch (e) {
      await _notifyAnalysisFailed(imageId, 'Network error during OCR: ${e.message}');
      throw Exception('Network error during OCR: ${e.message}');
    } catch (e) {
      await _notifyAnalysisFailed(imageId, 'OCR error: $e');
      throw Exception('OCR error: $e');
    }
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
      
      print('📤 Sending comprehensive analysis request to: http://localhost:8085/api/v1/ai/analyze/image');
      print('🌐 Using direct URL construction');
      developer.log('📤 Sending comprehensive analysis request...', name: 'IMAGE_ANALYSIS');
      
      // 통합 AI 분석 API 호출 - 완전한 URL 직접 사용
      final response = await _dio.post(
        'http://localhost:8085/api/v1/ai/analyze/image',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
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
