import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';

import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../data/auth/auth_repository.dart';
import '../widgets/page_transitions.dart';
import 'dashboard_page.dart';
import 'signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, this.authRepository});

  final AuthRepository? authRepository;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final AuthRepository _auth = widget.authRepository ?? AuthRepository();
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscure = true;
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _submitting = true;
      _error = null;
    });

    final ok = await _auth.logIn(email: _emailController.text, password: _passwordController.text);

    if (!mounted) return;
    if (!ok) {
      setState(() {
        _submitting = false;
        _error = 'Incorrect email or password.';
      });
      return;
    }

    Navigator.of(context).pushReplacement(
      FadeSlidePageRoute(builder: (_) => const DashboardPage()),
    );
  }

  Future<void> _continueAsGuest() async {
    setState(() => _submitting = true);
    await _auth.continueAsGuest();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      FadeSlidePageRoute(builder: (_) => const DashboardPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Gap(24),
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(Icons.receipt_long_rounded, color: Colors.white, size: 28),
                ).animate().fadeIn().slideY(begin: 0.15),
                const Gap(24),
                Text('Welcome back', style: AppTextStyles.displaySmall.copyWith(color: AppColors.textPrimary))
                    .animate(delay: 60.ms)
                    .fadeIn()
                    .slideY(begin: 0.15),
                const Gap(6),
                Text(
                  'Log in to keep your ${AppConstants.appName} data private to you.',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                ).animate(delay: 100.ms).fadeIn(),
                const Gap(32),

                Text('Email', style: AppTextStyles.labelLarge.copyWith(color: AppColors.textPrimary)),
                const Gap(8),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  decoration: const InputDecoration(hintText: 'you@example.com'),
                  validator: (value) {
                    final v = value?.trim() ?? '';
                    if (v.isEmpty) return 'Enter your email';
                    if (!v.contains('@') || !v.contains('.')) return 'Enter a valid email';
                    return null;
                  },
                ).animate(delay: 140.ms).fadeIn().slideY(begin: 0.1),
                const Gap(18),

                Text('Password', style: AppTextStyles.labelLarge.copyWith(color: AppColors.textPrimary)),
                const Gap(8),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscure,
                  autofillHints: const [AutofillHints.password],
                  decoration: InputDecoration(
                    hintText: 'Your password',
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: AppColors.textSecondary),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: (value) => (value == null || value.isEmpty) ? 'Enter your password' : null,
                  onFieldSubmitted: (_) => _submit(),
                ).animate(delay: 180.ms).fadeIn().slideY(begin: 0.1),

                if (_error != null) ...[
                  const Gap(14),
                  Text(_error!, style: AppTextStyles.bodySmall.copyWith(color: AppColors.danger)).animate().fadeIn().shake(hz: 4),
                ],

                const Gap(28),
                ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  child: _submitting
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
                        )
                      : const Text('Log In'),
                ).animate(delay: 220.ms).fadeIn(),
                const Gap(14),
                OutlinedButton(
                  onPressed: _submitting ? null : _continueAsGuest,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.border),
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text('Continue as Guest'),
                ).animate(delay: 260.ms).fadeIn(),
                const Gap(24),
                Center(
                  child: TextButton(
                    onPressed: _submitting
                        ? null
                        : () => Navigator.of(context).push(
                              FadeSlidePageRoute(builder: (_) => SignUpPage(authRepository: widget.authRepository)),
                            ),
                    child: Text.rich(
                      TextSpan(
                        text: "Don't have an account? ",
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                        children: [
                          TextSpan(text: 'Sign up', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ),
                ).animate(delay: 300.ms).fadeIn(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
