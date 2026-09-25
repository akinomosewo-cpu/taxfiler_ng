import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF00C896);
  static const Color primaryDark = Color(0xFF00A07A);
  static const Color primaryLight = Color(0xFF33D4A8);

  static const Color accent = Color(0xFF5E5CE6);

  static const Color success = Color(0xFF30D158);
  static const Color warning = Color(0xFFFFD60A);
  static const Color danger = Color(0xFFFF453A);
  static const Color info = Color(0xFF64D2FF);

  static const Color background = Color(0xFF0C0C0E);
  static const Color surface = Color(0xFF1C1C1E);
  static const Color surfaceElevated = Color(0xFF2C2C2E);
  static const Color surfaceHighest = Color(0xFF3A3A3C);

  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8E8E93);
  static const Color textTertiary = Color(0xFF48484A);

  static const Color border = Color(0xFF38383A);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF00C896), Color(0xFF00A0C4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient dangerGradient = LinearGradient(
    colors: [Color(0xFFFF453A), Color(0xFFFF6961)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1C1C1E), Color(0xFF2C2C2E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppTextStyles {
  AppTextStyles._();

  static TextStyle get displayLarge => GoogleFonts.inter(fontSize: 34, fontWeight: FontWeight.w700, letterSpacing: -0.5, height: 1.2);
  static TextStyle get displayMedium => GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: -0.3, height: 1.25);
  static TextStyle get displaySmall => GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w600, letterSpacing: -0.2, height: 1.3);
  static TextStyle get headlineLarge => GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, letterSpacing: -0.1, height: 1.35);
  static TextStyle get headlineMedium => GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w600, height: 1.4);
  static TextStyle get headlineSmall => GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, height: 1.4);
  static TextStyle get bodyLarge => GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w400, height: 1.5);
  static TextStyle get bodyMedium => GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w400, height: 1.5);
  static TextStyle get bodySmall => GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w400, height: 1.5);
  static TextStyle get labelLarge => GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, letterSpacing: 0.1, height: 1.4);
  static TextStyle get labelMedium => GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.1, height: 1.4);
  static TextStyle get labelSmall => GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.5, height: 1.4);
  static TextStyle get monoLarge => GoogleFonts.jetBrainsMono(fontSize: 32, fontWeight: FontWeight.w700, letterSpacing: -1);
}

class AppTheme {
  AppTheme._();

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
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
          systemOverlayStyle: SystemUiOverlayStyle.light,
          titleTextStyle: AppTextStyles.headlineMedium.copyWith(color: AppColors.textPrimary),
          iconTheme: const IconThemeData(color: AppColors.textPrimary),
        ),
        cardTheme: CardTheme(
          color: AppColors.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          margin: EdgeInsets.zero,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            textStyle: AppTextStyles.headlineSmall,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
        dividerTheme: const DividerThemeData(color: AppColors.border, thickness: 0.5),
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
