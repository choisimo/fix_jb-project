import 'dart:io';
import 'package:flutter/foundation.dart';
import 'roboflow_service.dart';
import 'ocr_service.dart';
import 'ai_agent_service.dart';

/// 하이브리드 분석 매니저 - OCR, 객체 감지, AI Agent를 통합 관리
class HybridAnalysisManager {
  static final HybridAnalysisManager _instance = HybridAnalysisManager._internal();
  static HybridAnalysisManager get instance => _instance;
  HybridAnalysisManager._internal();

  final RoboflowService _roboflowService = RoboflowService.instance;
  final OCRService _ocrService = OCRService.instance;
  final AIAgentService _aiAgentService = AIAgentService.instance;

  bool _isInitialized = false;

  /// 하이브리드 분석 시스템 초기화
  Future<void> init() async {
    try {
      debugPrint('🔄 하이브리드 분석 시스템 초기화 중...');
      
      // 모든 서비스 병렬 초기화
      await Future.wait([
        _roboflowService.init(),
        _ocrService.init(),
        _aiAgentService.init(),
      ]);
      
      _isInitialized = true;
      debugPrint('✅ 하이브리드 분석 시스템 초기화 완료');
      
    } catch (e) {
      debugPrint('❌ 하이브리드 분석 시스템 초기화 실패: $e');
      _isInitialized = false;
    }
  }

  /// 통합 이미지 분석 수행
  Future<HybridAnalysisResult> analyzeImage(File imageFile, {
    bool enableOCR = true,
    bool enableObjectDetection = true,
    bool enableAIAgent = true,
    AnalysisMode mode = AnalysisMode.comprehensive,
  }) async {
    if (!_isInitialized) {
      await init();
    }

    final stopwatch = Stopwatch()..start();
    
    try {
      debugPrint('🔍 하이브리드 분석 시작: ${imageFile.path}');
      debugPrint('📋 분석 모드: ${mode.name}');
      debugPrint('🛠️ 활성화된 기능: OCR($enableOCR), 객체감지($enableObjectDetection), AI($enableAIAgent)');

      ObjectDetectionResult? detectionResult;
      OCRResult? ocrResult;
      AIAnalysisResult? aiAnalysisResult;

      // 분석 모드에 따른 병렬/순차 처리
      switch (mode) {
        case AnalysisMode.fast:
          await _performFastAnalysis(
            imageFile,
            enableOCR: enableOCR,
            enableObjectDetection: enableObjectDetection,
          ).then((results) {
            detectionResult = results.$1;
            ocrResult = results.$2;
          });
          break;

        case AnalysisMode.comprehensive:
          await _performComprehensiveAnalysis(
            imageFile,
            enableOCR: enableOCR,
            enableObjectDetection: enableObjectDetection,
            enableAIAgent: enableAIAgent,
          ).then((results) {
            detectionResult = results.$1;
            ocrResult = results.$2;
            aiAnalysisResult = results.$3;
          });
          break;

        case AnalysisMode.sequential:
          final results = await _performSequentialAnalysis(
            imageFile,
            enableOCR: enableOCR,
            enableObjectDetection: enableObjectDetection,
            enableAIAgent: enableAIAgent,
          );
          detectionResult = results.$1;
          ocrResult = results.$2;
          aiAnalysisResult = results.$3;
          break;
      }

      stopwatch.stop();
      
      final result = HybridAnalysisResult(
        imagePath: imageFile.path,
        detectionResult: detectionResult,
        ocrResult: ocrResult,
        aiAnalysisResult: aiAnalysisResult,
        totalProcessingTime: stopwatch.elapsedMilliseconds,
        analysisMode: mode,
        timestamp: DateTime.now(),
      );

      debugPrint('✅ 하이브리드 분석 완료 (${stopwatch.elapsedMilliseconds}ms)');
      debugPrint('📊 분석 결과: ${result.summary}');

      return result;

    } catch (e) {
      stopwatch.stop();
      debugPrint('❌ 하이브리드 분석 오류: $e');
      
      return HybridAnalysisResult(
        imagePath: imageFile.path,
        detectionResult: null,
        ocrResult: null,
        aiAnalysisResult: null,
        totalProcessingTime: stopwatch.elapsedMilliseconds,
        analysisMode: mode,
        timestamp: DateTime.now(),
        error: e.toString(),
      );
    }
  }

