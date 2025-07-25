import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/auth_repository.dart';
import '../data/services/token_service.dart';

part 'auth_providers.g.dart';

/// 토큰 서비스 Provider
@riverpod
TokenService tokenService(TokenServiceRef ref) {
  return TokenService();
}

/// 인증 리포지토리 Provider  
@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) {
  final tokenService = ref.watch(tokenServiceProvider);
  return AuthRepository(tokenService: tokenService);
}

/// 현재 사용자 Provider
@riverpod
class CurrentUser extends _$CurrentUser {
  @override
  Future<User?> build() async {
    final authRepository = ref.watch(authRepositoryProvider);
    return authRepository.getCurrentUser();
  }

  /// 사용자 정보 새로고침
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    final authRepository = ref.read(authRepositoryProvider);
    try {
      final user = await authRepository.getCurrentUser();
      state = AsyncValue.data(user);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// 사용자 정보 업데이트
  void updateUser(User? user) {
    state = AsyncValue.data(user);
  }
}

/// 로그인 상태 Provider
@riverpod
class AuthStatus extends _$AuthStatus {
  @override
  Future<bool> build() async {
    final tokenService = ref.watch(tokenServiceProvider);
    return await tokenService.isLoggedIn();
  }

  /// 로그인 상태 새로고침
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    final tokenService = ref.read(tokenServiceProvider);
    try {
      final isLoggedIn = await tokenService.isLoggedIn();
      state = AsyncValue.data(isLoggedIn);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// 로그인 상태 설정
  void setLoginStatus(bool isLoggedIn) {
    state = AsyncValue.data(isLoggedIn);
  }
}

/// 생체 인증 상태 Provider
@riverpod
class BiometricStatus extends _$BiometricStatus {
  @override
  Future<bool> build() async {
    final tokenService = ref.watch(tokenServiceProvider);
    return await tokenService.isBiometricEnabled();
  }

  /// 생체 인증 설정 토글
  Future<void> toggle() async {
    final tokenService = ref.read(tokenServiceProvider);
    final current = state.valueOrNull ?? false;
    
    state = const AsyncValue.loading();
    try {
      await tokenService.setBiometricEnabled(!current);
      state = AsyncValue.data(!current);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// 생체 인증 상태 설정
  void setBiometricEnabled(bool enabled) {
    state = AsyncValue.data(enabled);
  }
}

// User import 추가 (임시)
class User {
  final String id;
  final String email;
  final String username;
  
  User({required this.id, required this.email, required this.username});
}