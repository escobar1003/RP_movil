// ─── editar_perfil_style.dart ─── EditarPerfilStyles

import 'package:flutter/material.dart';
import '../styles/colors.dart';

class EditarPerfilStyles {
  static const Color bg = SemanticColors.altBg;
  static const EdgeInsets screenPadding = EdgeInsets.all(20);
  static const EdgeInsets cardPadding = EdgeInsets.all(20);
  static const double cardRadius = 20;
  static const double fieldRadius = 12;
  static const EdgeInsets fieldPadding = EdgeInsets.symmetric(horizontal: 16, vertical: 14);
  static const double buttonHeight = 52;
  static const double buttonRadius = 14;
  static const double formGap = 20;
  static const double buttonGap = 24;
  static const double labelSize = 14;

  static const TextStyle label = TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: GreenColors.veryDark);
  static const TextStyle buttonText = TextStyle(fontSize: 16, fontWeight: FontWeight.w600);
  static const TextStyle appBarTitle = TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white);
}