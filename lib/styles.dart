import 'package:flutter/material.dart';

const double standardPadding = 16.0;

class AppColors {
  static const Color primary = Colors.deepPurple;
  static const Color primaryVariant = Colors.deepPurpleAccent;
  static const Color secondary = Colors.teal;
  static const Color success = Colors.green;
  static const Color error = Colors.red;
  static const Color grey = Colors.grey;
}

ThemeData appTheme() {
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
    useMaterial3: true,
    textTheme: const TextTheme(
      headlineMedium:
          TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
      bodySmall: TextStyle(fontSize: 16.0),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
    ),
  );
}