  /// 빠른 분석 (OCR + 객체 감지 병렬)
  Future<(ObjectDetectionResult?, OCRResult?)> _performFastAnalysis(
    File imageFile, {
    required bool enableOCR,
    required bool enableObjectDetection,
  }) async {
    final futures = <Future>[];
    
    if (enableObjectDetection) {
      futures.add(_roboflowService.detectObjects(imageFile));
    }
    
    if (enableOCR) {
      futures.add(_ocrService.extractText(imageFile));
    }

    if (futures.isEmpty) {
      return (null, null);
    }

    final results = await Future.wait(futures);
    
    ObjectDetectionResult? detectionResult;
    OCRResult? ocrResult;
    
    int resultIndex = 0;
    if (enableObjectDetection) {
      detectionResult = results[resultIndex++] as ObjectDetectionResult;
    }
    if (enableOCR) {
      ocrResult = results[resultIndex++] as OCRResult;
    }

    return (detectionResult, ocrResult);
  }

  /// 종합 분석 (모든 기능 병렬)
  Future<(ObjectDetectionResult?, OCRResult?, AIAnalysisResult?)> _performComprehensiveAnalysis(
    File imageFile, {
    required bool enableOCR,
    required bool enableObjectDetection,
    required bool enableAIAgent,
  }) async {
    final futures = <Future>[];
    
    if (enableObjectDetection) {
      futures.add(_roboflowService.detectObjects(imageFile));
    }
    
    if (enableOCR) {
      futures.add(_ocrService.extractText(imageFile));
    }

    // 기본 분석 완료 후 AI Agent 분석
    if (futures.isEmpty) {
      return (null, null, null);
    }

    final basicResults = await Future.wait(futures);
    
    ObjectDetectionResult? detectionResult;
    OCRResult? ocrResult;
    
    int resultIndex = 0;
    if (enableObjectDetection) {
      detectionResult = basicResults[resultIndex++] as ObjectDetectionResult;
    }
    if (enableOCR) {
      ocrResult = basicResults[resultIndex++] as OCRResult;
    }

    AIAnalysisResult? aiAnalysisResult;
    if (enableAIAgent) {
      aiAnalysisResult = await _aiAgentService.analyzeImage(
        imageFile: imageFile,
        detectionResult: detectionResult,
        ocrResult: ocrResult,
      );
    }

    return (detectionResult, ocrResult, aiAnalysisResult);
  }

  /// 순차 분석 (단계별 처리)
  Future<(ObjectDetectionResult?, OCRResult?, AIAnalysisResult?)> _performSequentialAnalysis(
    File imageFile, {
    required bool enableOCR,
    required bool enableObjectDetection,
    required bool enableAIAgent,
  }) async {
    ObjectDetectionResult? detectionResult;
    OCRResult? ocrResult;
    AIAnalysisResult? aiAnalysisResult;

    // 1단계: 객체 감지
    if (enableObjectDetection) {
      debugPrint('🔍 1단계: 객체 감지 실행');
      detectionResult = await _roboflowService.detectObjects(imageFile);
    }

    // 2단계: OCR 텍스트 추출
    if (enableOCR) {
      debugPrint('🔤 2단계: OCR 텍스트 추출 실행');
      ocrResult = await _ocrService.extractText(imageFile);
    }

    // 3단계: AI Agent 종합 분석
    if (enableAIAgent) {
      debugPrint('🤖 3단계: AI Agent 종합 분석 실행');
      aiAnalysisResult = await _aiAgentService.analyzeImage(
        imageFile: imageFile,
        detectionResult: detectionResult,
        ocrResult: ocrResult,
      );
    }

    return (detectionResult, ocrResult, aiAnalysisResult);
  }

