import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../controllers/signup_controller.dart';
import '../controllers/auth_controller.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/social_login_button.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _usernameController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final signupState = ref.watch(signupControllerProvider);
    final authState = ref.watch(authControllerProvider);

    ref.listen(authControllerProvider, (previous, next) {
      if (next.isAuthenticated) {
        context.go('/');
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Text(
                  'Join JB Report',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Create your account to get started',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 32),
                
                // Email Field
                AuthTextField(
                  controller: _emailController,
                  label: 'Email*',
                  hintText: 'Enter your email',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  errorText: signupState.fieldErrors?['email'],
                  onChanged: (value) {
                    ref.read(signupControllerProvider.notifier).updateEmail(value);
                  },
                  onEditingComplete: () {
                    ref.read(signupControllerProvider.notifier).checkEmailAvailability();
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Username Field
                AuthTextField(
                  controller: _usernameController,
                  label: 'Username*',
                  hintText: 'Enter your username',
                  prefixIcon: Icons.person_outlined,
                  errorText: signupState.fieldErrors?['username'],
                  onChanged: (value) {
                    ref.read(signupControllerProvider.notifier).updateUsername(value);
                  },
                  onEditingComplete: () {
                    ref.read(signupControllerProvider.notifier).checkUsernameAvailability();
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Full Name Field
                AuthTextField(
                  controller: _fullNameController,
                  label: 'Full Name',
                  hintText: 'Enter your full name',
                  prefixIcon: Icons.badge_outlined,
                  errorText: signupState.fieldErrors?['fullName'],
                  onChanged: (value) {
                    ref.read(signupControllerProvider.notifier).updateFullName(value);
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Phone Number Field
                AuthTextField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  hintText: 'Enter your phone number',
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icons.phone_outlined,
                  errorText: signupState.fieldErrors?['phoneNumber'],
                  onChanged: (value) {
                    ref.read(signupControllerProvider.notifier).updatePhoneNumber(value);
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Password Field
                AuthTextField(
                  controller: _passwordController,
                  label: 'Password*',
                  hintText: 'Enter your password',
                  obscureText: !signupState.showPassword,
                  prefixIcon: Icons.lock_outlined,
                  suffixIcon: IconButton(
                    icon: Icon(
                      signupState.showPassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      ref.read(signupControllerProvider.notifier).togglePasswordVisibility();
                    },
                  ),
                  errorText: signupState.fieldErrors?['password'],
                  onChanged: (value) {
                    ref.read(signupControllerProvider.notifier).updatePassword(value);
                  },
                ),
                
                const SizedBox(height: 8),
                
                // Password Requirements
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Password must contain:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 4),
                      _buildPasswordRequirement('At least 8 characters'),
                      _buildPasswordRequirement('One uppercase letter'),
                      _buildPasswordRequirement('One lowercase letter'),
                      _buildPasswordRequirement('One number'),
                      _buildPasswordRequirement('One special character'),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Confirm Password Field
                AuthTextField(
                  controller: _confirmPasswordController,
                  label: 'Confirm Password*',
                  hintText: 'Confirm your password',
                  obscureText: !signupState.showConfirmPassword,
                  prefixIcon: Icons.lock_outlined,
                  suffixIcon: IconButton(
                    icon: Icon(
                      signupState.showConfirmPassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      ref.read(signupControllerProvider.notifier).toggleConfirmPasswordVisibility();
                    },
                  ),
                  errorText: signupState.fieldErrors?['confirmPassword'],
                  onChanged: (value) {
                    ref.read(signupControllerProvider.notifier).updateConfirmPassword(value);
                  },
                ),
                
                const SizedBox(height: 24),
                
                // Terms and Privacy
                Column(
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: signupState.acceptTerms,
                          onChanged: (value) {
                            ref.read(signupControllerProvider.notifier).toggleAcceptTerms();
                          },
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              ref.read(signupControllerProvider.notifier).toggleAcceptTerms();
                            },
                            child: RichText(
                              text: TextSpan(
                                style: Theme.of(context).textTheme.bodyMedium,
                                children: [
                                  const TextSpan(text: 'I agree to the '),
                                  TextSpan(
                                    text: 'Terms and Conditions',
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: signupState.acceptPrivacy,
                          onChanged: (value) {
                            ref.read(signupControllerProvider.notifier).toggleAcceptPrivacy();
                          },
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              ref.read(signupControllerProvider.notifier).toggleAcceptPrivacy();
                            },
                            child: RichText(
                              text: TextSpan(
                                style: Theme.of(context).textTheme.bodyMedium,
                                children: [
                                  const TextSpan(text: 'I agree to the '),
                                  TextSpan(
                                    text: 'Privacy Policy',
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Error Message
                if (signupState.error != null || authState.hasError)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: Text(
                      signupState.error ?? authState.error?.message ?? 'An error occurred',
                      style: TextStyle(color: Colors.red[700]),
                    ),
                  ),
                
                // Create Account Button
                ElevatedButton(
                  onPressed: signupState.isLoading ? null : () async {
                    await ref.read(signupControllerProvider.notifier).signup();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: signupState.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Create Account', style: TextStyle(fontSize: 16)),
                ),
                
                const SizedBox(height: 16),
                
                // Divider
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Or sign up with',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Social Signup Buttons
                Row(
                  children: [
                    Expanded(
                      child: SocialLoginButton(
                        provider: 'Google',
                        icon: Icons.g_mobiledata,
                        onPressed: () async {
                          // Google signup logic will be handled by login controller
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SocialLoginButton(
                        provider: 'Kakao',
                        icon: Icons.chat_bubble,
                        backgroundColor: const Color(0xFFFFE812),
                        textColor: Colors.black,
                        onPressed: () async {
                          // Kakao signup logic will be handled by login controller
                        },
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    TextButton(
                      onPressed: () {
                        context.pop();
                      },
                      child: const Text('Login'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordRequirement(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          Icon(
            Icons.circle,
            size: 4,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}