import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/image_analysis_result.dart';
import '../../domain/services/image_analysis_service.dart';
import '../../../../core/providers/service_provider.dart';

final imageAnalysisServiceProvider = Provider<ImageAnalysisService>((ref) {
  final dio = ref.watch(aiDioProvider); // AI 전용 Dio 사용
  final webhookService = ref.watch(webhookServiceProvider); // 웹훅 서비스 추가
  return ImageAnalysisService(dio, webhookService: webhookService);
});

final imageAnalysisProvider = StateNotifierProvider<ImageAnalysisNotifier, AsyncValue<ImageAnalysisResult?>>((ref) {
  final service = ref.watch(imageAnalysisServiceProvider);
  return ImageAnalysisNotifier(service);
});

class ImageAnalysisNotifier extends StateNotifier<AsyncValue<ImageAnalysisResult?>> {
  final ImageAnalysisService _service;
  
  ImageAnalysisNotifier(this._service) : super(const AsyncValue.data(null));
  
  Future<void> performOCR(File imageFile) async {
    state = const AsyncValue.loading();
    
    try {
      final ocrResult = await _service.performOCR(imageFile);
      final currentResult = state.value ?? const ImageAnalysisResult();
      
      state = AsyncValue.data(
        currentResult.copyWith(
          ocrResult: ocrResult,
          imagePath: imageFile.path,  // 이미지 경로 저장
          analyzedAt: DateTime.now(),
        ),
      );
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
  
  Future<void> performAIAnalysis(File imageFile, {String analysisType = 'both'}) async {
    state = const AsyncValue.loading();
    
    try {
      final aiResult = await _service.performAIAnalysis(
        imageFile,
        analysisType: analysisType,
      );
      final currentResult = state.value ?? const ImageAnalysisResult();
      
      state = AsyncValue.data(
        currentResult.copyWith(
          aiResult: AIAnalysisResult.fromJson(aiResult),
          imagePath: imageFile.path,  // 이미지 경로 저장
          analyzedAt: DateTime.now(),
        ),
      );
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
  
  /// 통합 분석 수행 (OCR + AI 분석 + 웹훅)
  Future<void> performComprehensiveAnalysis(File imageFile) async {
    state = const AsyncValue.loading();
    
    try {
      final comprehensiveResult = await _service.performComprehensiveAnalysis(imageFile);
      
      state = AsyncValue.data(
        ImageAnalysisResult(
          ocrResult: comprehensiveResult.ocr,
          aiResult: AIAnalysisResult(
            sceneDescription: comprehensiveResult.aiAgent.sceneDescription,
            priorityRecommendation: comprehensiveResult.aiAgent.priorityRecommendation,
            confidenceScore: comprehensiveResult.aiAgent.confidenceScore,
            detectedObjects: comprehensiveResult.aiAgent.detectedObjects,
            contextAnalysis: comprehensiveResult.aiAgent.contextAnalysis,
          ),
          imagePath: imageFile.path,
          analyzedAt: DateTime.now(),
        ),
      );
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
  
  void reset() {
    state = const AsyncValue.data(null);
  }
  
  @override
  void dispose() {
    // Provider 종료시 처리된 파일 정리
    _service.cleanupTempFiles();
    super.dispose();
  }
}
