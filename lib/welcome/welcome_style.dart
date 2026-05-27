// ─── welcome_style.dart ─── WelcomeStyles

import 'package:flutter/material.dart';
import '../styles/colors.dart';

class WelcomeStyles {
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(horizontal: 28);

  static const TextStyle title = TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.textDark, height: 1.25);
  static const TextStyle subtitle = TextStyle(fontSize: 15, color: AppColors.textMid, height: 1.5);
  static const TextStyle link = TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 15);

  static const double buttonHeight = 52;
  static const double imageRatio = 0.55;

  static const double gapImageText = 24;
  static const double gapTitleSubtitle = 12;
  static const double gapButtonLink = 14;
  static const double gapBottom = 24;

  static const double circleTopRight = 260;
  static const double circleTopLeft = 150;
  static const double circleBottomLeft = 200;
  static const double circleTopRightOpacity = 0.12;
  static const double circleTopLeftOpacity = 0.08;
  static const double circleBottomLeftOpacity = 0.07;
}