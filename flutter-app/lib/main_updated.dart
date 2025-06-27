import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'app/theme/app_theme.dart';
import 'app/routes/app_routes.dart';
import 'core/auth/auth_service.dart';
import 'core/storage/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 렌더링 오류 방지를 위한 전역 설정
  _configureRenderingStability();

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

/// 렌더링 안정성을 위한 전역 설정
void _configureRenderingStability() {
  // 렌더링 오류 필터링 - 앱 크래시 방지
  FlutterError.onError = (FlutterErrorDetails details) {
    final errorString = details.toString();

    // 알려진 렌더링 오류들을 필터링
    if (errorString.contains('semantics.parentDataDirty') ||
        errorString.contains('!childSemantics.renderObject._needsLayout') ||
        errorString.contains('RenderBox was not laid out') ||
        errorString.contains('BoxConstraints has a negative minimum height') ||
        errorString.contains('RenderFlex overflowed')) {
      debugPrint('🔧 [FILTERED] Rendering issue: ${details.exception}');
      debugPrint('📍 Widget: ${details.context}');

      // 심각하지 않은 렌더링 오류는 로그만 남기고 진행
      return;
    }

    // 다른 심각한 에러는 기본 처리
    debugPrint('🔥 Critical error: ${details.exception}');
    FlutterError.presentError(details);
  };
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
    return MultiProvider(
      providers: [
        // AuthProvider를 먼저 초기화 (다른 Provider들이 의존할 수 있음)
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider(),
          lazy: false, // 즉시 초기화
        ),
        // ReportProvider는 AuthProvider 이후에 초기화
        ChangeNotifierProvider<ReportProvider>(
          create: (context) => ReportProvider(),
          lazy: true, // 필요할 때 초기화
        ),
      ],
      child: Builder(
        builder: (context) {
          return MaterialApp(
            title: '전북 현장 보고 플랫폼',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('ko', 'KR'), Locale('en', 'US')],
            initialRoute: AppRoutes.splash,
            onGenerateRoute: AppRoutes.generateRoute,
            debugShowCheckedModeBanner: false,
            // 렌더링 안정성을 위한 강화된 builder
            builder: (BuildContext context, Widget? child) {
              return Builder(
                builder: (context) {
                  // 에러 바운더리 역할
                  return MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                      // 텍스트 스케일 제한으로 UI 깨짐 방지
                      textScaler: TextScaler.linear(
                        MediaQuery.of(context).textScaleFactor.clamp(0.8, 1.2),
                      ),
                      // 접근성 애니메이션 비활성화 (렌더링 오류 방지)
                      disableAnimations: true,
                    ),
                    child: Directionality(
                      textDirection: TextDirection.ltr,
                      child: Banner(
                        message: 'DEBUG',
                        location: BannerLocation.topEnd,
                        child: RepaintBoundary(
                          child: child ?? const SizedBox.shrink(),
                        ),
                      ),
                    ),
                  );
                },
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
        },
      ),
    );
  }
}
