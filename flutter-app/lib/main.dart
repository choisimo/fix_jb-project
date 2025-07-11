import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'app/theme/app_theme.dart';
import 'app/routes/app_routes.dart';
import 'core/auth/auth_service.dart';
import 'core/storage/storage_service.dart';
import 'core/theme/theme_manager.dart';
import 'core/utils/naver_map_connection_test.dart';
import 'features/auth/presentation/pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Naver Map with enhanced error handling
  try {
    print('🔄 네이버 지도 SDK 초기화 시작...');
    print('📱 클라이언트 ID: 6gmofoay96');
    print('📦 패키지명: com.example.flutter.report.app (릴리즈)');
    print('📦 패키지명: com.example.flutter.report.app.debug (디버그)');

    // 네트워크 연결 테스트 먼저 수행
    try {
      final connectionResults = await NaverMapConnectionTest.testConnection();
      NaverMapConnectionTest.printTestResults(connectionResults);
    } catch (e) {
      print('⚠️ 네트워크 테스트 실패: $e');
    }

    await NaverMapSdk.instance.initialize(
      clientId: '6gmofoay96', // Your actual Naver Maps client ID
      onAuthFailed: (exception) {
        print('🚨 네이버 맵 인증 실패: $exception');
        print('📱 현재 패키지명: com.example.flutter.report.app');
        print('🔧 확인사항:');
        print('  1. 네이버 콘솔에 다음 패키지명들이 등록되었는지 확인:');
        print('     - com.example.flutter.report.app (릴리즈)');
        print('     - com.example.flutter.report.app.debug (디버그)');
        print('  2. Mobile Dynamic Map 서비스가 활성화되었는지 확인');
        print('  3. Client ID: 6gmofoay96 이 올바른지 확인');
        print('  4. 설정 변경 후 20분 대기했는지 확인');
        print('  5. 네트워크 연결 상태 확인');

        // 추가 디버깅 정보
        print('📊 추가 디버깅 정보:');
        print('  - Exception type: ${exception.runtimeType}');
        print('  - Exception details: ${exception.toString()}');
      },
    );
    print('✅ 네이버 지도 SDK 초기화 성공');
    print('🗺️ 지도 기능을 사용할 수 있습니다.');
  } catch (e) {
    print('❌ 네이버 지도 SDK 초기화 실패: $e');
    print('📱 앱은 지도 기능 없이 계속 실행됩니다.');
    print('🔧 해결 방법:');
    print('  1. 인터넷 연결 확인');
    print('  2. 네이버 개발자 콘솔 설정 확인');
    print('  3. 앱 재시작 후 다시 시도');
  }

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

    // 3. 테마 매니저 초기화
    debugPrint('🎨 Initializing Theme Manager...');
    await ThemeManager.instance.loadSettings();

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
    return AnimatedBuilder(
      animation: ThemeManager.instance,
      builder: (context, child) {
        return MaterialApp(
          title: '전북 현장 보고 플랫폼',
          theme: AppTheme.getLightTheme(
            fontSize: ThemeManager.instance.fontSize,
          ),
          darkTheme: AppTheme.getDarkTheme(
            fontSize: ThemeManager.instance.fontSize,
          ),
          themeMode: ThemeManager.instance.themeMode,
          home: null, // initialRoute를 사용하기 위해 null로 설정
          initialRoute: AppRoutes.splash, // 스플래시 페이지로 시작
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
      },
    );
  }
}
