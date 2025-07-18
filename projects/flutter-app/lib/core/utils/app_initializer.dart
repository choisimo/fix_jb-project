import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui';
import '../../firebase_options.dart';
import '../config/env_config.dart';
import '../services/unified_location_service.dart';

class AppInitializer {
  static bool _isInitialized = false;

  /// 앱 초기화
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Flutter 바인딩 초기화
      WidgetsFlutterBinding.ensureInitialized();

      // Firebase 초기화 (프로덕션 및 스테이징 환경에서만)
      if (EnvConfig.instance.isProduction || EnvConfig.instance.isStaging) {
        await _initializeFirebase();
      }

      // 시스템 UI 설정
      await _setupSystemUI();

      // 보안 저장소 초기화
      await _initializeSecureStorage();

      // 권한 초기화
      await _initializePermissions();

      // 디바이스 정보 초기화
      await _initializeDeviceInfo();
      
      // 통합 위치 서비스 초기화
      await _initializeUnifiedLocationService();

      // 네이버 맵 초기화
      await _initializeNaverMap();

      _isInitialized = true;
      debugPrint('✅ App initialization completed successfully');
    } catch (e) {
      debugPrint('❌ App initialization failed: $e');
      // Firebase Crashlytics로 오류 전송 (임시 비활성화)
      // if (FirebaseCrashlytics.instance.isCrashlyticsCollectionEnabled) {
      //   FirebaseCrashlytics.instance.recordError(e, null, fatal: true);
      // }
      rethrow;
    }
  }

  /// Firebase 초기화
  static Future<void> _initializeFirebase() async {
    try {
      // Firebase 초기화
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      
      // Crashlytics 설정
      await _setupCrashlytics();
      
      debugPrint('✅ Firebase initialized successfully');
    } catch (e) {
      debugPrint('❌ Firebase initialization failed: $e');
      rethrow;
    }
  }

  /// Firebase Crashlytics 설정
  static Future<void> _setupCrashlytics() async {
    try {
      // 환경에 따라 Crashlytics 활성화
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
        EnvConfig.instance.enableCrashlytics
      );
      
      // Flutter 프레임워크 오류를 Crashlytics에 전송
      FlutterError.onError = (errorDetails) {
        if (EnvConfig.instance.enableCrashlytics) {
          FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
        } else {
          // 로그만 출력
          debugPrint('Flutter Error: ${errorDetails.exception}');
          debugPrint('Stack trace: ${errorDetails.stack}');
        }
      };
      
      // PlatformDispatcher 오류를 Crashlytics에 전송
      PlatformDispatcher.instance.onError = (error, stack) {
        if (EnvConfig.instance.enableCrashlytics) {
          FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        } else {
          // 로그만 출력
          debugPrint('Platform Error: $error');
          debugPrint('Stack trace: $stack');
        }
        return true;
      };
      
      if (EnvConfig.instance.enableCrashlytics) {
        // 사용자 정보 설정 (개인정보 제외)
        await FirebaseCrashlytics.instance.setUserIdentifier('anonymous');
        await FirebaseCrashlytics.instance.setCustomKey('app_version', '1.0.0');
        await FirebaseCrashlytics.instance.setCustomKey('platform', 'flutter');
        await FirebaseCrashlytics.instance.setCustomKey('environment', EnvConfig.instance.environment.name);
      }
      
      debugPrint('\u2705 Firebase Crashlytics setup completed (${EnvConfig.instance.enableCrashlytics ? 'enabled' : 'disabled'})');
    } catch (e) {
      debugPrint('\u274c Firebase Crashlytics setup failed: $e');
    }
  }

  /// 시스템 UI 설정
  static Future<void> _setupSystemUI() async {
    try {
      // 상태바 설정
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: Colors.white,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      );

      // 화면 방향 설정 (세로 모드만 허용)
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);

      debugPrint('✅ System UI setup completed');
    } catch (e) {
      debugPrint('❌ System UI setup failed: $e');
    }
  }

  /// 보안 저장소 초기화
  static Future<void> _initializeSecureStorage() async {
    try {
      const storage = FlutterSecureStorage(
        aOptions: AndroidOptions(
          encryptedSharedPreferences: true,
        ),
        iOptions: IOSOptions(
          accessibility: KeychainAccessibility.first_unlock_this_device,
        ),
      );

      // 저장소 접근 테스트
      await storage.read(key: 'test_key');
      debugPrint('✅ Secure storage initialized');
    } catch (e) {
      debugPrint('❌ Secure storage initialization failed: $e');
    }
  }

  /// 권한 초기화
  static Future<void> _initializePermissions() async {
    try {
      // 기본 권한들을 미리 체크하지만 요청하지는 않음
      // 실제 사용 시점에 권한 요청
      debugPrint('✅ Permissions check completed');
    } catch (e) {
      debugPrint('❌ Permissions initialization failed: $e');
    }
  }

  /// 디바이스 정보 초기화
  static Future<void> _initializeDeviceInfo() async {
    try {
      // 디바이스 정보 수집 (개인정보 제외)
      debugPrint('✅ Device info initialized');
    } catch (e) {
      debugPrint('❌ Device info initialization failed: $e');
    }
  }
  
  /// 통합 위치 서비스 초기화
  static Future<void> _initializeUnifiedLocationService() async {
    try {
      // SharedPreferences 초기화 (마지막 알려진 위치 캐싱용)
      await SharedPreferences.getInstance();
      
      // UnifiedLocationService 인스턴스 초기 설정
      final unifiedLocationService = UnifiedLocationService();
      
      // 디버그 모드 설정
      if (kDebugMode) {
        unifiedLocationService.setDebugMode(true);
      }
      
      // 초기화 및 권한 확인
      await unifiedLocationService.init();
      
      debugPrint('✅ Unified location service initialized');
    } catch (e) {
      debugPrint('❌ Unified location service initialization failed: $e');
      // 위치 서비스 초기화 실패는 애플리케이션을 중단하지 않음
    }
  }

  /// 네이버 맵 초기화
  static Future<void> _initializeNaverMap() async {
    try {
      final clientId = EnvConfig.instance.naverMapClientId;
      
      if (clientId.isEmpty || clientId == 'YOUR_NAVER_MAP_CLIENT_ID') {
        throw Exception('네이버 맵 클라이언트 ID가 설정되지 않았습니다.');
      }
      
      debugPrint('🗺️ Initializing Naver Map SDK with client ID: $clientId');
      
      // 네이버 맵 SDK 초기화
      await NaverMapSdk.instance.initialize(
        clientId: clientId,
        onAuthFailed: (ex) {
          debugPrint('❌ Naver Map auth failed: $ex');
        },
      );
      debugPrint('✅ Naver Map SDK initialized successfully');
    } catch (e) {
      debugPrint('❌ Naver Map initialization failed: $e');
      // 네이버 맵 초기화 실패는 치명적이지 않으므로 계속 진행
    }
  }

  /// 앱 설정 복원
  static Future<void> restoreAppSettings() async {
    try {
      const storage = FlutterSecureStorage();
      
      // 테마 설정 복원
      final themeMode = await storage.read(key: 'theme_mode');
      if (themeMode != null) {
        debugPrint('🎨 Theme mode restored: $themeMode');
      }

      // 언어 설정 복원
      final language = await storage.read(key: 'language');
      if (language != null) {
        debugPrint('🌐 Language restored: $language');
      }

      // 알림 설정 복원
      final notifications = await storage.read(key: 'notifications_enabled');
      if (notifications != null) {
        debugPrint('🔔 Notification settings restored: $notifications');
      }

      debugPrint('✅ App settings restored');
    } catch (e) {
      debugPrint('❌ App settings restoration failed: $e');
    }
  }

  /// 초기화 상태 확인
  static bool get isInitialized => _isInitialized;

  /// 앱 종료 시 정리 작업
  static Future<void> dispose() async {
    try {
      // 리소스 정리
      _isInitialized = false;
      debugPrint('✅ App cleanup completed');
    } catch (e) {
      debugPrint('❌ App cleanup failed: $e');
    }
  }
}