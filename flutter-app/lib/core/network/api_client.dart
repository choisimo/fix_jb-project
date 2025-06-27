import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../auth/auth_service.dart';
import '../../app/config/app_config.dart';

class ApiClient {
  late final Dio _dio;

  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: AppConfig.apiTimeout,
      receiveTimeout: AppConfig.apiTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _setupInterceptors();
  }

  void _setupInterceptors() {
    // JWT 토큰 자동 추가
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await AuthService.instance.getAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          // 토큰 만료 시 자동 갱신
          final refreshed = await AuthService.instance.refreshToken();
          if (refreshed) {
            final newToken = await AuthService.instance.getAccessToken();
            error.requestOptions.headers['Authorization'] = 'Bearer $newToken';
            final response = await _dio.fetch(error.requestOptions);
            handler.resolve(response);
            return;
          } else {
            await AuthService.instance.logout();
          }
        }
        handler.next(error);
      },
    ));

    // 로깅 인터셉터 (디버그 모드에서만)
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (log) => debugPrint(log.toString()),
      ));
    }
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) {
    return _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {dynamic data}) {
    return _dio.post(path, data: data);
  }

  Future<Response> put(String path, {dynamic data}) {
    return _dio.put(path, data: data);
  }

  Future<Response> delete(String path) {
    return _dio.delete(path);
  }

  Future<Response> uploadFile(String path, String filePath,
      {Map<String, dynamic>? data}) {
    final formData = FormData.fromMap({
      'file': MultipartFile.fromFileSync(filePath),
      ...?data,
    });
    return _dio.post(path, data: formData);
  }

  Future<Response> postMultipart(
    String path,
    Map<String, dynamic> fields,
    List<File> files, {
    String fileFieldName = 'images',
  }) async {
    final formData = FormData.fromMap({
      ...fields,
    });

    // 파일들 추가
    for (int i = 0; i < files.length; i++) {
      final file = files[i];
      formData.files.add(MapEntry(
        '${fileFieldName}[$i]',
        await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
      ));
    }

    return _dio.post(path, data: formData);
  }
}
