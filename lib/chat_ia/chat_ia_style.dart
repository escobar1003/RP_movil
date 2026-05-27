// ─── chat_ia_style.dart ─── ChatStyles

import 'package:flutter/material.dart';

class ChatStyles {
  static const Color userBubble = Color(0xFFC8E6C9);
  static const Color assistantBubble = Color(0xFFEEEEEE);
  static const Color messageText = Colors.black87;

  static const EdgeInsets screenPadding = EdgeInsets.all(16.0);
  static const EdgeInsets bubbleMargin = EdgeInsets.symmetric(vertical: 6.0);
  static const EdgeInsets bubblePadding = EdgeInsets.all(12.0);
  static const EdgeInsets inputPadding = EdgeInsets.all(8.0);
  static const EdgeInsets inputContentPadding = EdgeInsets.symmetric(horizontal: 16.0);
  static const EdgeInsets loadingPadding = EdgeInsets.symmetric(vertical: 8.0);

  static const double inputRadius = 24.0;
  static const double bubbleRadius = 12.0;
  static const double messageFontSize = 16.0;
  static const double inputGap = 8.0;
}