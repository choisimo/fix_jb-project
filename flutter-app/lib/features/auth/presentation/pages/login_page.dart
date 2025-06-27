import 'package:flutter/material.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../core/auth/auth_service.dart';
import '../../../../app/config/app_config.dart';

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
  bool _isProcessing = false; // 중복 실행 방지를 위한 상태 플래그

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleEmailLogin() async {
    if (_isProcessing) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isProcessing = true;
    });

    final authService = AuthService.instance;
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    try {
      final success = await authService.loginWithEmail(
        _emailController.text,
        _passwordController.text,
      );

      if (!mounted) return;

      if (success) {
        // 로그인 성공 시 사용자 정보 확인
        final userInfo = authService.userInfo;
        final isTestAccount = userInfo?['isTestAccount'] == true;

        if (isTestAccount) {
          messenger.showSnackBar(
            SnackBar(
              content: Text('테스트 계정으로 로그인되었습니다: ${userInfo?['name']}'),
              backgroundColor: Colors.green,
            ),
          );
        }

        navigator.pushReplacementNamed(AppRoutes.home);
      } else {
        messenger.showSnackBar(
          const SnackBar(content: Text('이메일 또는 비밀번호가 일치하지 않습니다.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text('로그인 중 에러가 발생했습니다: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _handleSocialLogin(String provider) async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    final authService = AuthService.instance;
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    try {
      bool success = false;
      switch (provider) {
        case 'google':
          success = await authService.loginWithGoogle();
          break;
        case 'kakao':
          success = await authService.loginWithKakao();
          break;
        case 'naver':
          // 네이버 로그인은 임시로 비활성화
          success = false;
          break;
      }

      if (!mounted) return;

      if (success) {
        navigator.pushReplacementNamed(AppRoutes.home);
      } else {
        messenger.showSnackBar(
          SnackBar(content: Text('$provider 로그인에 실패했습니다.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('$provider 로그인 중 에러가 발생했습니다: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _fillTestAccount(String email, String password) {
    _emailController.text = email;
    _passwordController.text = password;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24.0),
            children: [
              const SizedBox(height: 48),
              const Text(
                '환영합니다',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                '현장 보고 시스템에 로그인하세요',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              SizedBox(
                height: 56,
                child: TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: '이메일',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
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
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 56,
                child: TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: '비밀번호',
                    prefixIcon: const Icon(Icons.lock),
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
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
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isProcessing ? null : _handleEmailLogin,
                child: const Text('로그인'),
              ),

              // 개발 모드에서만 테스트 계정 버튼들 표시
              if (AppConfig.isDevelopmentMode) ...[
                const SizedBox(height: 16),
                const Text(
                  '개발 모드 - 테스트 계정',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  alignment: WrapAlignment.center,
                  children: AppConfig.testAccounts.entries.map((entry) {
                    final email = entry.key;
                    final password = entry.value;
                    return SizedBox(
                      height: 32,
                      child: OutlinedButton(
                        onPressed: () => _fillTestAccount(email, password),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          email.split('@')[0],
                          style: const TextStyle(fontSize: 11),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],

              const SizedBox(height: 24),
              const Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('또는'),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: _isProcessing
                    ? null
                    : () => _handleSocialLogin('google'),
                icon: const Icon(Icons.g_mobiledata),
                label: const Text('Google로 로그인'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _isProcessing
                    ? null
                    : () => _handleSocialLogin('kakao'),
                icon: const Icon(Icons.chat_bubble),
                label: const Text('Kakao로 로그인'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
