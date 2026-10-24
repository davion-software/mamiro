import 'package:flutter/material.dart';
import 'package:mamiro/theme/palette.dart';

/// The pale sky gradient every screen sits on, with a soft blush aura in
/// the top corner.
final class SkyBackground extends StatelessWidget {
  const SkyBackground({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            MamiroPalette.skyTop,
            MamiroPalette.skyMid,
            MamiroPalette.skyBottom,
          ],
          stops: [0, 0.5, 1],
        ),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(1.1, -1.05),
            radius: 0.9,
            colors: [
              MamiroPalette.blushAura.withValues(alpha: 0.85),
              MamiroPalette.blushAura.withValues(alpha: 0),
            ],
          ),
        ),
        child: child,
      ),
    );
  }
}
