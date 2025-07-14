import 'dart:io';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../constants/api_constants.dart';

/// n8n 웹훅을 통한 이미지 업로드 서비스
/// 기존 이미지 업로드 기능에 추가로 동작하는 보조 서비스
class WebhookUploadService {
  final Dio _dio;

  WebhookUploadService(this._dio);

  /// 웹훅으로 이미지를 비동기 업로드
  /// 실패해도 에러를 던지지 않고 로그만 남김 (기존 기능에 영향 없음)
  Future<void> uploadImageToWebhook(XFile imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final fileName = imageFile.name;
      
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(
          bytes,
          filename: fileName,
        ),
      });

      // AI Analysis Server로 웹훅 요청
      await _dio.post(
        '${ApiConstants.aiBaseUrl}${ApiConstants.webhookImageUploadEndpoint}',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
          // 빠른 타임아웃 설정 (메인 업로드에 영향 없도록)
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );
      
      print('✅ Webhook upload completed for: $fileName');
    } catch (e) {
      // 웹훅 실패는 무시 (기존 기능에 영향 없음)
      print('⚠️ Webhook upload failed (ignored): $e');
    }
  }

  /// 여러 이미지를 웹훅으로 업로드
  Future<void> uploadImagesToWebhook(List<XFile> imageFiles) async {
    // 각 이미지를 독립적으로 업로드 (하나 실패해도 나머지 계속)
    for (final imageFile in imageFiles) {
      // Future.wait 사용하지 않음 (순차적으로 처리하여 서버 부하 방지)
      await uploadImageToWebhook(imageFile);
    }
  }

  /// File 객체를 위한 웹훅 업로드 메서드
  Future<void> uploadFileToWebhook(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final fileName = imageFile.path.split('/').last;
      
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(
          bytes,
          filename: fileName,
        ),
      });

      await _dio.post(
        '${ApiConstants.aiBaseUrl}${ApiConstants.webhookImageUploadEndpoint}',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );
      
      print('✅ Webhook upload completed for: $fileName');
    } catch (e) {
      print('⚠️ Webhook upload failed (ignored): $e');
    }
  }
}