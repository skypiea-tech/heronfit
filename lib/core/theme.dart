import 'package:flutter/material.dart';

class HeronFitTheme {
  static ThemeData lightTheme = ThemeData(
    primaryColor: primary,
    scaffoldBackgroundColor: bgLight,
    fontFamily: 'Poppins',
    textTheme: textTheme,
    colorScheme: ColorScheme.light(
      primary: primary,
      secondary: primaryDark,
      surface: Colors.white,
      onSurface: textPrimary,
      error: error,
      onError: Colors.white,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: primary,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      titleTextStyle: textTheme.titleLarge?.copyWith(color: Colors.white),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      selectedItemColor: primary,
      unselectedItemColor: textMuted,
    ),
  );

  // ✅ Colors
  static const Color primary = Color(0xFF2F27CE);
  static const Color primaryDark = Color(0xFF443DFF);
  static const Color bgLight = Color(0xFFFBFBFE);
  static const Color bgPrimary = Color(0xFFDDD8FF);
  static const Color bgSecondary = Color(0xFFE2E1FF);
  static const Color textDark = Color(0xFF040316);
  static const Color textPrimary = Color(0xFF2C2B3B);
  static const Color textSecondary = Color(0xFF545461);
  static const Color textWhite = Colors.white;
  static const Color textMuted = Color(0xFF737285);
  static const Color success = Color(0xFF81C784);
  static const Color error = Color(0xFFE57373);
  static const Color warning = Color(0xFFFFB74D);
  static const Color info = Color(0xFF4FC3F7);
  static const Color dropShadow = Colors.black26;

  // Define reusable card shadow based on the progress screen style
  static final List<BoxShadow> cardShadow = [
    BoxShadow(
      blurRadius: 40,
      color: Colors.black.withOpacity(0.1), // 10% opacity black
      offset: const Offset(0, 10),
    ),
  ];

  // ✅ Typography (Material Design 3)
  static final TextTheme textTheme = TextTheme(
    displayLarge: const TextStyle(
      fontFamily: 'Poppins',
      fontSize: 57,
      fontWeight: FontWeight.w700, // Bold (w700)
      color: textPrimary,
      letterSpacing: -0.25, // Subtle negative spacing for large display
      height: 1.12, // Line height ~64px
    ),
    displayMedium: const TextStyle(
      fontFamily: 'Poppins',
      fontSize: 45,
      fontWeight: FontWeight.w700, // Bold (w700)
      color: textPrimary,
      letterSpacing: 0,
      height: 1.15, // Line height ~52px
    ),
    displaySmall: const TextStyle(
      fontFamily: 'Poppins',
      fontSize: 36,
      fontWeight: FontWeight.w700, // Bold (w700)
      color: textPrimary,
      letterSpacing: 0,
      height: 1.22, // Line height ~44px
    ),
    headlineLarge: const TextStyle(
      fontFamily: 'Poppins',
      fontSize: 32,
      fontWeight: FontWeight.w800, // ExtraBold (w800)
      color: textPrimary,
      letterSpacing: 0,
      height: 1.25, // Line height ~40px
    ),
    headlineMedium: const TextStyle(
      fontFamily: 'Poppins',
      fontSize: 28,
      fontWeight: FontWeight.w800, // ExtraBold (w800)
      color: textPrimary,
      letterSpacing: 0,
      height: 1.28, // Line height ~36px
    ),
    headlineSmall: const TextStyle(
      fontFamily: 'Poppins',
      fontSize: 24,
      fontWeight: FontWeight.w800, // ExtraBold (w800)
      color: textPrimary,
      letterSpacing: 0,
      height: 1.33, // Line height ~32px
    ),
    titleLarge: const TextStyle(
      fontFamily: 'Poppins',
      fontSize: 20, // Adjusted from 22 to 20 for better scale
      fontWeight: FontWeight.w600, // SemiBold (w600)
      color: textPrimary,
      letterSpacing: 0.1,
      height: 1.4, // Line height ~28px
    ),
    titleMedium: const TextStyle(
      fontFamily: 'Poppins',
      fontSize: 16,
      fontWeight: FontWeight.w600, // SemiBold (w600)
      color: textPrimary,
      letterSpacing: 0.15,
      height: 1.5, // Line height ~24px
    ),
    titleSmall: const TextStyle(
      fontFamily: 'Poppins',
      fontSize: 14,
      fontWeight: FontWeight.w600, // SemiBold (w600)
      color: textPrimary,
      letterSpacing: 0.1,
      height: 1.43, // Line height ~20px
    ),
    bodyLarge: const TextStyle(
      fontFamily: 'Poppins',
      fontSize: 16,
      fontWeight: FontWeight.normal, // Normal (w400)
      color: textPrimary,
      letterSpacing: 0.5, // Standard spacing for body
      height: 1.5, // Line height ~24px
    ),
    bodyMedium: const TextStyle(
      fontFamily: 'Poppins',
      fontSize: 14,
      fontWeight:
          FontWeight
              .normal, // Normal (w400) - Reverted from w600 based on previous feedback
      color: textSecondary,
      letterSpacing: 0.25,
      height: 1.43, // Line height ~20px
    ),
    bodySmall: const TextStyle(
      fontFamily: 'Poppins',
      fontSize: 12,
      fontWeight: FontWeight.normal, // Normal (w400)
      color: textMuted,
      letterSpacing: 0.4,
      height: 1.33, // Line height ~16px
    ),
    labelLarge: const TextStyle(
      fontFamily: 'Poppins',
      fontSize: 14,
      fontWeight: FontWeight.w500, // Medium (w500)
      color: textPrimary,
      letterSpacing: 0.1,
      height: 1.43, // Line height ~20px
    ),
    labelMedium: const TextStyle(
      fontFamily: 'Poppins',
      fontSize: 12,
      fontWeight:
          FontWeight
              .w500, // Medium (w500) - Reverted from w600 based on previous feedback
      color: textSecondary,
      letterSpacing: 0.5,
      height: 1.33, // Line height ~16px
    ),
    labelSmall: const TextStyle(
      fontFamily: 'Poppins',
      fontSize: 11,
      fontWeight:
          FontWeight
              .w500, // Medium (w500) - Changed from normal for consistency
      color: textMuted,
      letterSpacing: 0.5,
      height: 1.45, // Line height ~16px
    ),
  );
}
