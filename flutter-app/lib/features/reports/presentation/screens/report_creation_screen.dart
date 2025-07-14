import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../image_analysis/presentation/providers/image_analysis_provider.dart';
import '../../../core/helpers/image_upload_helper.dart';

class ReportCreationScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Report Creation'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _pickAndAnalyzeImage(ref, context),
          child: Text('Capture Image'),
        ),
      ),
    );
  }

  Future<void> _pickAndAnalyzeImage(WidgetRef ref, BuildContext context) async {
    try {
      // 이미지 선택 및 준비
      final imageFile = await ImageUploadHelper.pickAndPrepareImage(
        source: ImageSource.camera,
      );
      
      if (imageFile == null) return;
      
      // OCR 수행
      await ref.read(imageAnalysisProvider.notifier).performOCR(imageFile);
      
      // 결과 확인
      final result = ref.read(imageAnalysisProvider).value;
      if (result?.ocrResult != null) {
        // 추출된 필드로 폼 자동 채우기
        _autoFillForm(result!.ocrResult!.extractedFields);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _autoFillForm(Map<String, dynamic> extractedFields) {
    // 자동 채우기 로직 구현
  }
}