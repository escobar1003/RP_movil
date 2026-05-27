// ─── theme.dart ─── AppTheme (ThemeData global)

import 'package:flutter/material.dart';
import 'colors.dart';

class AppTheme {
  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.background,
    colorSchemeSeed: AppColors.primary,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: AppColors.textDark),
      titleTextStyle: TextStyle(
        color: AppColors.textDark,
        fontWeight: FontWeight.w700,
        fontSize: 17,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}