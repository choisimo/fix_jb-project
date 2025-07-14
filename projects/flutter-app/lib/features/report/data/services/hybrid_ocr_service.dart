import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'google_mlkit_ocr_service.dart';
import '../../domain/models/ocr_result.dart';

class HybridOcrService {
  static final HybridOcrService _instance = HybridOcrService._internal();
  factory HybridOcrService() => _instance;
  HybridOcrService._internal();

  final GoogleMLKitOcrService _mlKitService = GoogleMLKitOcrService();
  final Dio _dio = Dio();
  
  bool _isInitialized = false;
  late String _serverBaseUrl;

  /// 하이브리드 OCR 서비스 초기화
  Future<void> initialize({String serverBaseUrl = 'http://localhost:8080'}) async {
    if (_isInitialized) return;

    _serverBaseUrl = serverBaseUrl;
    await _mlKitService.initialize();
    _isInitialized = true;
    
    print('✅ HybridOcrService 초기화 완료');
  }

  /// 스마트 OCR 처리 - 이미지 특성에 따라 최적의 엔진 선택
  Future<List<OcrResult>> extractTextSmart(
    File imageFile, {
    OcrConfig? config,
    bool enableParallel = true,
    bool enableFallback = true,
  }) async {
    if (!_isInitialized) throw Exception('HybridOcrService not initialized');

    final results = <OcrResult>[];
    
    try {
      // 1단계: 이미지 분석 및 전략 결정
      final strategy = await _determineOcrStrategy(imageFile, config);
      
      if (enableParallel && strategy.useParallelProcessing) {
        // 병렬 처리: ML Kit + 서버 OCR 동시 실행
        results.addAll(await _processParallel(imageFile, config));
      } else {
        // 순차 처리: 빠른 엔진 우선, 필요 시 정확한 엔진으로 폴백
        results.addAll(await _processSequential(imageFile, config, strategy, enableFallback));
      }

      return results;
    } catch (e) {
      print('❌ HybridOcrService 처리 실패: $e');
      
      // 긴급 폴백: ML Kit만 사용
      try {
        final mlKitResult = await _mlKitService.extractTextFromFile(imageFile, config: config);
        return [mlKitResult];
      } catch (fallbackError) {
        print('❌ 폴백 처리도 실패: $fallbackError');
        rethrow;
      }
    }
  }

  /// 실시간 OCR (ML Kit만 사용 - 빠른 처리)
  Future<OcrResult> extractTextRealtime(InputImage inputImage, {OcrConfig? config}) async {
    if (!_isInitialized) throw Exception('HybridOcrService not initialized');
    return await _mlKitService.extractTextFromCameraImage(inputImage, config: config);
  }

  /// 병렬 OCR 처리 (ML Kit + 서버)
  Future<List<OcrResult>> _processParallel(File imageFile, OcrConfig? config) async {
    final futures = <Future<OcrResult>>[];
    
    // ML Kit 처리 (빠름)
    futures.add(_mlKitService.extractTextFromFile(imageFile, config: config));
    
    // 서버 OCR 처리 (정확함)
    futures.add(_processServerOcr(imageFile, config));
    
    try {
      final results = await Future.wait(futures, eagerError: false);
      return results.where((result) => result.status != OcrStatus.failed).toList();
    } catch (e) {
      print('⚠️ 병렬 처리 중 일부 실패: $e');
      // 성공한 결과만 반환
      final completedResults = <OcrResult>[];
      for (final future in futures) {
        try {
          final result = await future;
          if (result.status != OcrStatus.failed) {
            completedResults.add(result);
          }
        } catch (_) {
          // 실패한 future는 무시
        }
      }
      return completedResults;
    }
  }

  /// 순차 OCR 처리 (전략 기반)
  Future<List<OcrResult>> _processSequential(
    File imageFile, 
    OcrConfig? config, 
    OcrStrategy strategy,
    bool enableFallback,
  ) async {
    final results = <OcrResult>[];
    
    if (strategy.primaryEngine == OcrEngine.googleMLKit) {
      // ML Kit 우선 처리
      final mlKitResult = await _mlKitService.extractTextFromFile(imageFile, config: config);
      results.add(mlKitResult);
      
      // 결과가 불만족스럽고 폴백이 활성화된 경우 서버 OCR 실행
      if (enableFallback && _shouldUseFallback(mlKitResult, strategy)) {
        try {
          final serverResult = await _processServerOcr(imageFile, config);
          results.add(serverResult);
        } catch (e) {
          print('⚠️ 서버 OCR 폴백 실패: $e');
        }
      }
    } else {
      // 서버 OCR 우선 처리
      try {
        final serverResult = await _processServerOcr(imageFile, config);
        results.add(serverResult);
      } catch (e) {
        print('⚠️ 서버 OCR 실패, ML Kit으로 폴백: $e');
        if (enableFallback) {
          final mlKitResult = await _mlKitService.extractTextFromFile(imageFile, config: config);
          results.add(mlKitResult);
        }
      }
    }
    
    return results;
  }

