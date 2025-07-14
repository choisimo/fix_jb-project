import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/image_analysis_result.dart';
import '../../domain/services/image_analysis_service.dart';
import '../../../core/providers/service_provider.dart';

final imageAnalysisServiceProvider = Provider<ImageAnalysisService>((ref) {
  final dio = ref.watch(dioProvider);
  return ImageAnalysisService(dio);
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
      final currentResult = state.value ?? ImageAnalysisResult();
      
      state = AsyncValue.data(
        currentResult.copyWith(ocrResult: ocrResult),
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
      final currentResult = state.value ?? ImageAnalysisResult();
      
      state = AsyncValue.data(
        currentResult.copyWith(aiResult: aiResult),
      );
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
  
  void reset() {
    state = const AsyncValue.data(null);
  }
}
