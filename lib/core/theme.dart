import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// All colours live here. Never hardcode a colour inside a screen.
class AppColors {
  static const teal = Color(0xFF0F766E);
  static const tealBg = Color(0xFFD8F0EC);
  static const ink = Color(0xFF16253A);
  static const mute = Color(0xFF5E6B7C);
  static const line = Color(0xFFE1E6EC);
  static const bg = Color(0xFFF7F8FA);
  static const amber = Color(0xFF7A4F0B);
  static const amberBg = Color(0xFFFBEBC8);
  static const red = Color(0xFF8A2E26);
  static const redBg = Color(0xFFF8DAD6);
}

ThemeData buildTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.teal),
    scaffoldBackgroundColor: AppColors.bg,
  );
  final border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: const BorderSide(color: AppColors.line),
  );
  return base.copyWith(
    textTheme: ThemeData.light().textTheme.apply(
      bodyColor: AppColors.ink, displayColor: AppColors.ink),
      
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.bg,
      elevation: 0,
      scrolledUnderElevation: 0,
      foregroundColor: AppColors.ink,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: border,
      enabledBorder: border,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
  );
}
