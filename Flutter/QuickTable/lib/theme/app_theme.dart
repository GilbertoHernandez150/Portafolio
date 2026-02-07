import 'package:flutter/material.dart';

class AppTheme {
  // COLORES PRINCIPALES
  static const Color primaryBlue = Color(0xFF0A4D8C);
  static const Color secondaryBlue = Color(0xFF0A7DD8);
  static const Color accentBlue = Color(0xFF4DB7F5);
  static const Color softWhite = Color(0xFFF5F9FF);

  // GRADIENTE PRINCIPAL
  static const LinearGradient mainGradient = LinearGradient(
    colors: [primaryBlue, secondaryBlue],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ---------------------------
  // 🔵 **TEMA CLARO**
  // ---------------------------
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: softWhite,

    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: primaryBlue,
      foregroundColor: Colors.white,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      labelStyle: TextStyle(color: primaryBlue, fontWeight: FontWeight.w500),
      contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: primaryBlue.withOpacity(0.4), width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: primaryBlue, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: EdgeInsets.symmetric(vertical: 16),
        textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
    ),

    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 3,
      surfaceTintColor: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    ),

    iconTheme: const IconThemeData(
      color: primaryBlue,
      size: 26,
    ),

    textTheme: const TextTheme(
      bodyLarge: TextStyle(fontSize: 18, color: Colors.black87),
      bodyMedium: TextStyle(fontSize: 16, color: Colors.black87),
      titleLarge: TextStyle(
        fontSize: 22,
        color: primaryBlue,
        fontWeight: FontWeight.bold,
      ),
    ),
  );

  // ---------------------------
  // 🌙 **TEMA OSCURO**
  // ---------------------------
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryBlue,
      brightness: Brightness.dark,
    ),
  );
}
