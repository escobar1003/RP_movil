// ─── gradients.dart ─── AppGradients

import 'package:flutter/material.dart';
import 'colors.dart';

class AppGradients {
  static const LinearGradient pointsCard = LinearGradient(
    colors: [GreenColors.gradientA, GreenColors.gradientB],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient gameCard = LinearGradient(
    colors: [Color(0xFF43A047), Color(0xFF66BB6A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient welcomeBg = LinearGradient(
    colors: [Color(0xFFE8F5E9), Color(0xFFF9FBF7), Color(0xFFFFFFFF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}