  /// 분석 설정 최적화 추천
  AnalysisConfiguration getOptimizedConfiguration({
    required String imageType,
    required int imageSize,
    required bool isRealTime,
  }) {
    if (isRealTime) {
      // 실시간 처리 - 빠른 분석 모드
      return AnalysisConfiguration(
        mode: AnalysisMode.fast,
        enableOCR: imageSize < 5 * 1024 * 1024, // 5MB 미만에서만 OCR
        enableObjectDetection: true,
        enableAIAgent: false, // 실시간에서는 AI Agent 비활성화
      );
    } else if (imageType.contains('text') || imageType.contains('sign')) {
      // 텍스트가 많은 이미지 - OCR 중심
      return AnalysisConfiguration(
        mode: AnalysisMode.comprehensive,
        enableOCR: true,
        enableObjectDetection: false,
        enableAIAgent: true,
      );
    } else {
      // 일반 이미지 - 전체 분석
      return AnalysisConfiguration(
        mode: AnalysisMode.comprehensive,
        enableOCR: true,
        enableObjectDetection: true,
        enableAIAgent: true,
      );
    }
  }

  /// 배치 분석 (여러 이미지 동시 처리)
  Future<List<HybridAnalysisResult>> analyzeBatch(
    List<File> imageFiles, {
    int maxConcurrency = 3,
    AnalysisMode mode = AnalysisMode.fast,
  }) async {
    final results = <HybridAnalysisResult>[];
    
    // 동시 처리 수 제한
    for (int i = 0; i < imageFiles.length; i += maxConcurrency) {
      final batch = imageFiles.skip(i).take(maxConcurrency).toList();
      
      final batchFutures = batch.map((file) => analyzeImage(
        file,
        mode: mode,
      ));
      
      final batchResults = await Future.wait(batchFutures);
      results.addAll(batchResults);
      
      debugPrint('📊 배치 분석 진행: ${results.length}/${imageFiles.length}');
    }
    
    return results;
  }

  /// 분석 성능 통계
  AnalysisPerformanceStats getPerformanceStats(List<HybridAnalysisResult> results) {
    if (results.isEmpty) {
      return AnalysisPerformanceStats.empty();
    }

    final totalTime = results.fold(0, (sum, r) => sum + r.totalProcessingTime);
    final successCount = results.where((r) => r.isSuccessful).length;
    
    final ocrCount = results.where((r) => r.ocrResult?.hasText == true).length;
    final detectionCount = results.where((r) => r.detectionResult?.hasDetections == true).length;
    final aiCount = results.where((r) => r.aiAnalysisResult?.isSuccessful == true).length;

    return AnalysisPerformanceStats(
      totalAnalyzed: results.length,
      successfulAnalyses: successCount,
      averageProcessingTime: totalTime / results.length,
      ocrSuccessRate: ocrCount / results.length,
      detectionSuccessRate: detectionCount / results.length,
      aiAnalysisSuccessRate: aiCount / results.length,
    );
  }

  /// 리소스 정리
  void dispose() {
    _roboflowService.dispose();
    _ocrService.dispose();
    _aiAgentService.dispose();
    _isInitialized = false;
    debugPrint('🔄 하이브리드 분석 시스템 종료');
  }
}

/// 분석 모드
enum AnalysisMode {
  fast,         // 빠른 분석 (기본 기능만)
  comprehensive, // 종합 분석 (모든 기능)
  sequential,   // 순차 분석 (단계별)
}

/// 분석 설정
class AnalysisConfiguration {
  final AnalysisMode mode;
  final bool enableOCR;
  final bool enableObjectDetection;
  final bool enableAIAgent;

  AnalysisConfiguration({
    required this.mode,
    required this.enableOCR,
    required this.enableObjectDetection,
    required this.enableAIAgent,
  });
}

