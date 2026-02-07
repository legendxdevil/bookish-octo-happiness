import 'package:flutter/material.dart';

/// Dark theme configuration for Antigravity
final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFF818CF8),
    onPrimary: Color(0xFF1E1B4B),
    primaryContainer: Color(0xFF4338CA),
    onPrimaryContainer: Color(0xFFE0E7FF),
    secondary: Color(0xFF34D399),
    onSecondary: Color(0xFF064E3B),
    secondaryContainer: Color(0xFF065F46),
    onSecondaryContainer: Color(0xFFD1FAE5),
    tertiary: Color(0xFFFBBF24),
    onTertiary: Color(0xFF92400E),
    tertiaryContainer: Color(0xFFB45309),
    onTertiaryContainer: Color(0xFFFEF3C7),
    error: Color(0xFFF87171),
    onError: Color(0xFF7F1D1D),
    surface: Color(0xFF111827),
    onSurface: Color(0xFFF9FAFB),
    surfaceVariant: Color(0xFF1F2937),
    onSurfaceVariant: Color(0xFF9CA3AF),
    outline: Color(0xFF374151),
    shadow: Color(0x3F000000),
  ),
  scaffoldBackgroundColor: const Color(0xFF0B0F19),
  fontFamily: 'Inter',
  textTheme: const TextTheme(
    displayLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      letterSpacing: -0.5,
      color: Color(0xFFF9FAFB),
    ),
    displayMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      letterSpacing: -0.5,
      color: Color(0xFFF9FAFB),
    ),
    displaySmall: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.5,
      color: Color(0xFFF9FAFB),
    ),
    headlineLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: Color(0xFFF9FAFB),
    ),
    headlineMedium: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: Color(0xFFF9FAFB),
    ),
    headlineSmall: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: Color(0xFFF9FAFB),
    ),
    titleLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: Color(0xFFF9FAFB),
    ),
    titleMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: Color(0xFFF9FAFB),
    ),
    titleSmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: Color(0xFFF9FAFB),
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: Color(0xFFE5E7EB),
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: Color(0xFFE5E7EB),
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.normal,
      color: Color(0xFFE5E7EB),
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: Color(0xFFE5E7EB),
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: Color(0xFFE5E7EB),
    ),
    labelSmall: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: Color(0xFFE5E7EB),
    ),
  ),
  cardTheme: CardThemeData(
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    color: const Color(0xFF1F2937),
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
      side: const BorderSide(color: Color(0xFF374151)),
      foregroundColor: const Color(0xFFF9FAFB),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      foregroundColor: const Color(0xFF818CF8),
      textStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF1F2937),
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
      borderSide: const BorderSide(color: Color(0xFF818CF8), width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFF87171), width: 1),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFF87171), width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    hintStyle: const TextStyle(
      color: Color(0xFF6B7280),
      fontSize: 14,
    ),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Color(0xFF111827),
    selectedItemColor: Color(0xFF818CF8),
    unselectedItemColor: Color(0xFF6B7280),
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
    foregroundColor: Color(0xFFF9FAFB),
    titleTextStyle: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: Color(0xFFF9FAFB),
    ),
  ),
  dividerTheme: const DividerThemeData(
    color: Color(0xFF374151),
    thickness: 1,
    space: 1,
  ),
  chipTheme: ChipThemeData(
    backgroundColor: const Color(0xFF1F2937),
    selectedColor: const Color(0xFF4338CA),
    labelStyle: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: Color(0xFFE5E7EB),
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
    backgroundColor: const Color(0xFF1F2937),
    elevation: 8,
  ),
  snackBarTheme: SnackBarThemeData(
    behavior: SnackBarBehavior.floating,
    backgroundColor: const Color(0xFF1F2937),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    contentTextStyle: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: Color(0xFFF9FAFB),
    ),
  ),
);
