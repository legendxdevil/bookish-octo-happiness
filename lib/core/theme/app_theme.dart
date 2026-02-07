import 'package:flutter/material.dart';

/// Light theme configuration for Antigravity
final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: const ColorScheme.light(
    primary: Color(0xFF6366F1),
    onPrimary: Colors.white,
    primaryContainer: Color(0xFFE0E7FF),
    onPrimaryContainer: Color(0xFF312E81),
    secondary: Color(0xFF10B981),
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFFD1FAE5),
    onSecondaryContainer: Color(0xFF064E3B),
    tertiary: Color(0xFFF59E0B),
    onTertiary: Colors.white,
    tertiaryContainer: Color(0xFFFEF3C7),
    onTertiaryContainer: Color(0xFF92400E),
    error: Color(0xFFEF4444),
    onError: Colors.white,
    surface: Colors.white,
    onSurface: Color(0xFF1F2937),
    surfaceVariant: Color(0xFFF3F4F6),
    onSurfaceVariant: Color(0xFF6B7280),
    outline: Color(0xFFE5E7EB),
    shadow: Color(0x1F000000),
  ),
  scaffoldBackgroundColor: const Color(0xFFF9FAFB),
  fontFamily: 'Inter',
  textTheme: const TextTheme(
    displayLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      letterSpacing: -0.5,
    ),
    displayMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      letterSpacing: -0.5,
    ),
    displaySmall: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.5,
    ),
    headlineLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w600,
    ),
    headlineMedium: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
    headlineSmall: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
    ),
    titleLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
    ),
    titleMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
    titleSmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.normal,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.normal,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.normal,
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
    ),
    labelSmall: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w500,
    ),
  ),
  cardTheme: CardThemeData(
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    color: Colors.white,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      side: const BorderSide(color: Color(0xFFE5E7EB)),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      textStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFFF3F4F6),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    hintStyle: const TextStyle(
      color: Color(0xFF9CA3AF),
      fontSize: 14,
    ),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Colors.white,
    selectedItemColor: Color(0xFF6366F1),
    unselectedItemColor: Color(0xFF9CA3AF),
    type: BottomNavigationBarType.fixed,
    elevation: 8,
    selectedLabelStyle: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
    ),
    unselectedLabelStyle: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
    ),
  ),
  appBarTheme: const AppBarTheme(
    elevation: 0,
    centerTitle: true,
    backgroundColor: Colors.transparent,
    foregroundColor: Color(0xFF1F2937),
    titleTextStyle: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: Color(0xFF1F2937),
    ),
  ),
  dividerTheme: const DividerThemeData(
    color: Color(0xFFE5E7EB),
    thickness: 1,
    space: 1,
  ),
  chipTheme: ChipThemeData(
    backgroundColor: const Color(0xFFF3F4F6),
    selectedColor: const Color(0xFFE0E7FF),
    labelStyle: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
    ),
    secondaryLabelStyle: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
    ),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  ),
  dialogTheme: DialogThemeData(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    backgroundColor: Colors.white,
    elevation: 8,
  ),
  snackBarTheme: SnackBarThemeData(
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    contentTextStyle: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
  ),
);
