// ─── decoration.dart ─── AppShadows, AppRadius, CardDecoration, HeaderDecoration, BadgeDecoration, IconContainerDecoration, FilterChipDecoration, MarkerDecoration, RoundedIconContainer

import 'package:flutter/material.dart';
import 'colors.dart';

class AppShadows {
  static List<BoxShadow> get card => [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 10,
      offset: const Offset(0, 3),
    ),
  ];
  static List<BoxShadow> get cardLight => [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];
  static List<BoxShadow> get soft => [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 12,
      offset: const Offset(0, 5),
    ),
  ];
  static List<BoxShadow> get header => [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 18,
      offset: const Offset(0, 8),
    ),
  ];
  static List<BoxShadow> get panel => [
    BoxShadow(
      color: Colors.black.withOpacity(0.12),
      blurRadius: 20,
      offset: const Offset(0, -4),
    ),
  ];
  static List<BoxShadow> get button => [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 8,
    ),
  ];
}

class AppRadius {
  static const sm   = 8.0;
  static const md   = 10.0;
  static const lg   = 12.0;
  static const xl   = 14.0;
  static const big  = 16.0;
  static const huge = 18.0;
  static const mass = 20.0;
  static const big2 = 24.0;
  static const big3 = 28.0;
  static const mass2 = 32.0;
  static const round = 50.0;
}

class CardDecoration {
  static BoxDecoration get white => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(AppRadius.big),
    boxShadow: AppShadows.card,
  );

  static BoxDecoration whiteSoft({double radius = AppRadius.huge}) => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(radius),
    boxShadow: AppShadows.soft,
  );

  static BoxDecoration get cardLight => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(AppRadius.huge),
    boxShadow: AppShadows.cardLight,
  );
}

class HeaderDecoration {
  static BoxDecoration get darkGreen => const BoxDecoration(
    color: GreenColors.dark,
    borderRadius: BorderRadius.only(
      bottomLeft: Radius.circular(AppRadius.big3),
      bottomRight: Radius.circular(AppRadius.big3),
    ),
  );
}

class BadgeDecoration {
  static BoxDecoration green({double radius = AppRadius.mass}) => BoxDecoration(
    color: GreenColors.lightBg,
    borderRadius: BorderRadius.circular(radius),
  );

  static BoxDecoration material({required Color bg}) => BoxDecoration(
    color: bg,
    borderRadius: BorderRadius.circular(AppRadius.mass),
  );
}

class IconContainerDecoration {
  static BoxDecoration small({required Color color}) => BoxDecoration(
    color: color.withOpacity(0.1),
    borderRadius: BorderRadius.circular(AppRadius.md),
  );

  static BoxDecoration medium({required Color color, double size = 52}) => BoxDecoration(
    color: color.withOpacity(0.1),
    borderRadius: BorderRadius.circular(AppRadius.xl),
  );
}

class FilterChipDecoration {
  static BoxDecoration active = BoxDecoration(
    color: GreenColors.dark,
    borderRadius: BorderRadius.circular(AppRadius.mass),
    boxShadow: AppShadows.cardLight,
  );

  static BoxDecoration inactive = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(AppRadius.mass),
    boxShadow: AppShadows.cardLight,
  );
}

class InputDecoration {
  static BoxDecoration get white => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(AppRadius.xl),
  );

  static BoxDecoration whiteRounded(double radius) => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(radius),
  );
}

class MarkerDecoration {
  static BoxDecoration active = BoxDecoration(
    color: AppColors.primary,
    borderRadius: BorderRadius.circular(AppRadius.xl),
    border: Border.all(color: Colors.white, width: 2.5),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.2),
        blurRadius: 8,
        offset: const Offset(0, 3),
      ),
    ],
  );

  static BoxDecoration inactive = BoxDecoration(
    color: AppColors.secondary,
    borderRadius: BorderRadius.circular(AppRadius.xl),
    border: Border.all(color: Colors.white, width: 2.5),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.2),
        blurRadius: 8,
        offset: const Offset(0, 3),
      ),
    ],
  );
}

class RoundedIconContainer {
  static BoxDecoration green = BoxDecoration(
    color: GreenColors.dark,
    borderRadius: BorderRadius.circular(AppRadius.xl),
  );
}

