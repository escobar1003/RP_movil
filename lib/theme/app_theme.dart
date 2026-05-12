// lib/theme/app_theme.dart

import 'package:flutter/material.dart';

class AppColors {
  static const primary    = Color(0xFF3A7D44);   // verde oscuro
  static const secondary  = Color(0xFF6AB04C);   // verde medio
  static const accent     = Color(0xFFFFCC00);   // amarillo botón
  static const background = Color(0xFFF4F9F4);   // fondo muy claro
  static const card       = Colors.white;
  static const textDark   = Color(0xFF1C2B1E);
  static const textMid    = Color(0xFF5A7060);
  static const textLight  = Color(0xFF9DB8A0);
  static const green100   = Color(0xFFE8F5E9);
  static const yellow100  = Color(0xFFFFFDE7);
}

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