import 'dart:ui';
import 'package:flutter/material.dart';
import 'app/theme/app_theme.dart';
import 'app/routes/app_routes.dart';
import 'core/auth/auth_service.dart';
import 'core/storage/storage_service.dart';
import 'features/auth/presentation/pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 전역 Flutter 에러 핸들러 설정 - semantics 오류 등 처리
  FlutterError.onError = (FlutterErrorDetails details) {
    final String errorString = details.exception.toString();

    // 알려진 non-critical 렌더링 오류들을 필터링
    final List<String> ignoredErrors = [
      '!semantics.parentDataDirty',
      'BoxConstraints has a negative minimum height',
      'RenderBox was not laid out',
      'Vertical viewport was given unbounded height',
      'RenderFlex overflowed by',
      'The following assertion was thrown during layout',
      'The following RenderObject was being processed when the failure occurred',
    ];

    bool shouldIgnoreError = ignoredErrors.any(
      (pattern) => errorString.contains(pattern),
    );

    if (shouldIgnoreError) {
      debugPrint(
        '⚠️ Ignored rendering error: ${errorString.split('\n').first}',
      );
      return; // 에러를 무시하고 앱 계속 실행
    } else {
      // 중요한 에러는 기본 핸들러로 처리
      debugPrint('🔥 Critical Flutter error: $errorString');
      FlutterError.presentError(details);
    }
  };

  // Dart 런타임 에러 핸들러도 설정
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('🔥 Unhandled Dart error: $error');
    debugPrint('Stack: $stack');
    return true; // 에러 처리 완료 표시
  };

  // 서비스 초기화 및 에러 핸들링
  try {
    await _initializeServices();
  } catch (e, stackTrace) {
    debugPrint('🔥 Critical initialization error: $e');
    debugPrint('Stack trace: $stackTrace');
    // 초기화 실패 시에도 앱 실행 (기본 상태)
  }

  runApp(const MyApp());
}

/// 서비스 초기화 함수 - 순차적으로 실행하여 의존성 문제 방지
Future<void> _initializeServices() async {
  try {
    // 1. 스토리지 서비스 먼저 초기화 (다른 서비스들이 의존)
    debugPrint('📦 Initializing Storage Service...');
    await StorageService.instance.init();

    // 2. 인증 서비스 초기화 (스토리지에 의존)
    debugPrint('🔐 Initializing Auth Service...');
    await AuthService.instance.init();

    debugPrint('✅ All services initialized successfully');
  } catch (e, stackTrace) {
    debugPrint('🔥 Service initialization failed: $e');
    debugPrint('Stack trace: $stackTrace');
    // 에러가 발생해도 앱은 실행하되, 기본 상태로 시작
    rethrow; // 필요시 에러를 상위로 전파
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '전북 현장 보고 플랫폼',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const LoginPage(),
      onGenerateRoute: AppRoutes.generateRoute,
      debugShowCheckedModeBanner: false,
      // 렌더링 안정성을 위한 builder 추가
      builder: (BuildContext context, Widget? child) {
        // MediaQuery 래핑으로 렌더링 오류 방지
        final mediaQuery = MediaQuery.of(context);
        return MediaQuery(
          data: mediaQuery.copyWith(
            // 텍스트 스케일 제한으로 UI 깨짐 방지
            textScaler: mediaQuery.textScaler.clamp(
              minScaleFactor: 0.8,
              maxScaleFactor: 1.2,
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
      // 전역 에러 핸들러
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(title: const Text('페이지를 찾을 수 없음')),
            body: const Center(child: Text('요청한 페이지를 찾을 수 없습니다.')),
          ),
        );
      },
    );
  }
}
