import 'package:freezed_annotation/freezed_annotation.dart';
import 'user.dart';
import 'auth_models.dart';

part 'auth_state.freezed.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

@freezed
class AuthState with _$AuthState {
  const factory AuthState({
    @Default(AuthStatus.initial) AuthStatus status,
    User? user,
    String? accessToken,
    String? refreshToken,
    AuthError? error,
    @Default(false) bool isLoading,
    @Default(false) bool biometricEnabled,
    @Default(false) bool rememberMe,
    DateTime? lastLoginAt,
    String? deviceId,
  }) = _AuthState;

  const AuthState._();

  bool get isAuthenticated => status == AuthStatus.authenticated && user != null;
  bool get isUnauthenticated => status == AuthStatus.unauthenticated;
  bool get hasError => status == AuthStatus.error && error != null;
}

@freezed
class LoginState with _$LoginState {
  const factory LoginState({
    @Default(false) bool isLoading,
    @Default(false) bool showPassword,
    @Default(false) bool rememberMe,
    String? email,
    String? password,
    String? error,
    @Default(false) bool isGoogleLoading,
    @Default(false) bool isKakaoLoading,
    @Default(false) bool isBiometricAvailable,
    @Default(false) bool isBiometricEnabled,
  }) = _LoginState;
}

@freezed
class SignupState with _$SignupState {
  const factory SignupState({
    @Default(false) bool isLoading,
    @Default(false) bool showPassword,
    @Default(false) bool showConfirmPassword,
    @Default(false) bool acceptTerms,
    @Default(false) bool acceptPrivacy,
    String? email,
    String? password,
    String? confirmPassword,
    String? username,
    String? fullName,
    String? phoneNumber,
    String? error,
    Map<String, String>? fieldErrors,
  }) = _SignupState;

  const SignupState._();

  bool get isFormValid =>
      email != null &&
      email!.isNotEmpty &&
      password != null &&
      password!.isNotEmpty &&
      confirmPassword != null &&
      confirmPassword!.isNotEmpty &&
      password == confirmPassword &&
      username != null &&
      username!.isNotEmpty &&
      acceptTerms &&
      acceptPrivacy;
}