/// 하이브리드 분석 결과
class HybridAnalysisResult {
  final String imagePath;
  final ObjectDetectionResult? detectionResult;
  final OCRResult? ocrResult;
  final AIAnalysisResult? aiAnalysisResult;
  final int totalProcessingTime;
  final AnalysisMode analysisMode;
  final DateTime timestamp;
  final String? error;

  HybridAnalysisResult({
    required this.imagePath,
    this.detectionResult,
    this.ocrResult,
    this.aiAnalysisResult,
    required this.totalProcessingTime,
    required this.analysisMode,
    required this.timestamp,
    this.error,
  });

  bool get hasError => error != null;
  bool get isSuccessful => !hasError && (
    detectionResult?.hasDetections == true ||
    ocrResult?.hasText == true ||
    aiAnalysisResult?.isSuccessful == true
  );

  String get summary {
    final parts = <String>[];
    
    if (detectionResult?.hasDetections == true) {
      parts.add('객체 ${detectionResult!.detections.length}개');
    }
    
    if (ocrResult?.hasText == true) {
      parts.add('텍스트 추출됨');
    }
    
    if (aiAnalysisResult?.isSuccessful == true) {
      parts.add('AI 분석완료');
    }
    
    if (hasError) {
      parts.add('오류 발생');
    }
    
    return parts.isNotEmpty ? parts.join(', ') : '분석 결과 없음';
  }

  // 종합 위험도 계산
  int get combinedRiskLevel {
    if (aiAnalysisResult?.analysis != null) {
      return aiAnalysisResult!.analysis.riskLevel;
    }
    
    // AI 분석이 없는 경우 기본 로직으로 위험도 추정
    if (detectionResult?.hasDetections == true) {
      final primaryDetection = detectionResult!.detections.first.name.toLowerCase();
      if (primaryDetection.contains('damage') || primaryDetection.contains('crack')) {
        return 4;
      } else if (primaryDetection.contains('pothole') || primaryDetection.contains('debris')) {
        return 3;
      }
    }
    
    if (ocrResult?.extractedInfo.keywords.any((k) => 
        ['위험', '파손', '고장', '균열'].contains(k)) == true) {
      return 3;
    }
    
    return 1; // 기본 안전 상태
  }

  Map<String, dynamic> toJson() {
    return {
      'imagePath': imagePath,
      'detectionResult': detectionResult?.toJson(),
      'ocrResult': ocrResult?.toJson(),
      'aiAnalysisResult': aiAnalysisResult?.toJson(),
      'totalProcessingTime': totalProcessingTime,
      'analysisMode': analysisMode.name,
      'timestamp': timestamp.toIso8601String(),
      'isSuccessful': isSuccessful,
      'summary': summary,
      'combinedRiskLevel': combinedRiskLevel,
      'error': error,
    };
  }
}

/// 분석 성능 통계
class AnalysisPerformanceStats {
  final int totalAnalyzed;
  final int successfulAnalyses;
  final double averageProcessingTime;
  final double ocrSuccessRate;
  final double detectionSuccessRate;
  final double aiAnalysisSuccessRate;

  AnalysisPerformanceStats({
    required this.totalAnalyzed,
    required this.successfulAnalyses,
    required this.averageProcessingTime,
    required this.ocrSuccessRate,
    required this.detectionSuccessRate,
    required this.aiAnalysisSuccessRate,
  });

  double get overallSuccessRate => successfulAnalyses / totalAnalyzed;

  factory AnalysisPerformanceStats.empty() {
    return AnalysisPerformanceStats(
      totalAnalyzed: 0,
      successfulAnalyses: 0,
      averageProcessingTime: 0,
      ocrSuccessRate: 0,
      detectionSuccessRate: 0,
      aiAnalysisSuccessRate: 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalAnalyzed': totalAnalyzed,
      'successfulAnalyses': successfulAnalyses,
      'overallSuccessRate': overallSuccessRate,
      'averageProcessingTime': averageProcessingTime,
      'ocrSuccessRate': ocrSuccessRate,
      'detectionSuccessRate': detectionSuccessRate,
      'aiAnalysisSuccessRate': aiAnalysisSuccessRate,
    };
  }
}