import 'dart:io';
import 'package:dio/dio.dart';
import 'package:image/image.dart' as img;
import '../models/image_analysis_result.dart';

class ImageAnalysisService {
  final Dio _dio;
  
  ImageAnalysisService(this._dio);
  
  Future<OCRResult> performOCR(File imageFile) async {
    try {
      // Prepare image for OCR
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);
      
      if (image == null) {
        throw Exception('Failed to decode image');
      }
      
      // Create form data
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: 'image.jpg',
        ),
        'language': 'ko+en', // Korean + English
        'detect_orientation': true,
      });
      
      // Call OCR API
      final response = await _dio.post(
        '/api/v1/ai/ocr',
        data: formData,
      );
      
      if (response.statusCode == 200) {
        return OCRResult.fromJson(response.data);
      } else {
        throw Exception('OCR failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('OCR error: $e');
    }
  }
  
  Future<AIAnalysisResult> performAIAnalysis(
    File imageFile, {
    String analysisType = 'general',
  }) async {
    try {
      // Create form data
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: 'image.jpg',
        ),
        'analysis_type': analysisType,
        'extract_fields': true,
      });
      
      // Call AI analysis API
      final response = await _dio.post(
        '/api/v1/ai/analyze',
        data: formData,
      );
      
      if (response.statusCode == 200) {
        return AIAnalysisResult.fromJson(response.data);
      } else {
        throw Exception('AI analysis failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('AI analysis error: $e');
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
