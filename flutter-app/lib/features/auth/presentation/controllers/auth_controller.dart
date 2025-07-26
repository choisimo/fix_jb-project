import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/auth_repository.dart';
import '../../domain/models/auth_state.dart';
import '../../domain/models/auth_models.dart';
import '../../domain/models/user.dart';

part 'auth_controller.g.dart';

@Riverpod(keepAlive: true)
class AuthController extends _$AuthController {
  @override
  AuthState build() {
    _initializeAuth();
    return const AuthState();
  }

  Future<void> _initializeAuth() async {
    final authRepository = ref.read(authRepositoryProvider);
    
    if (await authRepository.hasValidTokens()) {
      state = state.copyWith(status: AuthStatus.loading);
      
      try {
        final user = await authRepository.getCurrentUser();
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
        );
      } catch (e) {
        try {
          await authRepository.refreshToken();
          final user = await authRepository.getCurrentUser();
          state = state.copyWith(
            status: AuthStatus.authenticated,
            user: user,
          );
        } catch (e) {
          await authRepository.logout();
          state = state.copyWith(
            status: AuthStatus.unauthenticated,
            error: const AuthError(
              code: 'SESSION_EXPIRED',
              message: 'Session expired. Please login again.',
            ),
          );
        }
      }
    } else {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> login(LoginRequest request) async {
    state = state.copyWith(
      status: AuthStatus.loading,
      isLoading: true,
      error: null,
    );

    try {
      final authRepository = ref.read(authRepositoryProvider);
      final response = await authRepository.login(request);
      
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: response.user,
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
        isLoading: false,
        rememberMe: request.rememberMe,
        lastLoginAt: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        isLoading: false,
        error: AuthError(
          code: 'LOGIN_ERROR',
          message: e.toString(),
        ),
      );
    }
  }

  Future<void> signup(SignupRequest request) async {
    state = state.copyWith(
      status: AuthStatus.loading,
      isLoading: true,
      error: null,
    );

    try {
      final authRepository = ref.read(authRepositoryProvider);
      final response = await authRepository.signup(request);
      
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: response.user,
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
        isLoading: false,
        lastLoginAt: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        isLoading: false,
        error: AuthError(
          code: 'SIGNUP_ERROR',
          message: e.toString(),
        ),
      );
    }
  }

  Future<void> googleLogin() async {
    state = state.copyWith(
      status: AuthStatus.loading,
      isLoading: true,
      error: null,
    );

    try {
      final authRepository = ref.read(authRepositoryProvider);
      final response = await authRepository.googleLogin();
      
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: response.user,
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
        isLoading: false,
        lastLoginAt: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        isLoading: false,
        error: AuthError(
          code: 'GOOGLE_LOGIN_ERROR',
          message: e.toString(),
        ),
      );
    }
  }

  Future<void> kakaoLogin() async {
    state = state.copyWith(
      status: AuthStatus.loading,
      isLoading: true,
      error: null,
    );

    try {
      final authRepository = ref.read(authRepositoryProvider);
      final response = await authRepository.kakaoLogin();
      
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: response.user,
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
        isLoading: false,
        lastLoginAt: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        isLoading: false,
        error: AuthError(
          code: 'KAKAO_LOGIN_ERROR',
          message: e.toString(),
        ),
      );
    }
  }

  Future<void> logout() async {
    state = state.copyWith(
      status: AuthStatus.loading,
      isLoading: true,
    );

    try {
      final authRepository = ref.read(authRepositoryProvider);
      await authRepository.logout();
      
      state = const AuthState(
        status: AuthStatus.unauthenticated,
      );
    } catch (e) {
      state = const AuthState(
        status: AuthStatus.unauthenticated,
      );
    }
  }

  Future<void> refreshToken() async {
    try {
      final authRepository = ref.read(authRepositoryProvider);
      final response = await authRepository.refreshToken();
      
      state = state.copyWith(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
      );
    } catch (e) {
      await logout();
    }
  }

  Future<void> requestPasswordReset(String email) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
    );

    try {
      final authRepository = ref.read(authRepositoryProvider);
      await authRepository.requestPasswordReset(email);
      
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: AuthError(
          code: 'PASSWORD_RESET_ERROR',
          message: e.toString(),
        ),
      );
    }
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
    );

    try {
      final authRepository = ref.read(authRepositoryProvider);
      await authRepository.changePassword(currentPassword, newPassword);
      
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: AuthError(
          code: 'PASSWORD_CHANGE_ERROR',
          message: e.toString(),
        ),
      );
    }
  }

  Future<void> verifyEmail(String token) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
    );

    try {
      final authRepository = ref.read(authRepositoryProvider);
      await authRepository.verifyEmail(token);
      
      if (state.user != null) {
        state = state.copyWith(
          user: state.user!.copyWith(emailVerified: true),
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: AuthError(
          code: 'EMAIL_VERIFICATION_ERROR',
          message: e.toString(),
        ),
      );
    }
  }

  Future<void> resendEmailVerification() async {
    state = state.copyWith(
      isLoading: true,
      error: null,
    );

    try {
      final authRepository = ref.read(authRepositoryProvider);
      await authRepository.resendEmailVerification();
      
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: AuthError(
          code: 'EMAIL_VERIFICATION_RESEND_ERROR',
          message: e.toString(),
        ),
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void updateUser(User user) {
    state = state.copyWith(user: user);
  }
}