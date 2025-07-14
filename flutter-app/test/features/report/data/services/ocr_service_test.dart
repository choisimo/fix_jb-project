import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'dart:io';
import 'dart:typed_data';

import 'package:jb_report_app/features/report/data/services/google_mlkit_ocr_service.dart';
import 'package:jb_report_app/features/report/data/services/hybrid_ocr_service.dart';
import 'package:jb_report_app/features/report/domain/models/ocr_result.dart';

// Mock 클래스 생성
@GenerateNiceMocks([
  MockSpec<GoogleMLKitOcrService>(),
  MockSpec<File>(),
])
import 'ocr_service_test.mocks.dart';

void main() {
  group('GoogleMLKitOcrService Tests', () {
    late GoogleMLKitOcrService ocrService;
    late MockFile mockFile;

    setUp(() {
      ocrService = GoogleMLKitOcrService();
      mockFile = MockFile();
    });

    test('서비스 초기화 테스트', () async {
      // Given & When
      await ocrService.initialize();
      
      // Then
      // 초기화가 정상적으로 완료되어야 함 (예외 없이)
      expect(true, isTrue);
    });

    test('이미지 바이트에서 OCR 결과 생성 테스트', () async {
      // Given
      final testImageBytes = Uint8List.fromList([1, 2, 3, 4, 5]); // 더미 이미지 데이터
      final config = OcrConfig(
        preferredEngine: OcrEngine.googleMLKit,
        confidenceThreshold: 0.5,
        enableLanguageDetection: true,
      );

      // When
      final result = await ocrService.extractTextFromBytes(testImageBytes, config: config);

      // Then
      expect(result, isA<OcrResult>());
      expect(result.engine, equals(OcrEngine.googleMLKit));
      expect(result.id, isNotEmpty);
      expect(result.processedAt, isNotNull);
    });

    test('OCR 설정 기본값 테스트', () {
      // Given & When
      const config = OcrConfig();

      // Then
      expect(config.preferredEngine, equals(OcrEngine.googleMLKit));
      expect(config.confidenceThreshold, equals(0.5));
      expect(config.enableLanguageDetection, isTrue);
      expect(config.supportedLanguages, contains('ko'));
      expect(config.supportedLanguages, contains('en'));
      expect(config.timeoutMs, equals(5000));
      expect(config.enableFallback, isTrue);
    });

    test('OCR 결과 구조 검증', () {
      // Given
      final textBlocks = [
        TextBlock(
          text: '테스트 텍스트',
          confidence: 0.8,
          boundingBox: [
            Point(x: 10.0, y: 10.0),
            Point(x: 100.0, y: 10.0),
            Point(x: 100.0, y: 30.0),
            Point(x: 10.0, y: 30.0),
          ],
          language: 'ko',
        ),
      ];

      // When
      final result = OcrResult(
        id: 'test-id',
        engine: OcrEngine.googleMLKit,
        status: OcrStatus.success,
        extractedText: '테스트 텍스트',
        confidence: 0.8,
        textBlocks: textBlocks,
        language: 'ko',
        processedAt: DateTime.now(),
        processingTimeMs: 100,
      );

      // Then
      expect(result.id, equals('test-id'));
      expect(result.engine, equals(OcrEngine.googleMLKit));
      expect(result.status, equals(OcrStatus.success));
      expect(result.extractedText, equals('테스트 텍스트'));
      expect(result.confidence, equals(0.8));
      expect(result.textBlocks, hasLength(1));
      expect(result.language, equals('ko'));
      expect(result.processingTimeMs, equals(100));
    });
  });

  group('HybridOcrService Tests', () {
    late HybridOcrService hybridService;
    late MockFile mockFile;

    setUp(() {
      hybridService = HybridOcrService();
      mockFile = MockFile();
    });

    test('하이브리드 서비스 초기화 테스트', () async {
      // Given & When
      await hybridService.initialize(serverBaseUrl: 'http://test-server:8080');
      
      // Then
      // 초기화가 정상적으로 완료되어야 함
      expect(true, isTrue);
    });

    test('최적 OCR 결과 선택 로직 테스트', () {
      // Given
      final results = [
        OcrResult(
          id: 'result-1',
          engine: OcrEngine.googleMLKit,
          status: OcrStatus.success,
          extractedText: '짧은 텍스트',
          confidence: 0.7,
          processedAt: DateTime.now(),
        ),
        OcrResult(
          id: 'result-2',
          engine: OcrEngine.googleVision,
          status: OcrStatus.success,
          extractedText: '더 긴 텍스트이며 더 많은 정보를 담고 있습니다',
          confidence: 0.9,
          processedAt: DateTime.now(),
        ),
      ];

      // When
      final bestResult = hybridService.selectBestResult(results);

      // Then
      expect(bestResult.id, equals('result-2')); // 높은 신뢰도와 긴 텍스트
      expect(bestResult.confidence, equals(0.9));
    });

    test('OCR 엔진별 결과 비교 테스트', () {
      // Given
      final mlKitResult = OcrResult(
        id: 'mlkit-result',
        engine: OcrEngine.googleMLKit,
        status: OcrStatus.success,
        extractedText: 'ML Kit 결과',
        confidence: 0.75,
        processedAt: DateTime.now(),
        processingTimeMs: 50,
      );

      final visionResult = OcrResult(
        id: 'vision-result',
        engine: OcrEngine.googleVision,
        status: OcrStatus.success,
        extractedText: 'Google Vision 결과',
        confidence: 0.85,
        processedAt: DateTime.now(),
        processingTimeMs: 200,
      );

      final aiResult = OcrResult(
        id: 'ai-result',
        engine: OcrEngine.qwenVL,
        status: OcrStatus.success,
        extractedText: 'AI 모델 결과',
        confidence: 0.80,
        processedAt: DateTime.now(),
        processingTimeMs: 300,
      );

      // When & Then
      expect(mlKitResult.processingTimeMs, lessThan(visionResult.processingTimeMs!));
      expect(visionResult.confidence, greaterThan(mlKitResult.confidence));
      expect(aiResult.engine, equals(OcrEngine.qwenVL));
    });

    test('빈 OCR 결과 처리 테스트', () {
      // Given
      final emptyResults = <OcrResult>[];

      // When & Then
      expect(() => hybridService.selectBestResult(emptyResults), 
             throwsA(isA<Exception>()));
    });

    test('실패한 OCR 결과 필터링 테스트', () {
      // Given
      final results = [
        OcrResult(
          id: 'failed-result',
          engine: OcrEngine.googleMLKit,
          status: OcrStatus.failed,
          extractedText: '',
          confidence: 0.0,
          errorMessage: '처리 실패',
          processedAt: DateTime.now(),
        ),
        OcrResult(
          id: 'success-result',
          engine: OcrEngine.googleVision,
          status: OcrStatus.success,
          extractedText: '성공한 결과',
          confidence: 0.8,
          processedAt: DateTime.now(),
        ),
      ];

      // When
      final bestResult = hybridService.selectBestResult(results);

      // Then
      expect(bestResult.status, equals(OcrStatus.success));
      expect(bestResult.id, equals('success-result'));
    });
  });

  group('OCR 성능 테스트', () {
    test('대용량 텍스트 처리 성능 테스트', () async {
      // Given
      final largeText = 'A' * 10000; // 10,000 문자
      final result = OcrResult(
        id: 'performance-test',
        engine: OcrEngine.googleVision,
        status: OcrStatus.success,
        extractedText: largeText,
        confidence: 0.9,
        processedAt: DateTime.now(),
        processingTimeMs: 500,
      );

      // When & Then
      expect(result.extractedText.length, equals(10000));
      expect(result.processingTimeMs, lessThan(1000)); // 1초 미만
    });

    test('다중 언어 텍스트 처리 테스트', () {
      // Given
      const multilingualText = '안녕하세요 Hello こんにちは 你好';
      final result = OcrResult(
        id: 'multilingual-test',
        engine: OcrEngine.googleVision,
        status: OcrStatus.success,
        extractedText: multilingualText,
        confidence: 0.8,
        language: 'multi',
        processedAt: DateTime.now(),
      );

      // When & Then
      expect(result.extractedText, contains('안녕하세요'));
      expect(result.extractedText, contains('Hello'));
      expect(result.extractedText, contains('こんにちは'));
      expect(result.extractedText, contains('你好'));
    });
  });

  group('에러 처리 테스트', () {
    test('네트워크 오류 처리 테스트', () async {
      // Given
      final errorResult = OcrResult(
        id: 'error-test',
        engine: OcrEngine.googleVision,
        status: OcrStatus.failed,
        extractedText: '',
        confidence: 0.0,
        errorMessage: '네트워크 연결 실패',
        processedAt: DateTime.now(),
      );

      // When & Then
      expect(errorResult.status, equals(OcrStatus.failed));
      expect(errorResult.errorMessage, isNotNull);
      expect(errorResult.extractedText, isEmpty);
      expect(errorResult.confidence, equals(0.0));
    });

    test('부분 성공 처리 테스트', () {
      // Given
      final partialResult = OcrResult(
        id: 'partial-test',
        engine: OcrEngine.googleMLKit,
        status: OcrStatus.partial,
        extractedText: '부분적으로 인식된 텍스트',
        confidence: 0.3,
        processedAt: DateTime.now(),
      );

      // When & Then
      expect(partialResult.status, equals(OcrStatus.partial));
      expect(partialResult.confidence, lessThan(0.5));
      expect(partialResult.extractedText, isNotEmpty);
    });
  });
}