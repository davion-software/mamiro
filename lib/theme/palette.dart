import 'package:flutter/material.dart';

import 'package:mamiro/core/medication.dart';

/// Sky-and-coral palette: cobalt for actions and headings, coral for what
/// needs attention, on a pale sky gradient with white cards.
abstract final class MamiroPalette {
  static const fontFamily = 'PlusJakartaSans';

  // Screen background gradient, top to bottom, plus a blush aura.
  static const skyTop = Color(0xFFF4F5F9);
  static const skyMid = Color(0xFFEEF3FA);
  static const skyBottom = Color(0xFFC5E0F5);
  static const blushAura = Color(0xFFF6E1E9);

  static const surface = Color(0xFFFFFFFF);
  static const surfaceMuted = Color(0xFFF2F5F9);
  static const line = Color(0xFFE6EBF2);

  /// Borders that identify a control (fields, chips, unselected options):
  /// at least 3:1 against white and the top of the sky.
  static const outlineStrong = Color(0xFF858E9E);

  static const ink = Color(0xFF1B1B1F);

  /// Secondary text; 5:1 even on the bottom of the sky gradient.
  static const inkSoft = Color(0xFF545966);

  /// Headings and primary actions: 5:1 on every background, and white
  /// text on it is 6.8:1.
  static const cobalt = Color(0xFF2C55B8);
  static const cobaltMist = Color(0xFFDCE6F8);

  /// Fills and large icons only; white text on it is too faint.
  static const coral = Color(0xFFEE8560);

  /// Coral for text and small marks: 4.9:1 even on the bottom of the sky
  /// and on [coralMist].
  static const coralDeep = Color(0xFF9C3F1A);

  /// Coral buttons and chips carry white text, so they use a deeper coral:
  /// white is 5:1 on the lighter top of the gradient.
  static const coralButtonTop = Color(0xFFBC4D24);
  static const coralButtonBottom = Color(0xFFA9431C);

  /// Coral for thin graphics such as the progress ring (3.9:1).
  static const coralStrong = Color(0xFFC95A33);
  static const coralMist = Color(0xFFFCE3D8);

  static const Color ringTrack = cobaltMist;
}

Color colorFor(PillColor color) {
  switch (color) {
    case PillColor.sage:
      return const Color(0xFF5E8C74);
    case PillColor.moss:
      return const Color(0xFF7A8F45);
    case PillColor.terracotta:
      return const Color(0xFFE07A52);
    case PillColor.clay:
      return const Color(0xFFB07D5A);
    case PillColor.sand:
      return const Color(0xFFD4B48A);
    case PillColor.slate:
      return const Color(0xFF5E6A75);
    case PillColor.ink:
      return const Color(0xFF2A2622);
    case PillColor.blush:
      return const Color(0xFFD98C9A);
  }
}
