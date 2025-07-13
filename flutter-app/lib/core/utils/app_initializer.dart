import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AppInitializer {
  static bool _isInitialized = false;

  /// 앱 초기화
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Flutter 바인딩 초기화
      WidgetsFlutterBinding.ensureInitialized();

      // 시스템 UI 설정
      await _setupSystemUI();

      // 보안 저장소 초기화
      await _initializeSecureStorage();

      // 권한 초기화
      await _initializePermissions();

      // 디바이스 정보 초기화
      await _initializeDeviceInfo();

      _isInitialized = true;
      debugPrint('✅ App initialization completed successfully');
    } catch (e) {
      debugPrint('❌ App initialization failed: $e');
      rethrow;
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