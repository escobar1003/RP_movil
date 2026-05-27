// ─── buttons.dart ─── AppButtons

import 'package:flutter/material.dart';
import 'colors.dart';

class AppButtons {
  static ButtonStyle get primary => ElevatedButton.styleFrom(
    backgroundColor: AppColors.accent,
    foregroundColor: AppColors.textDark,
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
  );

  static ButtonStyle get darkGreen => ElevatedButton.styleFrom(
    backgroundColor: GreenColors.dark,
    foregroundColor: Colors.white,
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  );

  static ButtonStyle get green => ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
  );

  static ButtonStyle get fullWidth => ElevatedButton.styleFrom(
    minimumSize: const Size(double.infinity, 52),
  );

  static ButtonStyle get fullDarkGreen => ElevatedButton.styleFrom(
    backgroundColor: GreenColors.dark,
    foregroundColor: Colors.white,
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    minimumSize: const Size(double.infinity, 52),
  );
}