import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';

import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../data/auth/auth_repository.dart';
import '../widgets/page_transitions.dart';
import 'dashboard_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key, this.authRepository});

  final AuthRepository? authRepository;

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  late final AuthRepository _auth = widget.authRepository ?? AuthRepository();
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscure = true;
  bool _submitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);

    await _auth.signUp(email: _emailController.text, password: _passwordController.text);

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      FadeSlidePageRoute(builder: (_) => const DashboardPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text('Create Account', style: AppTextStyles.headlineMedium.copyWith(color: AppColors.textPrimary)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Set up ${AppConstants.appName}', style: AppTextStyles.displaySmall.copyWith(color: AppColors.textPrimary))
                    .animate()
                    .fadeIn()
                    .slideY(begin: 0.15),
                const Gap(6),
                Text(
                  'Your income and tax details stay on this device — nothing is uploaded.',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                ).animate(delay: 40.ms).fadeIn(),
                const Gap(32),

                Text('Email', style: AppTextStyles.labelLarge.copyWith(color: AppColors.textPrimary)),
                const Gap(8),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.newUsername],
                  decoration: const InputDecoration(hintText: 'you@example.com'),
                  validator: (value) {
                    final v = value?.trim() ?? '';
                    if (v.isEmpty) return 'Enter your email';
                    if (!v.contains('@') || !v.contains('.')) return 'Enter a valid email';
                    return null;
                  },
                ).animate(delay: 80.ms).fadeIn().slideY(begin: 0.1),
                const Gap(18),

                Text('Password', style: AppTextStyles.labelLarge.copyWith(color: AppColors.textPrimary)),
                const Gap(8),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscure,
                  autofillHints: const [AutofillHints.newPassword],
                  decoration: InputDecoration(
                    hintText: 'At least 6 characters',
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: AppColors.textSecondary),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Enter a password';
                    if (value.length < 6) return 'Use at least 6 characters';
                    return null;
                  },
                ).animate(delay: 120.ms).fadeIn().slideY(begin: 0.1),
                const Gap(18),

                Text('Confirm Password', style: AppTextStyles.labelLarge.copyWith(color: AppColors.textPrimary)),
                const Gap(8),
                TextFormField(
                  controller: _confirmController,
                  obscureText: _obscure,
                  decoration: const InputDecoration(hintText: 'Re-enter your password'),
                  validator: (value) => value != _passwordController.text ? 'Passwords do not match' : null,
                  onFieldSubmitted: (_) => _submit(),
                ).animate(delay: 160.ms).fadeIn().slideY(begin: 0.1),

                const Gap(28),
                ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  child: _submitting
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
                        )
                      : const Text('Create Account'),
                ).animate(delay: 200.ms).fadeIn(),
                const Gap(20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
