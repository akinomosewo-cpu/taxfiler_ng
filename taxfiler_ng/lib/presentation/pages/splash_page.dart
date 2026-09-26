import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../data/auth/auth_repository.dart';
import '../widgets/page_transitions.dart';
import 'login_page.dart';
import 'dashboard_page.dart';

/// Animated brand reveal shown briefly on cold start, then routes to the
/// dashboard (if already logged in) or the login screen.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key, this.authRepository, this.minDuration = const Duration(milliseconds: 1300)});

  final AuthRepository? authRepository;
  final Duration minDuration;

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _fade;
  late final AuthRepository _auth;

  @override
  void initState() {
    super.initState();
    _auth = widget.authRepository ?? AuthRepository();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _scale = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _fade = CurvedAnimation(parent: _controller, curve: const Interval(0, 0.6, curve: Curves.easeOut));
    _controller.forward();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final started = DateTime.now();
    final loggedIn = await _auth.isLoggedIn();

    final elapsed = DateTime.now().difference(started);
    final remaining = widget.minDuration - elapsed;
    if (remaining > Duration.zero) {
      await Future.delayed(remaining);
    }
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      FadeSlidePageRoute(
        builder: (_) => loggedIn ? const DashboardPage() : const LoginPage(),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Opacity(
              opacity: _fade.value,
              child: Transform.scale(scale: 0.85 + (0.15 * _scale.value), child: child),
            );
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.32),
                      blurRadius: 32,
                      offset: const Offset(0, 16),
                      spreadRadius: -8,
                    ),
                  ],
                ),
                child: const Icon(Icons.receipt_long_rounded, color: Colors.white, size: 42),
              ),
              const Gap(20),
              Text(AppConstants.appName, style: AppTextStyles.displaySmall.copyWith(color: AppColors.textPrimary)),
              const Gap(6),
              Text('Your Nigerian tax assistant', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }
}
