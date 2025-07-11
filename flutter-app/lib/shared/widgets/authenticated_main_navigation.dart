import 'package:flutter/material.dart';
import '../../core/auth/auth_service.dart';
import '../../app/routes/app_routes.dart';
import 'main_navigation.dart';

class AuthenticatedMainNavigation extends StatefulWidget {
  const AuthenticatedMainNavigation({super.key});

  @override
  State<AuthenticatedMainNavigation> createState() => _AuthenticatedMainNavigationState();
}

class _AuthenticatedMainNavigationState extends State<AuthenticatedMainNavigation> {
  bool _isChecking = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    try {
      final authService = AuthService.instance;
      
      // 인증 상태 재확인
      if (!authService.isAuthenticated) {
        debugPrint('❌ Not authenticated in main navigation');
        _navigateToLogin();
        return;
      }

      // 토큰 유효성 재검증
      final isValid = await authService.isTokenValid();
      
      if (!mounted) return;
      
      if (isValid) {
        debugPrint('✅ Authentication verified in main navigation');
        setState(() {
          _isAuthenticated = true;
          _isChecking = false;
        });
      } else {
        debugPrint('❌ Token invalid in main navigation, attempting refresh...');
        
        // 토큰 갱신 시도
        final refreshSuccess = await authService.refreshToken();
        
        if (!mounted) return;
        
        if (refreshSuccess) {
          debugPrint('✅ Token refreshed in main navigation');
          setState(() {
            _isAuthenticated = true;
            _isChecking = false;
          });
        } else {
          debugPrint('❌ Token refresh failed in main navigation');
          await authService.logout();
          _navigateToLogin();
        }
      }
    } catch (e) {
      debugPrint('❌ Authentication check error in main navigation: $e');
      if (mounted) {
        _navigateToLogin();
      }
    }
  }

  void _navigateToLogin() {
    if (mounted) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      // 인증 확인 중일 때 로딩 화면
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).colorScheme.primary.withOpacity(0.1),
                Theme.of(context).colorScheme.surface,
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '인증 정보를 확인하고 있습니다...',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (!_isAuthenticated) {
      // 인증되지 않은 경우 (일반적으로 여기까지 오지 않아야 함)
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                '인증이 필요합니다',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                '로그인 페이지로 이동합니다...',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 인증된 경우 실제 메인 네비게이션 표시
    return const MainNavigation();
  }
}