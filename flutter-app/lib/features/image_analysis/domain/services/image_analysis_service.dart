import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../models/image_analysis_result.dart';

class ImageAnalysisService {
  final Dio _dio;
  
  ImageAnalysisService(this._dio);
  
  Future<OCRResult> performOCR(File imageFile) async {
    try {
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
      
      // API 호출
      final response = await _dio.post(
        '/api/v1/ai/ocr',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );
      
      if (response.statusCode == 200) {
        return OCRResult.fromJson(response.data);
      } else {
        throw Exception('OCR failed: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error during OCR: ${e.message}');
    } catch (e) {
      throw Exception('OCR error: $e');
    }
  }
  
  Future<ComprehensiveAnalysisResult> performComprehensiveAnalysis(File imageFile) async {
    try {
      // 이미지 파일 검증
      if (!await imageFile.exists()) {
        throw Exception('Image file does not exist');
      }
      
      // 이미지 크기 최적화
      final optimizedFile = await _optimizeImageForUpload(imageFile);
      
      // Form data 생성
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          optimizedFile.path,
          filename: path.basename(optimizedFile.path),
        ),
      });
      
      // 통합 AI 분석 API 호출
      final response = await _dio.post(
        '/ai/analyze/image',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );
      
      if (response.statusCode == 200) {
        return ComprehensiveAnalysisResult.fromJson(response.data);
      } else {
        throw Exception('Comprehensive analysis failed: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error during comprehensive analysis: ${e.message}');
    } catch (e) {
      throw Exception('Comprehensive analysis error: $e');
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
      
      // 임시 파일로 저장
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
      
      // 임시 파일로 저장
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
  
  // 임시 파일 정리
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
