// ─── text_styles.dart ─── TitleStyles, BodyStyles, LightText, NumberStyles

import 'package:flutter/material.dart';
import 'colors.dart';

class TitleStyles {
  static const h1 = TextStyle(
    fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.textDark, height: 1.25,
  );
  static const h2 = TextStyle(
    fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textDark,
  );
  static const h3 = TextStyle(
    fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textDark,
  );
  static const section = TextStyle(
    fontWeight: FontWeight.w800, fontSize: 17, color: AppColors.textDark,
  );
  static const cardTitle = TextStyle(
    fontSize: 15, fontWeight: FontWeight.bold, color: GreenColors.veryDark,
  );
}

class BodyStyles {
  static const body = TextStyle(
    fontSize: 14, color: AppColors.textMid,
  );
  static const bodySmall = TextStyle(
    fontSize: 13, color: AppColors.textMid,
  );
  static const caption = TextStyle(
    fontSize: 12, color: AppColors.textLight,
  );
  static const label = TextStyle(
    fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textMid,
  );
}

class LightText {
  static const title = TextStyle(
    color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold,
  );
  static const titleSm = TextStyle(
    color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold,
  );
  static const subtitle = TextStyle(
    color: Colors.white70, fontSize: 14,
  );
  static const subtitleSm = TextStyle(
    color: Colors.white70, fontSize: 13,
  );
  static const body = TextStyle(
    color: Colors.white, fontSize: 14,
  );
  static const statValue = TextStyle(
    color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold,
  );
  static const statLabel = TextStyle(
    color: Colors.white70, fontSize: 12,
  );
}

class NumberStyles {
  static const pointsValue = TextStyle(
    color: Colors.white, fontSize: 38, fontWeight: FontWeight.w900,
  );
  static const bigValue = TextStyle(
    fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.primary,
  );
}
