import 'package:flutter/material.dart';
import 'app/theme/app_theme.dart';
import 'app/routes/app_routes.dart';
import 'core/auth/auth_service.dart';
import 'core/storage/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
      // 지역화 설정 - Provider 의존성 없이 기본 설정
      supportedLocales: const [Locale('ko', 'KR'), Locale('en', 'US')],
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRoutes.generateRoute,
      debugShowCheckedModeBanner: false,
      // 렌더링 안정성을 위한 builder 추가
      builder: (BuildContext context, Widget? child) {
        // MediaQuery 래핑으로 렌더링 오류 방지
        final mediaQuery = MediaQuery.of(context);
        return MediaQuery(
          data: mediaQuery.copyWith(
            // 텍스트 스케일 제한으로 UI 깨짐 방지 (새로운 API 사용)
            textScaler: mediaQuery.textScaler.clamp(
              minScaleFactor: 0.8,
              maxScaleFactor: 1.2,
            ),
          ),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: child ?? const SizedBox.shrink(),
          ),
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
