import 'package:flutter/material.dart';

const double standardPadding = 16.0;

ThemeData appTheme() {
  final ColorScheme colorScheme = ColorScheme.fromSeed(seedColor: Colors.lightBlue);

  return ThemeData(
    colorScheme: colorScheme,
    useMaterial3: true,
    primaryColor: colorScheme.primary,
    scaffoldBackgroundColor: colorScheme.surface,
    textTheme: const TextTheme(
      headlineMedium:
          TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
      bodySmall: TextStyle(fontSize: 16.0),
      bodyLarge: TextStyle(fontSize: 18.0),
      titleMedium: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
      labelLarge: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: colorScheme.onPrimary,
        fontSize: 20.0,
        fontWeight: FontWeight.bold),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: colorScheme.primary,
        textStyle: const TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: colorScheme.primary,
        side: BorderSide(color:colorScheme.primary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        textStyle: const TextStyle (
          fontSize: 14.0,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    cardTheme: CardTheme(
      color: colorScheme.surface,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0.0),
      shadowColor: colorScheme.shadow,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      selectedItemColor: colorScheme.primary,
      unselectedItemColor: colorScheme.onSurfaceVariant,
      backgroundColor: colorScheme.surface,
      elevation: 10,
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal)
    ),
    iconTheme: IconThemeData(
      color: colorScheme.primary,
      size: 24,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colorScheme.onSurfaceVariant,
      contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      border: OutlineInputBorder (
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(),
      ),
      labelStyle: TextStyle (
        color: colorScheme.onSurfaceVariant,
        fontSize: 14.0,
      ),
      hintStyle: TextStyle (
        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
        fontSize: 14.0,
      ),
      errorStyle: const TextStyle(
        color: Colors.red,
        fontSize: 12.0
      ),
    ),
    dialogTheme: DialogTheme (
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      titleTextStyle: TextStyle(
        color: colorScheme.onSurface,
        fontSize: 18.0,
        fontWeight: FontWeight.bold,
      ),
      contentTextStyle: TextStyle(
        color: colorScheme.onSurfaceVariant,
        fontSize: 14.0,
      ),
      backgroundColor: colorScheme.surface,
      elevation: 4,
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.selected)) {
          return colorScheme.primary;
        }
        return colorScheme.onSurfaceVariant;
      }),
      checkColor: WidgetStateProperty.all<Color>(colorScheme.primary),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.selected)) {
          return colorScheme.primary;
        }
        return colorScheme.onSurfaceVariant;
      }),
      trackColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.selected)) {
          return colorScheme.primary.withValues(alpha: 0.5);
        }
        return colorScheme.onSurfaceVariant.withValues(alpha: 0.3);
      }),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: colorScheme.surface,
      contentTextStyle: TextStyle(
        color: colorScheme.onSurface,
        fontSize: 14.0,
      ),
      actionTextColor: colorScheme.primary,
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: colorScheme.onSurface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(4.0),
      ),
      textStyle: TextStyle(
        color: colorScheme.surface,
        fontSize: 12.0,
      ),
    ),
  );
}
