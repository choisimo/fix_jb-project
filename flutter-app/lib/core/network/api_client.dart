import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../config/app_config.dart';
import '../error/exceptions.dart';
import '../storage/secure_storage.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/error_interceptor.dart';
import 'interceptors/retry_interceptor.dart';

class ApiClient {
  late final Dio _dio;
  final SecureStorage _secureStorage;
  
  ApiClient({required SecureStorage secureStorage}) 
      : _secureStorage = secureStorage {
    _setupDio();
  }
  
  void _setupDio() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.useNewApiVersion 
            ? AppConfig.apiBaseUrl 
            : AppConfig.legacyApiBaseUrl,
        connectTimeout: AppConfig.connectionTimeout.inMilliseconds,
        receiveTimeout: AppConfig.receiveTimeout.inMilliseconds,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Platform': defaultTargetPlatform.name,
          'X-App-Version': AppConfig.appVersion,
        },
      ),
    );
    
    // Add interceptors in order
    _dio.interceptors.addAll([
      AuthInterceptor(secureStorage: _secureStorage),
      RetryInterceptor(dio: _dio, maxRetries: AppConfig.maxRetryAttempts),
      ErrorInterceptor(),
    ]);
    
    // Add logger in debug mode
    if (AppConfig.enableNetworkLogging && !kReleaseMode) {
      _dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          compact: true,
        ),
      );
    }
  }
  
  // GET request
  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response.data as T;
    } on DioError catch (e) {
      throw _handleError(e);
    }
  }
  
  // POST request
  Future<T> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response.data as T;
    } on DioError catch (e) {
      throw _handleError(e);
    }
  }
  
  // PUT request
  Future<T> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response.data as T;
    } on DioError catch (e) {
      throw _handleError(e);
    }
  }
  
  // DELETE request
  Future<T> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response.data as T;
    } on DioError catch (e) {
      throw _handleError(e);
    }
  }
  
  // File upload
  Future<T> uploadFile<T>(
    String path, {
    required String filePath,
    required String fileFieldName,
    Map<String, dynamic>? data,
    ProgressCallback? onSendProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      final formData = FormData.fromMap({
        ...?data,
        fileFieldName: await MultipartFile.fromFile(filePath),
      });
      
      final response = await _dio.post<T>(
        path,
        data: formData,
        onSendProgress: onSendProgress,
        cancelToken: cancelToken,
      );
      return response.data as T;
    } on DioError catch (e) {
      throw _handleError(e);
    }
  }
  
  AppException _handleError(DioError error) {
    switch (error.type) {
      case DioErrorType.connectTimeout:
      case DioErrorType.sendTimeout:
      case DioErrorType.receiveTimeout:
        return NetworkException('Connection timeout');
      case DioErrorType.response:
        return _handleResponseError(error.response);
      case DioErrorType.cancel:
        return NetworkException('Request cancelled');
      case DioErrorType.other:
        return NetworkException('Network error: ${error.message}');
    }
  }
  
  AppException _handleResponseError(Response? response) {
    if (response == null) {
      return ServerException('No response from server');
    }
    
    final statusCode = response.statusCode ?? 0;
    final data = response.data;
    
    String message = 'Server error';
    if (data is Map<String, dynamic>) {
      message = data['message'] ?? data['error'] ?? message;
    }
    
    switch (statusCode) {
      case 400:
        return ValidationException(message, data['errors'] ?? {});
      case 401:
        return UnauthorizedException(message);
      case 403:
        return ForbiddenException(message);
      case 404:
        return NotFoundException(message);
      case 422:
        return ValidationException(message, data['errors'] ?? {});
      case 500:
      case 502:
      case 503:
        return ServerException(message);
      default:
        return ServerException('Unexpected error: $statusCode');
    }
  }
}
