import 'dart:io';
import 'dart:typed_data';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:uuid/uuid.dart';
import '../../domain/models/ocr_result.dart';

class GoogleMLKitOcrService {
  static final GoogleMLKitOcrService _instance = GoogleMLKitOcrService._internal();
  factory GoogleMLKitOcrService() => _instance;
  GoogleMLKitOcrService._internal();

  late final TextRecognizer _textRecognizer;
  late final TextRecognizer _koreanTextRecognizer;
  bool _isInitialized = false;

  /// OCR 서비스 초기화
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // 일반 텍스트 인식기 (라틴 문자)
      _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      
      // 한국어 텍스트 인식기
      _koreanTextRecognizer = TextRecognizer(script: TextRecognitionScript.korean);
      
      _isInitialized = true;
      print('✅ GoogleMLKitOcrService 초기화 완료');
    } catch (e) {
      print('❌ GoogleMLKitOcrService 초기화 실패: $e');
      rethrow;
    }
  }

  /// 이미지 파일에서 텍스트 추출 (빠른 온디바이스 처리)
  Future<OcrResult> extractTextFromFile(File imageFile, {OcrConfig? config}) async {
    if (!_isInitialized) await initialize();

    final stopwatch = Stopwatch()..start();
    final resultId = const Uuid().v4();
    
    try {
      final inputImage = InputImage.fromFile(imageFile);
      return await _processImage(inputImage, resultId, stopwatch, config);
    } catch (e) {
      stopwatch.stop();
      return OcrResult(
        id: resultId,
        engine: OcrEngine.googleMLKit,
        status: OcrStatus.failed,
        extractedText: '',
        confidence: 0.0,
        errorMessage: e.toString(),
        processedAt: DateTime.now(),
        processingTimeMs: stopwatch.elapsedMilliseconds,
      );
    }
  }

  /// 바이트 데이터에서 텍스트 추출
  Future<OcrResult> extractTextFromBytes(Uint8List imageBytes, {OcrConfig? config}) async {
    if (!_isInitialized) await initialize();

    final stopwatch = Stopwatch()..start();
    final resultId = const Uuid().v4();
    
    try {
      final inputImage = InputImage.fromBytes(
        bytes: imageBytes,
        metadata: InputImageMetadata(
          size: Size(1000, 1000), // 기본 크기 설정
          rotation: InputImageRotation.rotation0deg,
          format: InputImageFormat.nv21,
          bytesPerRow: 1000,
        ),
      );
      return await _processImage(inputImage, resultId, stopwatch, config);
    } catch (e) {
      stopwatch.stop();
      return OcrResult(
        id: resultId,
        engine: OcrEngine.googleMLKit,
        status: OcrStatus.failed,
        extractedText: '',
        confidence: 0.0,
        errorMessage: e.toString(),
        processedAt: DateTime.now(),
        processingTimeMs: stopwatch.elapsedMilliseconds,
      );
    }
  }

  /// 실시간 카메라 이미지에서 텍스트 추출
  Future<OcrResult> extractTextFromCameraImage(InputImage inputImage, {OcrConfig? config}) async {
    if (!_isInitialized) await initialize();

    final stopwatch = Stopwatch()..start();
    final resultId = const Uuid().v4();
    
    return await _processImage(inputImage, resultId, stopwatch, config);
  }

  /// 이미지 처리 및 OCR 수행
  Future<OcrResult> _processImage(
    InputImage inputImage, 
    String resultId, 
    Stopwatch stopwatch, 
    OcrConfig? config,
  ) async {
    try {
      // 한국어 우선 처리
      RecognizedText recognizedText = await _koreanTextRecognizer.processImage(inputImage);
      
      // 한국어로 인식된 텍스트가 부족하면 라틴 문자 인식기로 재시도
      if (recognizedText.text.isEmpty || recognizedText.text.length < 5) {
        final latinText = await _textRecognizer.processImage(inputImage);
        if (latinText.text.length > recognizedText.text.length) {
          recognizedText = latinText;
        }
      }

      stopwatch.stop();

      final textBlocks = recognizedText.blocks.map((block) {
        final boundingBox = block.boundingBox;
        return TextBlock(
          text: block.text,
          confidence: _calculateBlockConfidence(block),
          boundingBox: [
            Point(x: boundingBox.left.toDouble(), y: boundingBox.top.toDouble()),
            Point(x: boundingBox.right.toDouble(), y: boundingBox.top.toDouble()),
            Point(x: boundingBox.right.toDouble(), y: boundingBox.bottom.toDouble()),
            Point(x: boundingBox.left.toDouble(), y: boundingBox.bottom.toDouble()),
          ],
          language: _detectLanguage(block.text),
          metadata: {
            'lineCount': block.lines.length,
            'elementCount': block.lines.expand((line) => line.elements).length,
          },
        );
      }).toList();

      final overallConfidence = _calculateOverallConfidence(recognizedText);
      final confidenceThreshold = config?.confidenceThreshold ?? 0.5;

      return OcrResult(
        id: resultId,
        engine: OcrEngine.googleMLKit,
        status: overallConfidence >= confidenceThreshold ? OcrStatus.success : OcrStatus.partial,
        extractedText: recognizedText.text,
        confidence: overallConfidence,
        textBlocks: textBlocks,
        language: _detectLanguage(recognizedText.text),
        metadata: {
          'blockCount': recognizedText.blocks.length,
          'lineCount': recognizedText.blocks.expand((b) => b.lines).length,
          'elementCount': recognizedText.blocks.expand((b) => b.lines).expand((l) => l.elements).length,
          'processingEngine': 'google_ml_kit',
          'imageSize': inputImage.metadata?.size.toString(),
        },
        processedAt: DateTime.now(),
        processingTimeMs: stopwatch.elapsedMilliseconds,
      );

    } catch (e) {
      stopwatch.stop();
      return OcrResult(
        id: resultId,
        engine: OcrEngine.googleMLKit,
        status: OcrStatus.failed,
        extractedText: '',
        confidence: 0.0,
        errorMessage: e.toString(),
        processedAt: DateTime.now(),
        processingTimeMs: stopwatch.elapsedMilliseconds,
      );
    }
  }

  /// 블록별 신뢰도 계산 (휴리스틱)
  double _calculateBlockConfidence(TextBlock block) {
    // ML Kit는 직접적인 신뢰도를 제공하지 않으므로 휴리스틱 사용
    final textLength = block.text.length;
    final lineCount = block.lines.length;
    
    if (textLength == 0) return 0.0;
    if (textLength >= 20 && lineCount >= 2) return 0.9;
    if (textLength >= 10) return 0.8;
    if (textLength >= 5) return 0.7;
    return 0.6;
  }

  /// 전체 신뢰도 계산
  double _calculateOverallConfidence(RecognizedText recognizedText) {
    if (recognizedText.blocks.isEmpty) return 0.0;
    
    final totalBlocks = recognizedText.blocks.length;
    final totalText = recognizedText.text.length;
    
    if (totalText == 0) return 0.0;
    if (totalText >= 50 && totalBlocks >= 3) return 0.9;
    if (totalText >= 20 && totalBlocks >= 2) return 0.8;
    if (totalText >= 10) return 0.7;
    return 0.6;
  }

  /// 언어 감지 (간단한 휴리스틱)
  String? _detectLanguage(String text) {
    if (text.isEmpty) return null;
    
    // 한글 문자 패턴 확인
    final koreanPattern = RegExp(r'[ㄱ-ㅎㅏ-ㅣ가-힣]');
    final koreanMatches = koreanPattern.allMatches(text).length;
    
    // 영문 문자 패턴 확인
    final englishPattern = RegExp(r'[a-zA-Z]');
    final englishMatches = englishPattern.allMatches(text).length;
    
    if (koreanMatches > englishMatches) return 'ko';
    if (englishMatches > 0) return 'en';
    return null;
  }

  /// 서비스 해제
  Future<void> dispose() async {
    if (_isInitialized) {
      await _textRecognizer.close();
      await _koreanTextRecognizer.close();
      _isInitialized = false;
      print('✅ GoogleMLKitOcrService 해제 완료');
    }
  }
}