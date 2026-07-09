import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Primary — Verde agropecuario (oklch 0.52 0.12 150)
  static const Color primary = Color(0xFF3D8B5E);
  static const Color primaryLight = Color(0xFFEAF7EE);
  static const Color primaryForeground = Color(0xFFF8FDF9);

  // Background
  static const Color background = Color(0xFFF8FDF8);
  static const Color card = Color(0xFFF2F9F3);
  static const Color cardForeground = Color(0xFF1E3824);

  // Foreground
  static const Color foreground = Color(0xFF1E3824);
  static const Color mutedForeground = Color(0xFF7A9980);
  static const Color muted = Color(0xFFF0F7F1);

  // Secondary
  static const Color secondary = Color(0xFFE8F4EA);
  static const Color secondaryForeground = Color(0xFF3A6645);

  // Border
  static const Color border = Color(0xFFDCEEDF);

  // Status colors
  static const Color success = Color(0xFF3D8B5E);
  static const Color successBg = Color(0xFFEAF7EE);
  static const Color successLight = Color(0x1F3D8B5E);

  static const Color destructive = Color(0xFFD0412D);
  static const Color destructiveBg = Color(0xFFFFF1EE);
  static const Color destructiveLight = Color(0x1FD0412D);

  static const Color info = Color(0xFF3B6FD4);
  static const Color infoBg = Color(0xFFEFF3FD);
  static const Color infoLight = Color(0x1F3B6FD4);

  static const Color warning = Color(0xFFCA8A04);
  static const Color warningBg = Color(0xFFFFFBEB);

  // Specific scene colors (corral)
  static const Color sky1 = Color(0xFFCFE8F5);
  static const Color sky2 = Color(0xFFEAF4EA);
  static const Color grass1 = Color(0xFF7FB069);
  static const Color grass2 = Color(0xFF5F9E57);
  static const Color grass3 = Color(0xFF6BA85F);
  static const Color wood = Color(0xFF9B7B53);
  static const Color woodDark = Color(0xFF8A6A45);
  static const Color metal = Color(0xFF9AA3AB);
  static const Color metalLight = Color(0xFFC9D0D6);
  static const Color grain = Color(0xFFE0B34D);
  static const Color grainDark = Color(0xFFC8952F);
  static const Color waterColor = Color(0xFF3B6FD4);
}

class AppTheme {
  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.primary,
        onPrimary: AppColors.primaryForeground,
        secondary: AppColors.secondary,
        onSecondary: AppColors.secondaryForeground,
        error: AppColors.destructive,
        onError: Colors.white,
        surface: AppColors.card,
        onSurface: AppColors.foreground,
        surfaceContainerHighest: AppColors.muted,
        outline: AppColors.border,
        outlineVariant: AppColors.border,
        tertiary: AppColors.info,
        onTertiary: Colors.white,
      ),
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: GoogleFonts.inter().fontFamily,
    );

    return base.copyWith(
      textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
        bodyColor: AppColors.foreground,
        displayColor: AppColors.foreground,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.card,
        foregroundColor: AppColors.foreground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.transparent,
        titleTextStyle: GoogleFonts.inter(
          color: AppColors.foreground,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        toolbarHeight: 64,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.card,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.mutedForeground,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.primaryForeground,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.foreground,
          side: const BorderSide(color: AppColors.border, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        space: 0,
        thickness: 1,
      ),
    );
  }
}
