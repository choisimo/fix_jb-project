import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// 앱 전반에서 사용하는 통합 에러 핸들러
class ErrorHandler {
  /// 에러를 처리하고 사용자 친화적인 메시지를 반환
  static AppError handleError(dynamic error) {
    if (error is DioException) {
      return _handleDioError(error);
    } else if (error is AppError) {
      return error;
    } else {
      return AppError(
        type: ErrorType.unknown,
        message: '알 수 없는 오류가 발생했습니다.',
        originalError: error,
      );
    }
  }

  /// Dio 에러 처리
  static AppError _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return AppError(
          type: ErrorType.network,
          message: '네트워크 연결 시간이 초과되었습니다.\n잠시 후 다시 시도해주세요.',
          originalError: error,
        );

      case DioExceptionType.connectionError:
        return AppError(
          type: ErrorType.network,
          message: '인터넷 연결을 확인해주세요.',
          originalError: error,
        );

      case DioExceptionType.badResponse:
        return _handleHttpError(error);

      case DioExceptionType.cancel:
        return AppError(
          type: ErrorType.cancelled,
          message: '요청이 취소되었습니다.',
          originalError: error,
        );

      default:
        return AppError(
          type: ErrorType.network,
          message: '네트워크 오류가 발생했습니다.',
          originalError: error,
        );
    }
  }

  /// HTTP 상태 코드별 에러 처리
  static AppError _handleHttpError(DioException error) {
    final statusCode = error.response?.statusCode;
    final responseData = error.response?.data;

    // 서버에서 제공하는 에러 메시지 추출
    String? serverMessage;
    if (responseData is Map<String, dynamic>) {
      serverMessage = responseData['message'] as String? ?? 
                     responseData['error'] as String?;
    }

    switch (statusCode) {
      case 400:
        return AppError(
          type: ErrorType.validation,
          message: serverMessage ?? '잘못된 요청입니다.',
          originalError: error,
        );

      case 401:
        return AppError(
          type: ErrorType.authentication,
          message: '로그인이 필요합니다.',
          originalError: error,
        );

      case 403:
        return AppError(
          type: ErrorType.authorization,
          message: '접근 권한이 없습니다.',
          originalError: error,
        );

      case 404:
        return AppError(
          type: ErrorType.notFound,
          message: '요청한 정보를 찾을 수 없습니다.',
          originalError: error,
        );

      case 409:
        return AppError(
          type: ErrorType.conflict,
          message: serverMessage ?? '데이터 충돌이 발생했습니다.',
          originalError: error,
        );

      case 422:
        return AppError(
          type: ErrorType.validation,
          message: serverMessage ?? '입력 데이터를 확인해주세요.',
          originalError: error,
        );

      case 429:
        return AppError(
          type: ErrorType.rateLimit,
          message: '요청이 너무 많습니다. 잠시 후 다시 시도해주세요.',
          originalError: error,
        );

      case 500:
        return AppError(
          type: ErrorType.server,
          message: '서버 오류가 발생했습니다.',
          originalError: error,
        );

      case 502:
      case 503:
      case 504:
        return AppError(
          type: ErrorType.server,
          message: '서버가 일시적으로 사용할 수 없습니다.\n잠시 후 다시 시도해주세요.',
          originalError: error,
        );

      default:
        return AppError(
          type: ErrorType.server,
          message: serverMessage ?? 'HTTP 오류가 발생했습니다. (${statusCode ?? 'Unknown'})',
          originalError: error,
        );
    }
  }

  /// 에러를 로그에 기록
  static void logError(AppError error, {StackTrace? stackTrace}) {
    if (kDebugMode) {
      debugPrint('🔥 ERROR [${error.type.name}]: ${error.message}');
      if (error.originalError != null) {
        debugPrint('Original error: ${error.originalError}');
      }
      if (stackTrace != null) {
        debugPrint('Stack trace: $stackTrace');
      }
    }

    // 프로덕션에서는 Crashlytics 등에 에러 전송
    if (kReleaseMode) {
      _sendErrorToCrashlytics(error, stackTrace);
    }
  }

  /// Crashlytics에 에러 전송 (프로덕션용)
  static void _sendErrorToCrashlytics(AppError error, StackTrace? stackTrace) {
    // TODO: Firebase Crashlytics 연동
    // FirebaseCrashlytics.instance.recordError(
    //   error.originalError ?? error.message,
    //   stackTrace,
    //   fatal: error.type == ErrorType.critical,
    // );
  }

  /// 사용자에게 에러 메시지 표시
  static void showErrorDialog(BuildContext context, AppError error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_getErrorTitle(error.type)),
        content: Text(error.message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  /// 스낵바로 에러 메시지 표시
  static void showErrorSnackBar(BuildContext context, AppError error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error.message),
        backgroundColor: _getErrorColor(error.type),
        action: SnackBarAction(
          label: '확인',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  /// 에러 타입별 제목 반환
  static String _getErrorTitle(ErrorType type) {
    switch (type) {
      case ErrorType.network:
        return '네트워크 오류';
      case ErrorType.authentication:
        return '인증 오류';
      case ErrorType.authorization:
        return '권한 오류';
      case ErrorType.validation:
        return '입력 오류';
      case ErrorType.notFound:
        return '정보 없음';
      case ErrorType.server:
        return '서버 오류';
      case ErrorType.conflict:
        return '데이터 충돌';
      case ErrorType.rateLimit:
        return '요청 제한';
      case ErrorType.cancelled:
        return '요청 취소';
      case ErrorType.critical:
        return '심각한 오류';
      default:
        return '오류';
    }
  }

  /// 에러 타입별 색상 반환
  static Color _getErrorColor(ErrorType type) {
    switch (type) {
      case ErrorType.network:
        return Colors.orange;
      case ErrorType.authentication:
      case ErrorType.authorization:
        return Colors.red;
      case ErrorType.validation:
        return Colors.amber;
      case ErrorType.server:
      case ErrorType.critical:
        return Colors.red[700]!;
      default:
        return Colors.red;
    }
  }
}

/// 앱에서 사용하는 에러 타입
enum ErrorType {
  network,        // 네트워크 오류
  authentication, // 인증 오류
  authorization,  // 권한 오류
  validation,     // 입력 검증 오류
  notFound,       // 리소스 찾을 수 없음
  server,         // 서버 오류
  conflict,       // 데이터 충돌
  rateLimit,      // 요청 제한
  cancelled,      // 요청 취소
  critical,       // 심각한 오류
  unknown,        // 알 수 없는 오류
}

/// 앱 에러 클래스
class AppError implements Exception {
  final ErrorType type;
  final String message;
  final dynamic originalError;
  final Map<String, dynamic>? details;

  const AppError({
    required this.type,
    required this.message,
    this.originalError,
    this.details,
  });

  @override
  String toString() {
    return 'AppError{type: $type, message: $message}';
  }

  /// 에러가 재시도 가능한지 확인
  bool get isRetryable {
    switch (type) {
      case ErrorType.network:
      case ErrorType.server:
        return true;
      default:
        return false;
    }
  }

  /// 에러가 사용자 액션이 필요한지 확인
  bool get requiresUserAction {
    switch (type) {
      case ErrorType.authentication:
      case ErrorType.authorization:
      case ErrorType.validation:
        return true;
      default:
        return false;
    }
  }
}

/// 특정 에러 타입별 헬퍼 클래스
class NetworkError extends AppError {
  const NetworkError(String message, {super.originalError})
      : super(
          type: ErrorType.network,
          message: message,
        );
}

class AuthenticationError extends AppError {
  const AuthenticationError(String message, {super.originalError})
      : super(
          type: ErrorType.authentication,
          message: message,
        );
}

class ValidationError extends AppError {
  const ValidationError(String message, {super.details})
      : super(
          type: ErrorType.validation,
          message: message,
        );
}

class ServerError extends AppError {
  const ServerError(String message, {super.originalError})
      : super(
          type: ErrorType.server,
          message: message,
        );
}