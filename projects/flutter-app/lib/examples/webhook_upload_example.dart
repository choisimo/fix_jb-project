// 웹훅 업로드 사용 예제

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/report_repository.dart';
import '../core/utils/image_upload_helper.dart';
import '../core/services/webhook_upload_service.dart';

void initializeWebhookUpload(WidgetRef ref) {
  // 웹훅 업로드 서비스 초기화
  final webhookUploadService = ref.read(webhookUploadServiceProvider);
  ImageUploadHelper.setWebhookUploadService(webhookUploadService);
}

// 이미지 업로드 시 자동으로 웹훅도 호출됨
Future<void> uploadImageExample(WidgetRef ref, XFile imageFile) async {
  final repository = ref.read(reportRepositoryProvider);
  
  try {
    // 기존 업로드 + 웹훅 업로드가 자동으로 실행됨
    final response = await repository.uploadImage(imageFile);
    print('Upload successful: ${response.imageId}');
  } catch (e) {
    print('Upload failed: $e');
    // 웹훅 실패는 여기에 영향을 주지 않음
  }
}

// 이미지 선택 시에도 웹훅 호출됨
Future<void> pickImageExample(WidgetRef ref) async {
  // 웹훅 업로드 서비스 설정
  initializeWebhookUpload(ref);
  
  final file = await ImageUploadHelper.pickAndPrepareImage(
    source: ImageSource.camera,
    enableWebhookUpload: true, // 웹훅 업로드 활성화
  );
  
  if (file != null) {
    print('Image picked and webhook upload initiated');
  }
}