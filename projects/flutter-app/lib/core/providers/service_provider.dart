import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/api_constants.dart';
import '../services/webhook_service.dart';
import '../../features/report/domain/services/report_service.dart';
import 'dart:developer' as developer;

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: ApiConstants.baseUrl, // API Gateway URL 사용
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 5),
  ));
  
  // Add a LogInterceptor to print network logs
  dio.interceptors.add(LogInterceptor(
    request: true,
    requestHeader: true,
    requestBody: true,
    responseHeader: true,
    responseBody: true,
    error: true,
    logPrint: (obj) => developer.log(obj.toString(), name: 'DIO'),
  ));
  
  return dio;
});

// AI 분석 전용 Dio Provider
final aiDioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: 'http://localhost:8085', // 슬래시 없는 깔끔한 baseUrl
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    sendTimeout: const Duration(seconds: 30),
    headers: {
      'Accept': 'application/json',
      'User-Agent': 'JB-Report-Flutter-App/1.0',
    },
  ));
  
  // Enhanced logging interceptor
  dio.interceptors.add(LogInterceptor(
    request: true,
    requestHeader: true,
    requestBody: true,
    responseHeader: true,
    responseBody: true,
    error: true,
    logPrint: (obj) => developer.log(obj.toString(), name: 'AI_DIO'),
  ));
  
  // Custom interceptor for debugging network connectivity
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) {
      developer.log('🚀 AI Request: ${options.method} ${options.uri}', name: 'AI_DIO');
      developer.log('📤 Headers: ${options.headers}', name: 'AI_DIO');
      handler.next(options);
    },
    onResponse: (response, handler) {
      developer.log('✅ AI Response: ${response.statusCode} ${response.statusMessage}', name: 'AI_DIO');
      handler.next(response);
    },
    onError: (error, handler) {
      developer.log('❌ AI Error: ${error.type} - ${error.message}', name: 'AI_DIO');
      if (error.response != null) {
        developer.log('❌ Response: ${error.response?.statusCode} - ${error.response?.statusMessage}', name: 'AI_DIO');
        developer.log('❌ Data: ${error.response?.data}', name: 'AI_DIO');
      }
      handler.next(error);
    },
  ));
  
  return dio;
});

// 웹훅 전용 Dio Provider
final webhookDioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    sendTimeout: const Duration(seconds: 30),
    headers: {
      'Content-Type': 'application/json',
      'User-Agent': 'JB-Report-Webhook/1.0',
    },
  ));
  
  dio.interceptors.add(LogInterceptor(
    request: true,
    requestHeader: true,
    requestBody: true,
    responseHeader: true,
    responseBody: true,
    error: true,
    logPrint: (obj) => developer.log(obj.toString(), name: 'WEBHOOK_DIO'),
  ));
  
  return dio;
});

// 웹훅 서비스 Provider
final webhookServiceProvider = Provider<WebhookService>((ref) {
  final webhookDio = ref.watch(webhookDioProvider);
  
  final service = WebhookService(
    webhookDio,
    webhookUrls: [
      // 이미지 분석 웹훅 URL
      'https://n8n-test.nodove.com/webhook/379e0d1c-db91-488b-b7e3-596c22a3306e',
    ],
    enableWebhooks: true,
  );
  
  return service;
});

// 리포트 서비스 Provider
final reportServiceProvider = Provider<ReportService>((ref) {
  final dio = ref.watch(dioProvider);
  return ReportService(dio);
});
