import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Warm, soft, light-first palette. A single vibrant brand accent (green)
/// is used sparingly against off-white/pastel surfaces, with generous
/// rounding and soft shadows rather than flat borders.
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF12A870);
  static const Color primaryDark = Color(0xFF0C8A5B);
  static const Color primaryLight = Color(0xFF5CD9A8);

  static const Color accent = Color(0xFF6C5CE6);

  static const Color success = Color(0xFF2FB673);
  static const Color warning = Color(0xFFF5A623);
  static const Color danger = Color(0xFFE8544E);
  static const Color info = Color(0xFF3FA9F5);

  // Soft off-white / pastel canvas.
  static const Color background = Color(0xFFF7F3EC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceElevated = Color(0xFFFDFBF7);
  static const Color surfaceHighest = Color(0xFFF0EAE0);

  static const Color textPrimary = Color(0xFF231F1A);
  static const Color textSecondary = Color(0xFF847C70);
  static const Color textTertiary = Color(0xFFB8AFA1);

  static const Color border = Color(0xFFEDE6D8);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF12A870), Color(0xFF0C8AAE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient dangerGradient = LinearGradient(
    colors: [Color(0xFFE8544E), Color(0xFFF08A5B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF7F3EC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Soft, low-contrast card shadow to replace flat borders.
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: const Color(0xFF231F1A).withValues(alpha: 0.06),
          blurRadius: 24,
          offset: const Offset(0, 10),
          spreadRadius: -6,
        ),
        BoxShadow(
          color: const Color(0xFF231F1A).withValues(alpha: 0.04),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ];
}

class AppTextStyles {
  AppTextStyles._();

  static TextStyle get displayLarge => GoogleFonts.inter(fontSize: 40, fontWeight: FontWeight.w800, letterSpacing: -0.8, height: 1.1);
  static TextStyle get displayMedium => GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -0.6, height: 1.15);
  static TextStyle get displaySmall => GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.w700, letterSpacing: -0.3, height: 1.2);
  static TextStyle get headlineLarge => GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: -0.2, height: 1.3);
  static TextStyle get headlineMedium => GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, height: 1.35);
  static TextStyle get headlineSmall => GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, height: 1.4);
  static TextStyle get bodyLarge => GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w400, height: 1.5);
  static TextStyle get bodyMedium => GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w400, height: 1.5);
  static TextStyle get bodySmall => GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w400, height: 1.5);
  static TextStyle get labelLarge => GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.1, height: 1.4);
  static TextStyle get labelMedium => GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.1, height: 1.4);
  static TextStyle get labelSmall => GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.4, height: 1.4);
  static TextStyle get monoLarge => GoogleFonts.jetBrainsMono(fontSize: 36, fontWeight: FontWeight.w700, letterSpacing: -1);
}

class AppTheme {
  AppTheme._();

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          secondary: AppColors.accent,
          surface: AppColors.surface,
          error: AppColors.danger,
          onPrimary: Colors.white,
          onSurface: AppColors.textPrimary,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.background,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          titleTextStyle: AppTextStyles.headlineMedium.copyWith(color: AppColors.textPrimary),
          iconTheme: const IconThemeData(color: AppColors.textPrimary),
        ),
        cardTheme: CardThemeData(
          color: AppColors.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          margin: EdgeInsets.zero,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            minimumSize: const Size(double.infinity, 58),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            textStyle: AppTextStyles.headlineSmall,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
        dividerTheme: const DividerThemeData(color: AppColors.border, thickness: 1),
        textTheme: TextTheme(
          displayLarge: AppTextStyles.displayLarge.copyWith(color: AppColors.textPrimary),
          displayMedium: AppTextStyles.displayMedium.copyWith(color: AppColors.textPrimary),
          headlineLarge: AppTextStyles.headlineLarge.copyWith(color: AppColors.textPrimary),
          headlineMedium: AppTextStyles.headlineMedium.copyWith(color: AppColors.textPrimary),
          headlineSmall: AppTextStyles.headlineSmall.copyWith(color: AppColors.textPrimary),
          bodyLarge: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimary),
          bodyMedium: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
          bodySmall: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
          labelLarge: AppTextStyles.labelLarge.copyWith(color: AppColors.textPrimary),
          labelMedium: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary),
          labelSmall: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary),
        ),
      );
}

/// A small, colorful pill used for statuses and categories — matches the
/// soft, semantic accent-chip language used across the app.
class AppChip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const AppChip({super.key, required this.label, required this.color, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: color, size: 13),
            const SizedBox(width: 5),
          ],
          Text(label, style: AppTextStyles.labelSmall.copyWith(color: color)),
        ],
      ),
    );
  }
}
