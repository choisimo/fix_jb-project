import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' hide User;
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

import '../../../core/api/api_client.dart';
import 'api/auth_api_client.dart';
import 'services/token_service.dart';
import '../domain/models/auth_models.dart';
import '../domain/models/user.dart';

final tokenServiceProvider = Provider<TokenService>((ref) => TokenService());

final authApiClientProvider = Provider<AuthApiClient>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthApiClient(apiClient.dio);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final authApiClient = ref.watch(authApiClientProvider);
  final tokenService = ref.watch(tokenServiceProvider);
  final apiClient = ref.watch(apiClientProvider); // Dio 인스턴스에 직접 접근
  return AuthRepository(authApiClient, tokenService, apiClient.dio);
});

class AuthRepository {
  final AuthApiClient _authApiClient;
  final TokenService _tokenService;
  final Dio _dio; // Dio 인스턴스 추가
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: null, // Android용 별도 설정이 필요한 경우 추가
  );
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  final Uuid _uuid = const Uuid();
  
  AuthRepository(this._authApiClient, this._tokenService, this._dio);
  
  Future<AuthResponse> login(LoginRequest request) async {
    try {
      final deviceInfo = await _getDeviceInfo();
      
      // 서버 LoginRequest 형식에 맞춰 데이터 변환 (email, password만 필요)
      final requestData = {
        'email': request.email,
        'password': request.password,
      };
      
      // 직접 API 호출하여 서버 응답 구조에 맞게 파싱
      final apiResponse = await _dio.post('/auth/login', data: requestData);
      
      // 서버 응답 구조: { success, message, data: { ... }, timestamp, errorCode }
      final responseData = apiResponse.data as Map<String, dynamic>;
      final authData = responseData['data'] as Map<String, dynamic>;
      
      // AuthResponse 생성
      final response = AuthResponse.fromJson(authData);
      
      await _tokenService.saveTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
        userId: response.user.id,
        rememberMe: request.rememberMe,
      );
      
      if (deviceInfo['deviceId'] != null) {
        await _tokenService.setDeviceId(deviceInfo['deviceId']!);
      }
      
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<AuthResponse> signup(SignupRequest request) async {
    try {
      final deviceInfo = await _getDeviceInfo();
      
      // 서버 RegisterRequest 형식에 맞춰 데이터 변환
      final requestData = {
        'email': request.email,
        'password': request.password,
        'name': request.fullName ?? request.username ?? '사용자',  // null 체크 강화
        'phone': request.phoneNumber ?? '010-0000-0000',  // 기본 전화번호 제공
        'department': '일반',  // 기본 부서
      };
      
      // 직접 API 호출하여 서버 응답 구조에 맞게 파싱
      final apiResponse = await _dio.post('/auth/register', data: requestData);
      
      // 서버 응답 구조: { success, message, data: { ... }, timestamp, errorCode }
      final responseData = apiResponse.data as Map<String, dynamic>;
      final authData = responseData['data'] as Map<String, dynamic>;
      
      // AuthResponse 생성
      final response = AuthResponse.fromJson(authData);
      
      await _tokenService.saveTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
        userId: response.user.id,
        rememberMe: false,
      );
      
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<AuthResponse> googleLogin() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google sign in was cancelled');
      }
      
      final googleAuth = await googleUser.authentication;
      final deviceInfo = await _getDeviceInfo();
      
      final request = SocialLoginRequest(
        provider: 'google',
        accessToken: googleAuth.accessToken!,
        idToken: googleAuth.idToken,
        email: googleUser.email,
        username: googleUser.email.split('@').first,
        fullName: googleUser.displayName,
        profileImageUrl: googleUser.photoUrl,
        deviceId: deviceInfo['deviceId'],
        deviceName: deviceInfo['deviceName'],
      );
      
      // 직접 API 호출하여 서버 응답 구조에 맞게 파싱
      final apiResponse = await _dio.post('/auth/social-login', data: request.toJson());
      
      // 서버 응답 구조: { success, message, data: { ... }, timestamp, errorCode }
      final responseData = apiResponse.data as Map<String, dynamic>;
      final authData = responseData['data'] as Map<String, dynamic>;
      
      // AuthResponse 생성
      final response = AuthResponse.fromJson(authData);
      
      await _tokenService.saveTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
        userId: response.user.id,
        rememberMe: false,
      );
      
      return response;
    } catch (e) {
      throw Exception('Google login failed: $e');
    }
  }
  
  Future<AuthResponse> kakaoLogin() async {
    try {
      OAuthToken token;
      
      if (await isKakaoTalkInstalled()) {
        token = await UserApi.instance.loginWithKakaoTalk();
      } else {
        token = await UserApi.instance.loginWithKakaoAccount();
      }
      
      final kakaoUser = await UserApi.instance.me();
      final deviceInfo = await _getDeviceInfo();
      
      final request = SocialLoginRequest(
        provider: 'kakao',
        accessToken: token.accessToken,
        email: kakaoUser.kakaoAccount?.email,
        username: kakaoUser.kakaoAccount?.profile?.nickname ?? 'kakao_user',
        fullName: kakaoUser.kakaoAccount?.profile?.nickname,
        profileImageUrl: kakaoUser.kakaoAccount?.profile?.profileImageUrl,
        deviceId: deviceInfo['deviceId'],
        deviceName: deviceInfo['deviceName'],
      );
      
      // 직접 API 호출하여 서버 응답 구조에 맞게 파싱
      final apiResponse = await _dio.post('/auth/social-login', data: request.toJson());
      
      // 서버 응답 구조: { success, message, data: { ... }, timestamp, errorCode }
      final responseData = apiResponse.data as Map<String, dynamic>;
      final authData = responseData['data'] as Map<String, dynamic>;
      
      // AuthResponse 생성
      final response = AuthResponse.fromJson(authData);
      
      await _tokenService.saveTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
        userId: response.user.id,
        rememberMe: false,
      );
      
      return response;
    } catch (e) {
      throw Exception('Kakao login failed: $e');
    }
  }
  
  Future<AuthResponse> refreshToken() async {
    try {
      final refreshToken = await _tokenService.getRefreshToken();
      if (refreshToken == null) {
        throw Exception('No refresh token available');
      }
      
      final request = RefreshTokenRequest(refreshToken: refreshToken);
      
      // 직접 API 호출하여 서버 응답 구조에 맞게 파싱
      final apiResponse = await _dio.post('/auth/refresh', data: request.toJson());
      
      // 서버 응답 구조: { success, message, data: { ... }, timestamp, errorCode }
      final responseData = apiResponse.data as Map<String, dynamic>;
      final authData = responseData['data'] as Map<String, dynamic>;
      
      // AuthResponse 생성
      final response = AuthResponse.fromJson(authData);
      
      await _tokenService.updateAccessToken(response.accessToken);
      
      return response;
    } on DioException catch (e) {
      await _tokenService.clearTokens();
      throw _handleError(e);
    }
  }
  
  Future<void> logout() async {
    try {
      await _authApiClient.logout();
    } catch (e) {
      // Continue with local logout even if server logout fails
    } finally {
      await _tokenService.clearTokens();
      await _googleSignIn.signOut();
      try {
        await UserApi.instance.logout();
      } catch (e) {
        // Ignore kakao logout errors
      }
    }
  }
  
  Future<User> getCurrentUser() async {
    try {
      // 직접 API 호출하여 서버 응답 구조에 맞게 파싱
      final apiResponse = await _dio.get('/auth/me');
      
      // 서버 응답이 감싸진 형태인지 확인
      final responseData = apiResponse.data as Map<String, dynamic>;
      
      // 만약 { data: { ... } } 형태라면 data 필드 추출, 아니면 직접 사용
      final userData = responseData.containsKey('data') 
          ? responseData['data'] as Map<String, dynamic>
          : responseData;
      
      return User.fromJson(userData);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<void> requestPasswordReset(String email) async {
    try {
      final request = PasswordResetRequest(email: email);
      await _authApiClient.requestPasswordReset(request.toJson());
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<void> changePassword(String currentPassword, String newPassword) async {
    try {
      final request = PasswordChangeRequest(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      await _authApiClient.changePassword(request.toJson());
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<void> verifyEmail(String token) async {
    try {
      final request = EmailVerificationRequest(token: token);
      await _authApiClient.verifyEmail(request.toJson());
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<void> resendEmailVerification() async {
    try {
      await _authApiClient.resendEmailVerification();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<bool> checkEmailAvailability(String email) async {
    try {
      final response = await _authApiClient.checkEmailAvailability(email);
      return response['available'] ?? false;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<bool> checkUsernameAvailability(String username) async {
    try {
      final response = await _authApiClient.checkUsernameAvailability(username);
      return response['available'] ?? false;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<bool> hasValidTokens() async {
    return await _tokenService.hasValidTokens();
  }
  
  Future<Map<String, String?>> _getDeviceInfo() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        return {
          'deviceId': androidInfo.id,
          'deviceName': '${androidInfo.brand} ${androidInfo.model}',
        };
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        return {
          'deviceId': iosInfo.identifierForVendor,
          'deviceName': '${iosInfo.name} ${iosInfo.model}',
        };
      }
    } catch (e) {
      // Fallback to generated UUID
    }
    
    return {
      'deviceId': _uuid.v4(),
      'deviceName': 'Unknown Device',
    };
  }
  
  Exception _handleError(DioException error) {
    if (error.response != null) {
      final data = error.response!.data;
      if (data is Map<String, dynamic>) {
        final message = data['message'] ?? 'Unknown error occurred';
        final code = data['code'] ?? 'UNKNOWN_ERROR';
        return Exception('$code: $message');
      }
    }
    
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('Network timeout. Please check your connection.');
      case DioExceptionType.connectionError:
        return Exception('Connection error. Please check your internet connection.');
      default:
        return Exception('Network error occurred');
    }
  }
}
