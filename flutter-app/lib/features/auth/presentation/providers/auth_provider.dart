import 'package:flutter/foundation.dart';
import '../../../../core/auth/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService.instance;
  
  bool _isLoading = false;
  bool _isAuthenticated = false;
  Map<String, dynamic>? _userInfo;

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  Map<String, dynamic>? get userInfo => _userInfo;

  Future<void> checkAuthStatus() async {
    _isAuthenticated = _authService.isAuthenticated;
    _userInfo = _authService.userInfo;
    notifyListeners();
  }

  Future<bool> loginWithEmail(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _authService.loginWithEmail(email, password);
      _isAuthenticated = success;
      if (success) {
        _userInfo = _authService.userInfo;
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> loginWithGoogle() async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _authService.loginWithGoogle();
      _isAuthenticated = success;
      if (success) {
        _userInfo = _authService.userInfo;
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> loginWithKakao() async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _authService.loginWithKakao();
      _isAuthenticated = success;
      if (success) {
        _userInfo = _authService.userInfo;
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _isAuthenticated = false;
    _userInfo = null;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
