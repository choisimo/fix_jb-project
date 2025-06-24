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
    _setLoading(true);
    
    try {
      final success = await _authService.loginWithEmail(email, password);
      if (success) {
        _isAuthenticated = true;
        _userInfo = _authService.userInfo;
      }
      return success;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> loginWithGoogle() async {
    _setLoading(true);
    
    try {
      final success = await _authService.loginWithGoogle();
      if (success) {
        _isAuthenticated = true;
        _userInfo = _authService.userInfo;
      }
      return success;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> loginWithKakao() async {
    _setLoading(true);
    
    try {
      final success = await _authService.loginWithKakao();
      if (success) {
        _isAuthenticated = true;
        _userInfo = _authService.userInfo;
      }
      return success;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    
    try {
      await _authService.logout();
      _isAuthenticated = false;
      _userInfo = null;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
