import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../storage/storage_service.dart';
import '../network/api_client.dart';
import '../../app/config/app_config.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  static AuthService get instance => _instance;
  AuthService._internal();

  final StorageService _storage = StorageService.instance;
  final ApiClient _apiClient = ApiClient();

  String? _accessToken;
  String? _refreshToken;
  Map<String, dynamic>? _userInfo;

  Future<void> init() async {
    await _loadTokensFromStorage();
  }

  bool get isAuthenticated => _accessToken != null;
  Map<String, dynamic>? get userInfo => _userInfo;

  Future<bool> loginWithEmail(String email, String password) async {
    try {
      // 개발 모드에서 테스트 계정 확인
      if (AppConfig.isDevelopmentMode &&
          AppConfig.testAccounts.containsKey(email)) {
        if (AppConfig.testAccounts[email] == password) {
          // 테스트 계정으로 로그인 성공
          await _saveTestUserTokens(email);
          await _loadTestUserInfo(email);
          debugPrint('Test account login successful: $email');
          return true;
        } else {
          debugPrint('Test account login failed: incorrect password');
          return false;
        }
      }

      // 실제 서버 로그인
      final response = await _apiClient.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        await _saveTokens(data['accessToken'], data['refreshToken']);
        await _loadUserInfo();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Login error: $e');
      return false;
    }
  }

  Future<bool> loginWithGoogle() async {
    try {
      // Google OAuth2 로그인 구현
      // google_sign_in 패키지 사용
      return false; // 임시
    } catch (e) {
      debugPrint('Google login error: $e');
      return false;
    }
  }

  Future<bool> loginWithKakao() async {
    try {
      // Kakao 로그인 구현
      // kakao_flutter_sdk 패키지 사용
      return false; // 임시
    } catch (e) {
      debugPrint('Kakao login error: $e');
      return false;
    }
  }

  Future<bool> refreshToken() async {
    if (_refreshToken == null) return false;

    try {
      final response = await _apiClient.post(
        '/auth/refresh',
        data: {'refreshToken': _refreshToken},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        await _saveTokens(data['accessToken'], data['refreshToken']);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Token refresh error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    try {
      if (_accessToken != null) {
        await _apiClient.post('/auth/logout');
      }
    } catch (e) {
      debugPrint('Logout error: $e');
    } finally {
      await _clearTokens();
    }
  }

  Future<String?> getAccessToken() async {
    return _accessToken;
  }

  Future<void> _saveTokens(String accessToken, String refreshToken) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;

    await _storage.setString('access_token', accessToken);
    await _storage.setString('refresh_token', refreshToken);
  }

  Future<void> _loadTokensFromStorage() async {
    _accessToken = await _storage.getString('access_token');
    _refreshToken = await _storage.getString('refresh_token');

    if (_accessToken != null) {
      await _loadUserInfo();
    }
  }

  Future<void> _loadUserInfo() async {
    try {
      final response = await _apiClient.get('/auth/me');
      if (response.statusCode == 200) {
        _userInfo = response.data;
        await _storage.setString('user_info', jsonEncode(_userInfo));
      }
    } catch (e) {
      debugPrint('Load user info error: $e');
    }
  }

  Future<void> _clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
    _userInfo = null;

    await _storage.remove('access_token');
    await _storage.remove('refresh_token');
    await _storage.remove('user_info');
  }

  // 테스트 사용자를 위한 메서드들 (개발 모드에서만 사용)
  Future<void> _saveTestUserTokens(String email) async {
    // 테스트 토큰 생성 (실제로는 JWT가 아니지만 테스트용)
    final testToken =
        'test_token_${email.replaceAll('@', '_').replaceAll('.', '_')}';
    final testRefreshToken =
        'test_refresh_${email.replaceAll('@', '_').replaceAll('.', '_')}';

    await _saveTokens(testToken, testRefreshToken);
  }

  Future<void> _loadTestUserInfo(String email) async {
    // 테스트 사용자 정보 생성
    final testUserInfo = {
      'id': email.hashCode,
      'email': email,
      'name': email.split('@')[0].replaceAll('.', ' ').toUpperCase(),
      'role': email.startsWith('admin') ? 'ADMIN' : 'USER',
      'isTestAccount': true,
      'createdAt': DateTime.now().toIso8601String(),
    };

    _userInfo = testUserInfo;
    await _storage.setString('user_info', jsonEncode(_userInfo));
  }
}
