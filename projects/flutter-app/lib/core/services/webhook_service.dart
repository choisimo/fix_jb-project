import 'package:dio/dio.dart';
import 'dart:developer' as developer;
import '../models/webhook_payload.dart';

class WebhookService {
  final Dio _dio;
  final List<String> _webhookUrls;
  final bool _enableWebhooks;
  
  WebhookService(
    this._dio, {
    List<String>? webhookUrls,
    bool enableWebhooks = true,
  }) : _webhookUrls = webhookUrls ?? [],
        _enableWebhooks = enableWebhooks;
  
  /// 웹훅 URL 추가
  void addWebhookUrl(String url) {
    if (!_webhookUrls.contains(url)) {
      _webhookUrls.add(url);
      developer.log('Added webhook URL: $url', name: 'WEBHOOK');
    }
  }
  
  /// 웹훅 URL 제거
  void removeWebhookUrl(String url) {
    _webhookUrls.remove(url);
    developer.log('Removed webhook URL: $url', name: 'WEBHOOK');
  }
  
  /// 단일 웹훅 전송
  Future<bool> sendWebhook(String url, WebhookPayload payload) async {
    if (!_enableWebhooks) {
      developer.log('Webhooks disabled, skipping send', name: 'WEBHOOK');
      return false;
    }
    
    try {
      developer.log('📤 Sending webhook to: $url', name: 'WEBHOOK');
      developer.log('📦 Payload: ${payload.eventType}', name: 'WEBHOOK');
      
      final response = await _dio.post(
        url,
        data: payload.toJson(),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'X-Webhook-Event': payload.eventType,
            'X-Webhook-Timestamp': payload.timestamp.toIso8601String(),
            'X-Webhook-Source': 'jb-report-flutter',
          },
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        developer.log('✅ Webhook sent successfully to: $url', name: 'WEBHOOK');
        return true;
      } else {
        developer.log('⚠️ Webhook returned non-success status: ${response.statusCode}', name: 'WEBHOOK');
        return false;
      }
    } on DioException catch (e) {
      developer.log('❌ Webhook failed to: $url - ${e.type}: ${e.message}', name: 'WEBHOOK');
      return false;
    } catch (e) {
      developer.log('❌ Unexpected webhook error to: $url - $e', name: 'WEBHOOK');
      return false;
    }
  }
  
  /// 모든 웹훅 URL에 전송
  Future<List<bool>> sendToAllWebhooks(WebhookPayload payload) async {
    if (_webhookUrls.isEmpty) {
      developer.log('No webhook URLs configured', name: 'WEBHOOK');
      return [];
    }
    
    developer.log('📡 Broadcasting webhook to ${_webhookUrls.length} endpoints', name: 'WEBHOOK');
    
    final futures = _webhookUrls.map((url) => sendWebhook(url, payload));
    final results = await Future.wait(futures);
    
    final successCount = results.where((success) => success).length;
    developer.log('📊 Webhook broadcast completed: $successCount/${_webhookUrls.length} successful', name: 'WEBHOOK');
    
    return results;
  }
  
  /// 이미지 분석 시작 웹훅
  Future<List<bool>> notifyImageAnalysisStarted({
    required String imageId,
    required String imagePath,
    required int fileSize,
    required String mimeType,
    String? userId,
    String? sessionId,
    Map<String, dynamic>? metadata,
  }) async {
    final payload = ImageAnalysisWebhookPayload(
      imageId: imageId,
      imagePath: imagePath,
      fileSize: fileSize,
      mimeType: mimeType,
      userId: userId,
      sessionId: sessionId,
      metadata: metadata,
    );
    
    return await sendToAllWebhooks(payload);
  }
  
  /// 이미지 분석 완료 웹훅
  Future<List<bool>> notifyImageAnalysisCompleted({
    required String imageId,
    required Map<String, dynamic> analysisResult,
    String? userId,
    String? sessionId,
  }) async {
    final payload = ImageAnalysisWebhookPayload.completed(
      imageId: imageId,
      analysisResult: analysisResult,
      userId: userId,
      sessionId: sessionId,
    );
    
    return await sendToAllWebhooks(payload);
  }
  
  /// 이미지 분석 실패 웹훅
  Future<List<bool>> notifyImageAnalysisFailed({
    required String imageId,
    required String error,
    String? userId,
    String? sessionId,
  }) async {
    final payload = ImageAnalysisWebhookPayload.failed(
      imageId: imageId,
      error: error,
      userId: userId,
      sessionId: sessionId,
    );
    
    return await sendToAllWebhooks(payload);
  }
  
  /// 리포트 생성 웹훅
  Future<List<bool>> notifyReportCreated({
    required String reportId,
    required Map<String, dynamic> reportData,
    String? userId,
    String? sessionId,
  }) async {
    final payload = ReportWebhookPayload.created(
      reportId: reportId,
      reportData: reportData,
      userId: userId,
      sessionId: sessionId,
    );
    
    return await sendToAllWebhooks(payload);
  }
  
  /// 리포트 업데이트 웹훅
  Future<List<bool>> notifyReportUpdated({
    required String reportId,
    required Map<String, dynamic> updatedFields,
    String? userId,
    String? sessionId,
  }) async {
    final payload = ReportWebhookPayload.updated(
      reportId: reportId,
      updatedFields: updatedFields,
      userId: userId,
      sessionId: sessionId,
    );
    
    return await sendToAllWebhooks(payload);
  }
  
  /// 웹훅 URL 연결 상태 확인
  Future<Map<String, bool>> checkWebhookUrls() async {
    final results = <String, bool>{};
    
    final checkPayload = WebhookPayload(
      eventType: 'webhook_check',
      timestamp: DateTime.now(),
      data: {'message': 'Webhook connectivity check from JB Report app'},
    );
    
    for (final url in _webhookUrls) {
      results[url] = await sendWebhook(url, checkPayload);
    }
    
    return results;
  }
  
  /// 웹훅 설정 정보
  Map<String, dynamic> getWebhookInfo() {
    return {
      'enabled': _enableWebhooks,
      'urlCount': _webhookUrls.length,
      'urls': _webhookUrls,
    };
  }
}