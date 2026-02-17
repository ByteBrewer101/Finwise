import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_radius.dart';

import '../providers/auth_provider.dart';
import '../../../../core/router/app_routes.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _error;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authRepo = ref.read(authRepositoryProvider);

      await authRepo.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    } catch (e) {
      setState(() {
        _error = "Invalid email or password";
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome Back 👋',
                    style: AppTextStyles.headingLarge,
                  ),

                  const SizedBox(height: AppSpacing.sm),

                   Text(
                    'Login to continue managing your finances',
                    style: AppTextStyles.body,
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  /// Email
                  TextField(
                    controller: _emailController,
                    decoration: _inputDecoration('Email'),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  /// Password
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: _inputDecoration('Password'),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: Text(
                        _error!,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.danger,
                        ),
                      ),
                    ),

                  /// Primary Login Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        minimumSize: const Size(double.infinity, 52),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppRadius.lg),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Login',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  /// Google Login
                  TextButton(
                    onPressed: _isLoading
                        ? null
                        : () async {
                            final authRepo =
                                ref.read(authRepositoryProvider);
                            await authRepo.signInWithGoogle();
                          },
                    child: const Text('Continue with Google'),
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  /// Register
                  Center(
                    child: TextButton(
                      onPressed: () {
                        context.go(AppRoutes.register);
                      },
                      child: const Text('Create an account'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: AppColors.card,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        borderSide: const BorderSide(color: AppColors.divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        borderSide: const BorderSide(color: AppColors.divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
    );
  }
}
