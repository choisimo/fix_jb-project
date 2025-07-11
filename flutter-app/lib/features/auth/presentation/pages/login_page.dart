import 'package:flutter/material.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../core/auth/auth_service.dart';
import '../../../../app/config/app_config.dart';

enum LoginState { idle, loading, success, error }

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  LoginState _loginState = LoginState.idle;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleEmailLogin() async {
    // 이미 로딩 중이면 무시
    if (_loginState == LoginState.loading) return;
    
    // 폼 검증
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loginState = LoginState.loading;
      _errorMessage = null;
    });

    final authService = AuthService.instance;
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    try {
      final result = await authService.loginWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      if (result.success) {
        setState(() {
          _loginState = LoginState.success;
        });

        // 로그인 성공 시 사용자 정보 확인
        final userInfo = result.userInfo;
        final isTestAccount = userInfo?['isTestAccount'] == true;

        if (isTestAccount) {
          messenger.showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.verified_user, color: Colors.white),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text('테스트 계정으로 로그인되었습니다: ${userInfo?['name']}'),
                  ),
                ],
              ),
              backgroundColor: Theme.of(context).colorScheme.primary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              duration: Duration(seconds: 3),
            ),
          );
        }

        // 성공 시 홈으로 이동
        navigator.pushReplacementNamed(AppRoutes.home);
      } else {
        setState(() {
          _loginState = LoginState.error;
          _errorMessage = result.message ?? '로그인에 실패했습니다.';
        });

        _showErrorSnackBar(messenger, result.message ?? '로그인에 실패했습니다.');
      }
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _loginState = LoginState.error;
        _errorMessage = '로그인 중 예상치 못한 오류가 발생했습니다.';
      });

      _showErrorSnackBar(messenger, '로그인 중 예상치 못한 오류가 발생했습니다.');
      debugPrint('Login exception: $e');
    }
  }

  void _showErrorSnackBar(ScaffoldMessengerState messenger, String message) {
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: Duration(seconds: 4),
        action: SnackBarAction(
          label: '닫기',
          textColor: Colors.white,
          onPressed: () => messenger.hideCurrentSnackBar(),
        ),
      ),
    );
  }

  Future<void> _handleSocialLogin(String provider) async {
    if (_loginState == LoginState.loading) return;

    setState(() {
      _loginState = LoginState.loading;
      _errorMessage = null;
    });

    final authService = AuthService.instance;
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    try {
      AuthResult result;
      switch (provider) {
        case 'google':
          result = await authService.loginWithGoogle();
          break;
        case 'kakao':
          result = await authService.loginWithKakao();
          break;
        default:
          result = AuthResult.failure(AuthError.unknown, '지원하지 않는 로그인 방식입니다.');
      }

      if (!mounted) return;

      if (result.success) {
        setState(() {
          _loginState = LoginState.success;
        });

        messenger.showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('${provider.toUpperCase()} 로그인 성공!'),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );

        navigator.pushReplacementNamed(AppRoutes.home);
      } else {
        setState(() {
          _loginState = LoginState.error;
          _errorMessage = result.message;
        });

        _showErrorSnackBar(messenger, result.message ?? '${provider.toUpperCase()} 로그인에 실패했습니다.');
      }
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _loginState = LoginState.error;
        _errorMessage = '${provider.toUpperCase()} 로그인 중 오류가 발생했습니다.';
      });

      _showErrorSnackBar(messenger, '${provider.toUpperCase()} 로그인 중 오류가 발생했습니다.');
      debugPrint('Social login exception: $e');
    }
  }

  void _fillTestAccount(String email, String password) {
    if (_loginState == LoginState.loading) return;
    
    _emailController.text = email;
    _passwordController.text = password;
    setState(() {
      _errorMessage = null; // 에러 메시지 초기화
    });
  }

  bool get _isLoading => _loginState == LoginState.loading;

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
              colorScheme.surface,
              colorScheme.surface.withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(24.0),
              children: [
                const SizedBox(height: 60),
                
                // 로고 및 타이틀 영역
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: colorScheme.primary.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.location_city,
                        size: 48,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '전북 현장 보고',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: colorScheme.onSurface,
                          letterSpacing: -0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '안전하고 효율적인 현장 관리',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.7),
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 48),
                
                // 입력 필드들
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.shadow.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: '이메일',
                          prefixIcon: Icon(
                            Icons.email_outlined,
                            color: colorScheme.primary,
                          ),
                          labelStyle: TextStyle(
                            color: colorScheme.onSurface.withOpacity(0.7),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            debugPrint('이메일 입력값이 비어있음');
                            return '이메일을 입력하세요';
                          }
                          if (!RegExp(
                            r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                          ).hasMatch(value)) {
                            debugPrint('이메일 형식 오류: $value');
                            return '올바른 이메일 형식을 입력하세요';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: '비밀번호',
                          prefixIcon: Icon(
                            Icons.lock_outline,
                            color: colorScheme.primary,
                          ),
                          labelStyle: TextStyle(
                            color: colorScheme.onSurface.withOpacity(0.7),
                            fontWeight: FontWeight.w500,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: colorScheme.onSurface.withOpacity(0.6),
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            debugPrint('비밀번호 입력값이 비어있음');
                            return '비밀번호를 입력하세요';
                          }
                          if (value.length < 6) {
                            debugPrint('비밀번호 길이 오류: $value');
                            return '비밀번호는 6자 이상이어야 합니다';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),
                      
                      // 로그인 버튼
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleEmailLogin,
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            backgroundColor: _errorMessage != null 
                                ? colorScheme.error 
                                : null,
                          ),
                          child: _isLoading
                              ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      colorScheme.onPrimary,
                                    ),
                                  ),
                                )
                              : Text(
                                  _errorMessage != null ? '다시 시도' : '로그인',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                        ),
                      ),
                      
                      // 에러 메시지 표시
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: colorScheme.error.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: colorScheme.error,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: TextStyle(
                                    color: colorScheme.onErrorContainer,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // 개발 모드에서만 테스트 계정 버튼들 표시
                if (AppConfig.isDevelopmentMode) ...[
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '개발 모드 - 테스트 계정',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.6),
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: AppConfig.testAccounts.entries.map((entry) {
                            final email = entry.key;
                            final password = entry.value;
                            return Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: colorScheme.outline.withOpacity(0.5),
                                ),
                              ),
                              child: InkWell(
                                onTap: () => _fillTestAccount(email, password),
                                borderRadius: BorderRadius.circular(8),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  child: Text(
                                    email.split('@')[0],
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 32),
                
                // 구분선
                Row(
                  children: [
                    Expanded(child: Divider(color: colorScheme.outline.withOpacity(0.3))),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        '또는',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: colorScheme.outline.withOpacity(0.3))),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // 소셜 로그인 버튼들
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: OutlinedButton.icon(
                        onPressed: _isLoading
                            ? null
                            : () => _handleSocialLogin('google'),
                        icon: Icon(
                          Icons.g_mobiledata,
                          size: 24,
                          color: _isLoading 
                              ? colorScheme.onSurface.withOpacity(0.3)
                              : colorScheme.primary,
                        ),
                        label: const Text('Google로 로그인'),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: OutlinedButton.icon(
                        onPressed: _isLoading
                            ? null
                            : () => _handleSocialLogin('kakao'),
                        icon: Icon(
                          Icons.chat_bubble_outline,
                          size: 24,
                          color: _isLoading 
                              ? colorScheme.onSurface.withOpacity(0.3)
                              : colorScheme.primary,
                        ),
                        label: const Text('Kakao로 로그인'),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
