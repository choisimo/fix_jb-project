import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/models/auth_state.dart';
import '../../domain/models/auth_models.dart';
import '../../data/auth_repository.dart';
import 'auth_controller.dart';

part 'signup_controller.g.dart';

@riverpod
class SignupController extends _$SignupController {
  @override
  SignupState build() {
    return const SignupState();
  }

  void updateEmail(String email) {
    state = state.copyWith(email: email, error: null);
    _clearFieldError('email');
    
    if (email.isNotEmpty) {
      _validateEmail(email);
    }
  }

  void updatePassword(String password) {
    state = state.copyWith(password: password, error: null);
    _clearFieldError('password');
    
    if (password.isNotEmpty) {
      _validatePassword(password);
    }
    
    if (state.confirmPassword != null && state.confirmPassword!.isNotEmpty) {
      _validatePasswordMatch();
    }
  }

  void updateConfirmPassword(String confirmPassword) {
    state = state.copyWith(confirmPassword: confirmPassword, error: null);
    _clearFieldError('confirmPassword');
    
    if (confirmPassword.isNotEmpty) {
      _validatePasswordMatch();
    }
  }

  void updateUsername(String username) {
    state = state.copyWith(username: username, error: null);
    _clearFieldError('username');
    
    if (username.isNotEmpty) {
      _validateUsername(username);
    }
  }

  void updateFullName(String fullName) {
    state = state.copyWith(fullName: fullName, error: null);
    _clearFieldError('fullName');
  }

  void updatePhoneNumber(String phoneNumber) {
    state = state.copyWith(phoneNumber: phoneNumber, error: null);
    _clearFieldError('phoneNumber');
  }

  void togglePasswordVisibility() {
    state = state.copyWith(showPassword: !state.showPassword);
  }

  void toggleConfirmPasswordVisibility() {
    state = state.copyWith(showConfirmPassword: !state.showConfirmPassword);
  }

  void toggleAcceptTerms() {
    state = state.copyWith(acceptTerms: !state.acceptTerms, error: null);
  }

  void toggleAcceptPrivacy() {
    state = state.copyWith(acceptPrivacy: !state.acceptPrivacy, error: null);
  }

  Future<void> checkEmailAvailability() async {
    if (state.email == null || state.email!.isEmpty) return;

    try {
      final authRepository = ref.read(authRepositoryProvider);
      final isAvailable = await authRepository.checkEmailAvailability(state.email!);
      
      if (!isAvailable) {
        _setFieldError('email', 'Email is already taken');
      }
    } catch (e) {
      _setFieldError('email', 'Failed to check email availability');
    }
  }

  Future<void> checkUsernameAvailability() async {
    if (state.username == null || state.username!.isEmpty) return;

    try {
      final authRepository = ref.read(authRepositoryProvider);
      final isAvailable = await authRepository.checkUsernameAvailability(state.username!);
      
      if (!isAvailable) {
        _setFieldError('username', 'Username is already taken');
      }
    } catch (e) {
      _setFieldError('username', 'Failed to check username availability');
    }
  }

  Future<void> signup() async {
    if (!_validateForm()) {
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final request = SignupRequest(
        email: state.email!,
        password: state.password!,
        username: state.username!,
        fullName: state.fullName,
        phoneNumber: state.phoneNumber,
        acceptTerms: state.acceptTerms,
        acceptPrivacy: state.acceptPrivacy,
      );

      await ref.read(authControllerProvider.notifier).signup(request);
      
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  bool _validateForm() {
    bool isValid = true;
    Map<String, String> errors = {};

    // Email validation
    if (state.email == null || state.email!.isEmpty) {
      errors['email'] = 'Email is required';
      isValid = false;
    } else if (!_isValidEmail(state.email!)) {
      errors['email'] = 'Please enter a valid email';
      isValid = false;
    }

    // Password validation
    if (state.password == null || state.password!.isEmpty) {
      errors['password'] = 'Password is required';
      isValid = false;
    } else if (!_isValidPassword(state.password!)) {
      errors['password'] = 'Password must be at least 8 characters with uppercase, lowercase, number and special character';
      isValid = false;
    }

    // Confirm password validation
    if (state.confirmPassword == null || state.confirmPassword!.isEmpty) {
      errors['confirmPassword'] = 'Please confirm your password';
      isValid = false;
    } else if (state.password != state.confirmPassword) {
      errors['confirmPassword'] = 'Passwords do not match';
      isValid = false;
    }

    // Username validation
    if (state.username == null || state.username!.isEmpty) {
      errors['username'] = 'Username is required';
      isValid = false;
    } else if (!_isValidUsername(state.username!)) {
      errors['username'] = 'Username must be 3-20 characters, alphanumeric and underscore only';
      isValid = false;
    }

    // Terms and privacy validation
    if (!state.acceptTerms) {
      errors['terms'] = 'You must accept the terms and conditions';
      isValid = false;
    }

    if (!state.acceptPrivacy) {
      errors['privacy'] = 'You must accept the privacy policy';
      isValid = false;
    }

    if (!isValid) {
      state = state.copyWith(
        fieldErrors: errors,
        error: 'Please fix the errors above',
      );
    }

    return isValid;
  }

  void _validateEmail(String email) {
    if (!_isValidEmail(email)) {
      _setFieldError('email', 'Please enter a valid email');
    } else {
      _clearFieldError('email');
    }
  }

  void _validatePassword(String password) {
    if (!_isValidPassword(password)) {
      _setFieldError('password', 'Password must be at least 8 characters with uppercase, lowercase, number and special character');
    } else {
      _clearFieldError('password');
    }
  }

  void _validatePasswordMatch() {
    if (state.password != state.confirmPassword) {
      _setFieldError('confirmPassword', 'Passwords do not match');
    } else {
      _clearFieldError('confirmPassword');
    }
  }

  void _validateUsername(String username) {
    if (!_isValidUsername(username)) {
      _setFieldError('username', 'Username must be 3-20 characters, alphanumeric and underscore only');
    } else {
      _clearFieldError('username');
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email);
  }

  bool _isValidPassword(String password) {
    return password.length >= 8 &&
           RegExp(r'[A-Z]').hasMatch(password) &&
           RegExp(r'[a-z]').hasMatch(password) &&
           RegExp(r'[0-9]').hasMatch(password) &&
           RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);
  }

  bool _isValidUsername(String username) {
    return username.length >= 3 &&
           username.length <= 20 &&
           RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(username);
  }

  void _setFieldError(String field, String error) {
    final errors = Map<String, String>.from(state.fieldErrors ?? {});
    errors[field] = error;
    state = state.copyWith(fieldErrors: errors);
  }

  void _clearFieldError(String field) {
    if (state.fieldErrors != null && state.fieldErrors!.containsKey(field)) {
      final errors = Map<String, String>.from(state.fieldErrors!);
      errors.remove(field);
      state = state.copyWith(fieldErrors: errors);
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void clearAllErrors() {
    state = state.copyWith(error: null, fieldErrors: {});
  }
}