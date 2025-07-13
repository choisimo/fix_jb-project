import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:local_auth/local_auth.dart';

import '../../domain/models/auth_state.dart';
import '../../domain/models/auth_models.dart';
import '../../data/services/token_service.dart';
import 'auth_controller.dart';

part 'login_controller.g.dart';

final tokenServiceProvider = Provider((ref) => TokenService());

@riverpod
class LoginController extends _$LoginController {
  final LocalAuthentication _localAuth = LocalAuthentication();

  @override
  LoginState build() {
    _checkBiometricAvailability();
    return const LoginState();
  }

  Future<void> _checkBiometricAvailability() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      final isBiometricEnabled = await ref.read(tokenServiceProvider).isBiometricEnabled();
      
      state = state.copyWith(
        isBiometricAvailable: isAvailable && isDeviceSupported,
        isBiometricEnabled: isBiometricEnabled,
      );
    } catch (e) {
      state = state.copyWith(isBiometricAvailable: false);
    }
  }

  void updateEmail(String email) {
    state = state.copyWith(email: email, error: null);
  }

  void updatePassword(String password) {
    state = state.copyWith(password: password, error: null);
  }

  void togglePasswordVisibility() {
    state = state.copyWith(showPassword: !state.showPassword);
  }

  void toggleRememberMe() {
    state = state.copyWith(rememberMe: !state.rememberMe);
  }

  Future<void> login() async {
    if (state.email == null || state.email!.isEmpty) {
      state = state.copyWith(error: 'Email is required');
      return;
    }

    if (state.password == null || state.password!.isEmpty) {
      state = state.copyWith(error: 'Password is required');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final request = LoginRequest(
        email: state.email!,
        password: state.password!,
        rememberMe: state.rememberMe,
      );

      await ref.read(authControllerProvider.notifier).login(request);
      
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> googleLogin() async {
    state = state.copyWith(isGoogleLoading: true, error: null);

    try {
      await ref.read(authControllerProvider.notifier).googleLogin();
      state = state.copyWith(isGoogleLoading: false);
    } catch (e) {
      state = state.copyWith(
        isGoogleLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> kakaoLogin() async {
    state = state.copyWith(isKakaoLoading: true, error: null);

    try {
      await ref.read(authControllerProvider.notifier).kakaoLogin();
      state = state.copyWith(isKakaoLoading: false);
    } catch (e) {
      state = state.copyWith(
        isKakaoLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> biometricLogin() async {
    if (!state.isBiometricAvailable || !state.isBiometricEnabled) {
      state = state.copyWith(error: 'Biometric authentication not available');
      return;
    }

    try {
      final isAuthenticated = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to access your account',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (isAuthenticated) {
        // Get stored credentials and login
        final tokenService = ref.read(tokenServiceProvider);
        final hasTokens = await tokenService.hasValidTokens();
        
        if (hasTokens) {
          // Try to refresh token and get user data
          await ref.read(authControllerProvider.notifier).refreshToken();
        } else {
          state = state.copyWith(error: 'No stored credentials found');
        }
      }
    } catch (e) {
      state = state.copyWith(error: 'Biometric authentication failed');
    }
  }

  Future<void> enableBiometric() async {
    if (!state.isBiometricAvailable) {
      state = state.copyWith(error: 'Biometric authentication not available');
      return;
    }

    try {
      final isAuthenticated = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to enable biometric login',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (isAuthenticated) {
        await ref.read(tokenServiceProvider).setBiometricEnabled(true);
        state = state.copyWith(isBiometricEnabled: true);
      }
    } catch (e) {
      state = state.copyWith(error: 'Failed to enable biometric authentication');
    }
  }

  Future<void> disableBiometric() async {
    try {
      await ref.read(tokenServiceProvider).setBiometricEnabled(false);
      state = state.copyWith(isBiometricEnabled: false);
    } catch (e) {
      state = state.copyWith(error: 'Failed to disable biometric authentication');
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}