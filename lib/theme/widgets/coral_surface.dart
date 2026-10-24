import 'package:flutter/material.dart';
import 'package:mamiro/theme/palette.dart';

/// The glossy coral of the reference buttons: a top-lit gradient, a thin
/// light rim, and a soft coral halo around it. White text reads on it.
BoxDecoration coralSurface({BoxShape shape = BoxShape.rectangle}) {
  return BoxDecoration(
    shape: shape,
    borderRadius: shape == BoxShape.circle ? null : BorderRadius.circular(999),
    gradient: const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [MamiroPalette.coralButtonTop, MamiroPalette.coralButtonBottom],
    ),
    border: Border.all(color: Colors.white.withValues(alpha: 0.35), width: 1.5),
    boxShadow: [
      // Halo ring, as around the reference's microphone and chips.
      BoxShadow(
        color: MamiroPalette.coral.withValues(alpha: 0.28),
        spreadRadius: 4,
      ),
      BoxShadow(
        color: MamiroPalette.coralButtonBottom.withValues(alpha: 0.35),
        blurRadius: 16,
        offset: const Offset(0, 6),
      ),
    ],
  );
}
