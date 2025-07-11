import 'package:flutter/material.dart';
import '../../../../core/auth/auth_service.dart';
import '../../../../app/routes/app_routes.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> 
    with SingleTickerProviderStateMixin {
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
    ));

    _animationController.forward();
    
    // 인증 상태 확인을 프레임 후에 실행
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _checkAuthState();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkAuthState() async {
    try {
      // 최소 1.5초 대기 (스플래시 효과)
      await Future.delayed(const Duration(milliseconds: 1500));
      
      final authService = AuthService.instance;
      final navigator = Navigator.of(context);
      
      if (!mounted) return;
      
      // 인증 상태 확인
      if (authService.isAuthenticated) {
        debugPrint('🔍 Checking token validity...');
        
        // 토큰 유효성 검증
        final isValid = await authService.isTokenValid();
        
        if (!mounted) return;
        
        if (isValid) {
          debugPrint('✅ Token is valid, navigating to home');
          navigator.pushReplacementNamed(AppRoutes.home);
          return;
        } else {
          debugPrint('❌ Token is invalid, attempting refresh...');
          
          // 토큰 갱신 시도
          final refreshSuccess = await authService.refreshToken();
          
          if (!mounted) return;
          
          if (refreshSuccess) {
            debugPrint('✅ Token refreshed successfully, navigating to home');
            navigator.pushReplacementNamed(AppRoutes.home);
            return;
          } else {
            debugPrint('❌ Token refresh failed, clearing tokens');
            await authService.logout();
          }
        }
      }
      
      // 인증되지 않았거나 토큰이 유효하지 않은 경우 로그인 페이지로
      debugPrint('🔄 Not authenticated, navigating to login');
      if (mounted) {
        navigator.pushReplacementNamed(AppRoutes.login);
      }
      
    } catch (e) {
      debugPrint('❌ Auth check error: $e');
      
      // 오류 발생 시 로그인 페이지로
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.primary.withOpacity(0.1),
              colorScheme.surface,
              colorScheme.secondary.withOpacity(0.1),
            ],
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 앱 로고
                      Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(
                            color: colorScheme.primary.withOpacity(0.2),
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          Icons.location_city,
                          size: 80,
                          color: colorScheme.primary,
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // 앱 이름
                      Text(
                        '전북 현장 보고',
                        style: theme.textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: colorScheme.onSurface,
                          letterSpacing: -1.0,
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // 서브타이틀
                      Text(
                        '안전하고 효율적인 현장 관리',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      
                      const SizedBox(height: 48),
                      
                      // 로딩 인디케이터
                      SizedBox(
                        width: 32,
                        height: 32,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            colorScheme.primary,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      Text(
                        '인증 상태를 확인하고 있습니다...',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
