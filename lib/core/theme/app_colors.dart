import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color background = Color(0xFF000000); // true OLED black
  static const Color surface = Color(0xFF0D0D0D); // cards
  static const Color surfaceHigh = Color(0xFF1A1A1A); // elevated surfaces
  static const Color border = Color(0xFF2A2A2A); // subtle dividers
  static const Color primary = Color(0xFFFFFFFF); // primary text
  static const Color secondary = Color(0xFF8A8A8A); // secondary text
  static const Color hint = Color(0xFF707070); // placeholder & less important text (improved contrast)
  static const Color accent = Color(0xFFE8E8E8); // interactive accent
  static const Color pinned = Color(0xFFF5C542); // pin icon
  static const Color danger = Color(0xFFFF4545); // delete actions
  static const Color warning = Color(0xFFFF9F43); // archive/archive warning

  static const List<Color> tagColors = [
    Color(0xFF5E8EFF), // blue
    Color(0xFF5ED4A3), // teal
    Color(0xFFF5C542), // amber
    Color(0xFFFF6B6B), // red
    Color(0xFFB57BFF), // purple
    Color(0xFFFF9F43), // orange
    Color(0xFF54D4E0), // cyan
    Color(0xFFFF78C4), // pink
  ];
}
