import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_input_field.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/section_header.dart';

import '../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _error;
  String? _success;

  Future<void> _register() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _success = null;
    });

    try {
      final authRepo = ref.read(authRepositoryProvider);

      await authRepo.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      setState(() {
        _success = "Account created successfully!";
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(title: "Create Account"),

                  const SizedBox(height: AppSpacing.xl),

                  AppInputField(controller: _emailController, label: "Email"),

                  const SizedBox(height: AppSpacing.lg),

                  AppInputField(
                    controller: _passwordController,
                    label: "Password",
                    obscureText: true,
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),

                  if (_success != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: Text(
                        _success!,
                        style: const TextStyle(color: Colors.green),
                      ),
                    ),

                  PrimaryButton(
                    label: 'Register',
                    onPressed: _isLoading ? null : _register,
                    isLoading: _isLoading,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