  /// 서버 사이드 OCR 처리 (Google Vision 또는 AI 모델)
  Future<OcrResult> _processServerOcr(File imageFile, OcrConfig? config) async {
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(imageFile.path),
        'engine': config?.preferredEngine.name ?? 'auto',
        'config': config?.toJson(),
      });

      final response = await _dio.post(
        '$_serverBaseUrl/api/v1/ocr/extract',
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
          sendTimeout: Duration(milliseconds: config?.timeoutMs ?? 10000),
          receiveTimeout: Duration(milliseconds: config?.timeoutMs ?? 10000),
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        return OcrResult.fromJson(response.data);
      } else {
        throw Exception('서버 OCR 응답 오류: ${response.statusCode}');
      }
    } catch (e) {
      if (e is DioException) {
        throw Exception('서버 OCR 네트워크 오류: ${e.message}');
      }
      rethrow;
    }
  }

  /// OCR 전략 결정
  Future<OcrStrategy> _determineOcrStrategy(File imageFile, OcrConfig? config) async {
    try {
      // 이미지 기본 정보 분석
      final fileSize = await imageFile.length();
      final filename = imageFile.path.toLowerCase();
      
      // 파일 크기 기반 판단
      if (fileSize > 5 * 1024 * 1024) { // 5MB 이상
        return OcrStrategy(
          primaryEngine: OcrEngine.googleVision,
          useParallelProcessing: false,
          confidenceThreshold: 0.8,
          reason: '대용량 이미지 - 서버 처리 권장',
        );
      }
      
      // 파일 확장자 기반 판단
      if (filename.endsWith('.pdf') || filename.contains('document')) {
        return OcrStrategy(
          primaryEngine: OcrEngine.googleVision,
          useParallelProcessing: true,
          confidenceThreshold: 0.9,
          reason: '문서 이미지 - 높은 정확도 필요',
        );
      }
      
      // 일반적인 경우: ML Kit 우선
      return OcrStrategy(
        primaryEngine: OcrEngine.googleMLKit,
        useParallelProcessing: fileSize < 2 * 1024 * 1024, // 2MB 미만일 때 병렬
        confidenceThreshold: 0.7,
        reason: '일반 이미지 - 빠른 처리 우선',
      );
    } catch (e) {
      // 분석 실패 시 기본 전략
      return OcrStrategy(
        primaryEngine: OcrEngine.googleMLKit,
        useParallelProcessing: false,
        confidenceThreshold: 0.7,
        reason: '기본 전략 (분석 실패)',
      );
    }
  }

  /// 폴백 사용 여부 결정
  bool _shouldUseFallback(OcrResult result, OcrStrategy strategy) {
    // 신뢰도가 임계값보다 낮거나 텍스트가 너무 짧은 경우
    return result.confidence < strategy.confidenceThreshold ||
           result.extractedText.length < 10 ||
           result.status == OcrStatus.partial;
  }

  /// 최적의 OCR 결과 선택
  OcrResult selectBestResult(List<OcrResult> results) {
    if (results.isEmpty) {
      throw Exception('OCR 결과가 없습니다');
    }
    
    if (results.length == 1) {
      return results.first;
    }
    
    // 성공한 결과만 필터링
    final successResults = results.where((r) => r.status == OcrStatus.success).toList();
    if (successResults.isEmpty) {
      // 성공한 결과가 없으면 신뢰도가 가장 높은 결과 반환
      results.sort((a, b) => b.confidence.compareTo(a.confidence));
      return results.first;
    }
    
    // 성공한 결과 중에서 신뢰도와 텍스트 길이를 종합적으로 고려
    successResults.sort((a, b) {
      final scoreA = a.confidence * 0.7 + (a.extractedText.length / 100) * 0.3;
      final scoreB = b.confidence * 0.7 + (b.extractedText.length / 100) * 0.3;
      return scoreB.compareTo(scoreA);
    });
    
    return successResults.first;
  }

  /// 서비스 해제
  Future<void> dispose() async {
    await _mlKitService.dispose();
    _dio.close();
    _isInitialized = false;
    print('✅ HybridOcrService 해제 완료');
  }
}

/// OCR 처리 전략
class OcrStrategy {
  final OcrEngine primaryEngine;
  final bool useParallelProcessing;
  final double confidenceThreshold;
  final String reason;

  OcrStrategy({
    required this.primaryEngine,
    required this.useParallelProcessing,
    required this.confidenceThreshold,
    required this.reason,
  });
}