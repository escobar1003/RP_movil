// ─── main_navigation_style.dart ─── NavStyles

import 'package:flutter/material.dart';
import '../styles/colors.dart';

class NavStyles {
  static const double fabElevation = 4;
  static const double fabIconSize = 30;
  static const double bottomAppBarElevation = 8;
  static const double bottomAppBarHeight = 70;
  static const double notchMargin = 8;
  static const double navItemPadding = 4;
  static const double navIconSize = 18;
  static const double navLabelFontSize = 9;
  static const double navIconLabelGap = 1;

  static Color navColor(bool active) => active ? AppColors.primary : AppColors.textLight;
  static FontWeight navWeight(bool active) => active ? FontWeight.w600 : FontWeight.w500;
}