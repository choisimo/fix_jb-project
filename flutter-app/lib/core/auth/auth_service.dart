import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../storage/storage_service.dart';
import '../network/api_client.dart';
import '../../app/config/app_config.dart';

enum AuthError {
  invalidCredentials,
  networkError,
  serverError,
  tokenExpired,
  userNotFound,
  accountLocked,
  invalidEmail,
  weakPassword,
  unknown,
}

class AuthException implements Exception {
  final AuthError error;
  final String message;
  final String? details;

  AuthException(this.error, this.message, {this.details});

  @override
  String toString() {
    return 'AuthException: $message${details != null ? ' ($details)' : ''}';
  }
}

class AuthResult {
  final bool success;
  final AuthError? error;
  final String? message;
  final Map<String, dynamic>? userInfo;

  AuthResult.success({this.userInfo}) 
      : success = true, error = null, message = null;

  AuthResult.failure(this.error, this.message) 
      : success = false, userInfo = null;
}

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

  bool get isAuthenticated => _accessToken != null && _accessToken!.isNotEmpty;
  Map<String, dynamic>? get userInfo => _userInfo;

  /// 토큰 유효성 검증
  Future<bool> isTokenValid() async {
    if (!isAuthenticated) return false;
    
    try {
      final response = await _apiClient.get('/auth/validate');
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Token validation failed: $e');
      return false;
    }
  }

  /// 강화된 이메일 로그인
  Future<AuthResult> loginWithEmail(String email, String password) async {
    try {
      // 입력 값 검증
      if (email.isEmpty) {
        return AuthResult.failure(AuthError.invalidEmail, '이메일을 입력하세요.');
      }
      
      if (password.isEmpty) {
        return AuthResult.failure(AuthError.weakPassword, '비밀번호를 입력하세요.');
      }

      if (!_isValidEmail(email)) {
        return AuthResult.failure(AuthError.invalidEmail, '올바른 이메일 형식을 입력하세요.');
      }

      if (password.length < 6) {
        return AuthResult.failure(AuthError.weakPassword, '비밀번호는 6자 이상이어야 합니다.');
      }

      // 개발 모드에서 테스트 계정 확인
      if (AppConfig.isDevelopmentMode &&
          AppConfig.testAccounts.containsKey(email)) {
        if (AppConfig.testAccounts[email] == password) {
          // 테스트 계정으로 로그인 성공
          await _saveTestUserTokens(email);
          await _loadTestUserInfo(email);
          debugPrint('✅ Test account login successful: $email');
          return AuthResult.success(userInfo: _userInfo);
        } else {
          debugPrint('❌ Test account login failed: incorrect password');
          return AuthResult.failure(AuthError.invalidCredentials, '비밀번호가 일치하지 않습니다.');
        }
      }

      // 실제 서버 로그인
      debugPrint('🔄 Attempting server login for: $email');
      final response = await _apiClient.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        
        // 응답 데이터 검증
        if (data == null || 
            data['accessToken'] == null || 
            data['refreshToken'] == null) {
          throw AuthException(
            AuthError.serverError, 
            '서버 응답이 올바르지 않습니다.',
            details: 'Missing tokens in response'
          );
        }

        await _saveTokens(data['accessToken'], data['refreshToken']);
        await _loadUserInfo();
        
        debugPrint('✅ Server login successful for: $email');
        return AuthResult.success(userInfo: _userInfo);
      } else if (response.statusCode == 401) {
        return AuthResult.failure(AuthError.invalidCredentials, '이메일 또는 비밀번호가 일치하지 않습니다.');
      } else if (response.statusCode == 423) {
        return AuthResult.failure(AuthError.accountLocked, '계정이 잠겨있습니다. 관리자에게 문의하세요.');
      } else if (response.statusCode == 404) {
        return AuthResult.failure(AuthError.userNotFound, '존재하지 않는 사용자입니다.');
      } else {
        return AuthResult.failure(AuthError.serverError, '로그인 중 서버 오류가 발생했습니다. (${response.statusCode})');
      }
    } on AuthException catch (e) {
      debugPrint('❌ Auth exception: $e');
      return AuthResult.failure(e.error, e.message);
    } catch (e) {
      debugPrint('❌ Login error: $e');
      
      // 네트워크 오류 감지
      if (e.toString().contains('SocketException') || 
          e.toString().contains('HandshakeException') ||
          e.toString().contains('TimeoutException')) {
        return AuthResult.failure(AuthError.networkError, '네트워크 연결을 확인해주세요.');
      }
      
      return AuthResult.failure(AuthError.unknown, '로그인 중 예상치 못한 오류가 발생했습니다.');
    }
  }

  /// 이메일 형식 검증
  bool _isValidEmail(String email) {
    return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email);
  }

  Future<AuthResult> loginWithGoogle() async {
    try {
      // 개발 모드에서는 Google 로그인을 시뮬레이션
      if (AppConfig.isDevelopmentMode) {
        debugPrint('🔄 Google login simulated in development mode');
        await _saveTestUserTokens('google.test@example.com');
        await _loadTestUserInfo('google.test@example.com');
        return AuthResult.success(userInfo: _userInfo);
      }
      
      // 실제 Google 로그인은 추후 구현
      debugPrint('❌ Google login not implemented yet');
      return AuthResult.failure(AuthError.unknown, 'Google 로그인이 아직 구현되지 않았습니다.');
    } catch (e) {
      debugPrint('❌ Google login error: $e');
      return AuthResult.failure(AuthError.unknown, 'Google 로그인 중 오류가 발생했습니다.');
    }
  }

  Future<AuthResult> loginWithKakao() async {
    try {
      // 개발 모드에서는 Kakao 로그인을 시뮬레이션
      if (AppConfig.isDevelopmentMode) {
        debugPrint('🔄 Kakao login simulated in development mode');
        await _saveTestUserTokens('kakao.test@example.com');
        await _loadTestUserInfo('kakao.test@example.com');
        return AuthResult.success(userInfo: _userInfo);
      }
      
      // 실제 Kakao 로그인은 추후 구현
      debugPrint('❌ Kakao login not implemented yet');
      return AuthResult.failure(AuthError.unknown, 'Kakao 로그인이 아직 구현되지 않았습니다.');
    } catch (e) {
      debugPrint('❌ Kakao login error: $e');
      return AuthResult.failure(AuthError.unknown, 'Kakao 로그인 중 오류가 발생했습니다.');
    }
  }

  Future<bool> refreshToken() async {
    if (_refreshToken == null || _refreshToken!.isEmpty) {
      debugPrint('❌ No refresh token available');
      return false;
    }

    try {
      debugPrint('🔄 Attempting token refresh...');
      final response = await _apiClient.post(
        '/auth/refresh',
        data: {'refreshToken': _refreshToken},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        
        if (data == null || 
            data['accessToken'] == null || 
            data['refreshToken'] == null) {
          debugPrint('❌ Invalid refresh response format');
          await _clearTokens();
          return false;
        }

        await _saveTokens(data['accessToken'], data['refreshToken']);
        debugPrint('✅ Token refresh successful');
        return true;
      } else if (response.statusCode == 401) {
        debugPrint('❌ Refresh token expired, clearing tokens');
        await _clearTokens();
        return false;
      } else {
        debugPrint('❌ Token refresh failed: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Token refresh error: $e');
      
      // 네트워크 오류가 아닌 경우 토큰 클리어
      if (!e.toString().contains('SocketException') && 
          !e.toString().contains('HandshakeException') &&
          !e.toString().contains('TimeoutException')) {
        await _clearTokens();
      }
      
      return false;
    }
  }

  Future<void> logout() async {
    try {
      if (_accessToken != null && _accessToken!.isNotEmpty) {
        debugPrint('🔄 Attempting server logout...');
        await _apiClient.post('/auth/logout');
        debugPrint('✅ Server logout successful');
      }
    } catch (e) {
      debugPrint('❌ Logout error: $e');
      // 로그아웃 에러가 발생해도 로컬 토큰은 삭제
    } finally {
      await _clearTokens();
      debugPrint('✅ Local tokens cleared');
    }
  }

  Future<String?> getAccessToken() async {
    return _accessToken;
  }

  Future<void> _saveTokens(String accessToken, String refreshToken) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;

    // 🔐 보안 저장소에 토큰 저장
    await _storage.setSecureString('access_token', accessToken);
    await _storage.setSecureString('refresh_token', refreshToken);
  }

  Future<void> _loadTokensFromStorage() async {
    // 🔐 보안 저장소에서 토큰 로드
    _accessToken = await _storage.getSecureString('access_token');
    _refreshToken = await _storage.getSecureString('refresh_token');

    if (_accessToken != null) {
      await _loadUserInfo();
    }
  }

  Future<void> _loadUserInfo() async {
    try {
      debugPrint('🔄 Loading user info...');
      final response = await _apiClient.get('/auth/me');
      
      if (response.statusCode == 200 && response.data != null) {
        _userInfo = response.data;
        await _storage.setString('user_info', jsonEncode(_userInfo));
        debugPrint('✅ User info loaded successfully');
      } else if (response.statusCode == 401) {
        debugPrint('❌ Unauthorized - clearing tokens');
        await _clearTokens();
      } else {
        debugPrint('❌ Failed to load user info: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Load user info error: $e');
      
      // 네트워크 오류가 아닌 경우 토큰 문제일 수 있으므로 클리어
      if (!e.toString().contains('SocketException') && 
          !e.toString().contains('HandshakeException') &&
          !e.toString().contains('TimeoutException')) {
        await _clearTokens();
      }
    }
  }

  Future<void> _clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
    _userInfo = null;

    // 🔐 보안 저장소에서 토큰 삭제
    await _storage.removeSecure('access_token');
    await _storage.removeSecure('refresh_token');
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