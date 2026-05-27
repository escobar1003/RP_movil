// ─── login_style.dart ─── LoginStyles

import 'package:flutter/material.dart';
import '../styles/colors.dart';

class LoginStyles {
  static const EdgeInsets screenPadding = EdgeInsets.all(28);
  static const EdgeInsets fieldPadding = EdgeInsets.symmetric(vertical: 16, horizontal: 16);

  static const TextStyle title = TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textDark);
  static const TextStyle subtitle = TextStyle(color: AppColors.textMid, fontSize: 14);
  static const TextStyle label = TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textMid);
  static const TextStyle hint = TextStyle(color: AppColors.textLight);

  static const double buttonHeight = 52;
  static const double fieldRadius = 12;
  static const double iconSize = 20;

  static const double gapTitle = 20;
  static const double gapTitleSubtitle = 6;
  static const double gapBeforeField = 36;
  static const double gapLabelField = 6;
  static const double gapBetweenFields = 18;
  static const double gapBeforeButton = 36;
}