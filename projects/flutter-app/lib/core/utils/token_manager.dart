import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class TokenManager {
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // 저장소 키
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userDataKey = 'user_data';
  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _lastLoginKey = 'last_login';

  /// 액세스 토큰 저장
  static Future<void> saveAccessToken(String token) async {
    try {
      await _storage.write(key: _accessTokenKey, value: token);
      debugPrint('✅ Access token saved');
    } catch (e) {
      debugPrint('❌ Failed to save access token: $e');
      rethrow;
    }
  }

  /// 리프레시 토큰 저장
  static Future<void> saveRefreshToken(String token) async {
    try {
      await _storage.write(key: _refreshTokenKey, value: token);
      debugPrint('✅ Refresh token saved');
    } catch (e) {
      debugPrint('❌ Failed to save refresh token: $e');
      rethrow;
    }
  }

  /// 토큰 쌍 저장 (액세스 + 리프레시)
  static Future<void> saveTokens(String accessToken, String refreshToken) async {
    try {
      await Future.wait([
        saveAccessToken(accessToken),
        saveRefreshToken(refreshToken),
      ]);
      
      // 마지막 로그인 시간 저장
      await _storage.write(
        key: _lastLoginKey, 
        value: DateTime.now().toIso8601String(),
      );
      
      debugPrint('✅ Tokens saved successfully');
    } catch (e) {
      debugPrint('❌ Failed to save tokens: $e');
      rethrow;
    }
  }

  /// 액세스 토큰 가져오기
  static Future<String?> getAccessToken() async {
    try {
      final token = await _storage.read(key: _accessTokenKey);
      if (token != null && !isTokenExpired(token)) {
        return token;
      }
      if (token != null && isTokenExpired(token)) {
        debugPrint('⚠️ Access token expired');
      }
      return null;
    } catch (e) {
      debugPrint('❌ Failed to get access token: $e');
      return null;
    }
  }

  /// 리프레시 토큰 가져오기
  static Future<String?> getRefreshToken() async {
    try {
      final token = await _storage.read(key: _refreshTokenKey);
      if (token != null && !isTokenExpired(token)) {
        return token;
      }
      if (token != null && isTokenExpired(token)) {
        debugPrint('⚠️ Refresh token expired');
        await clearTokens(); // 만료된 토큰 정리
      }
      return null;
    } catch (e) {
      debugPrint('❌ Failed to get refresh token: $e');
      return null;
    }
  }

  /// 유효한 액세스 토큰 가져오기 (자동 갱신 포함)
  static Future<String?> getValidAccessToken() async {
    try {
      String? accessToken = await getAccessToken();
      
      if (accessToken != null) {
        return accessToken;
      }

      // 액세스 토큰이 없거나 만료된 경우 리프레시 시도
      final refreshToken = await getRefreshToken();
      if (refreshToken != null) {
        debugPrint('🔄 Attempting to refresh access token');
        // 여기서 실제로는 API 호출을 통해 토큰을 갱신해야 함
        // 현재는 기본 구현만 제공
        return null;
      }

      return null;
    } catch (e) {
      debugPrint('❌ Failed to get valid access token: $e');
      return null;
    }
  }

  /// 사용자 데이터 저장
  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    try {
      await _storage.write(
        key: _userDataKey, 
        value: jsonEncode(userData),
      );
      debugPrint('✅ User data saved');
    } catch (e) {
      debugPrint('❌ Failed to save user data: $e');
      rethrow;
    }
  }

  /// 사용자 데이터 가져오기
  static Future<Map<String, dynamic>?> getUserData() async {
    try {
      final userDataString = await _storage.read(key: _userDataKey);
      if (userDataString != null) {
        return jsonDecode(userDataString) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      debugPrint('❌ Failed to get user data: $e');
      return null;
    }
  }

  /// 생체 인증 활성화 상태 저장
  static Future<void> setBiometricEnabled(bool enabled) async {
    try {
      await _storage.write(
        key: _biometricEnabledKey, 
        value: enabled.toString(),
      );
      debugPrint('✅ Biometric setting saved: $enabled');
    } catch (e) {
      debugPrint('❌ Failed to save biometric setting: $e');
      rethrow;
    }
  }

  /// 생체 인증 활성화 상태 가져오기
  static Future<bool> isBiometricEnabled() async {
    try {
      final enabled = await _storage.read(key: _biometricEnabledKey);
      return enabled == 'true';
    } catch (e) {
      debugPrint('❌ Failed to get biometric setting: $e');
      return false;
    }
  }

  /// 마지막 로그인 시간 가져오기
  static Future<DateTime?> getLastLoginTime() async {
    try {
      final lastLoginString = await _storage.read(key: _lastLoginKey);
      if (lastLoginString != null) {
        return DateTime.parse(lastLoginString);
      }
      return null;
    } catch (e) {
      debugPrint('❌ Failed to get last login time: $e');
      return null;
    }
  }

  /// 토큰 만료 여부 확인
  static bool isTokenExpired(String token) {
    try {
      return JwtDecoder.isExpired(token);
    } catch (e) {
      debugPrint('❌ Failed to check token expiration: $e');
      return true; // 에러 시 만료된 것으로 간주
    }
  }

  /// 토큰에서 사용자 ID 추출
  static String? getUserIdFromToken(String token) {
    try {
      final decodedToken = JwtDecoder.decode(token);
      return decodedToken['sub'] as String?;
    } catch (e) {
      debugPrint('❌ Failed to extract user ID from token: $e');
      return null;
    }
  }

  /// 토큰에서 사용자 권한 추출
  static List<String> getUserRolesFromToken(String token) {
    try {
      final decodedToken = JwtDecoder.decode(token);
      final roles = decodedToken['roles'] as List<dynamic>?;
      return roles?.map((role) => role.toString()).toList() ?? [];
    } catch (e) {
      debugPrint('❌ Failed to extract user roles from token: $e');
      return [];
    }
  }

  /// 토큰 만료까지 남은 시간 (분 단위)
  static int getTokenExpiryMinutes(String token) {
    try {
      final expiryDate = JwtDecoder.getExpirationDate(token);
      final now = DateTime.now();
      final difference = expiryDate.difference(now);
      return difference.inMinutes;
    } catch (e) {
      debugPrint('❌ Failed to get token expiry minutes: $e');
      return 0;
    }
  }

  /// 사용자 로그인 상태 확인
  static Future<bool> isLoggedIn() async {
    try {
      final accessToken = await getAccessToken();
      final refreshToken = await getRefreshToken();
      
      // 액세스 토큰이 유효하거나 리프레시 토큰이 있으면 로그인 상태
      return accessToken != null || refreshToken != null;
    } catch (e) {
      debugPrint('❌ Failed to check login status: $e');
      return false;
    }
  }

  /// 모든 토큰 및 데이터 삭제 (로그아웃)
  static Future<void> clearTokens() async {
    try {
      await Future.wait([
        _storage.delete(key: _accessTokenKey),
        _storage.delete(key: _refreshTokenKey),
        _storage.delete(key: _userDataKey),
        _storage.delete(key: _lastLoginKey),
      ]);
      debugPrint('✅ All tokens and user data cleared');
    } catch (e) {
      debugPrint('❌ Failed to clear tokens: $e');
      rethrow;
    }
  }

  /// 전체 저장소 초기화 (앱 초기화 시 사용)
  static Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
      debugPrint('✅ All stored data cleared');
    } catch (e) {
      debugPrint('❌ Failed to clear all data: $e');
      rethrow;
    }
  }

  /// 저장된 모든 키 목록 가져오기 (디버깅용)
  static Future<Map<String, String>> getAllStoredData() async {
    try {
      if (kDebugMode) {
        return await _storage.readAll();
      }
      return {};
    } catch (e) {
      debugPrint('❌ Failed to get all stored data: $e');
      return {};
    }
  }
}