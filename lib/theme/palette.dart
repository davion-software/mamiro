import 'package:flutter/material.dart';

import 'package:mamiro/core/medication.dart';

/// Static design constants. Colors live in the theme: see MamiroColors.
abstract final class MamiroPalette {
  static const fontFamily = 'PlusJakartaSans';
}

/// A medication's own pill color, chosen by the user. These stay the same
/// in every theme so a pill always looks like itself.
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
