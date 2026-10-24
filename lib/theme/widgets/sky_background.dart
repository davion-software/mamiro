import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mamiro/theme/mamiro_colors.dart';

/// The pale sky gradient every screen sits on, with a soft blush aura in
/// the top corner.
final class SkyBackground extends StatelessWidget {
  const SkyBackground({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    // The Android navigation bar blends into the bottom of the gradient.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: context.colors.bgBottom,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: _gradient(context),
    );
  }

  Widget _gradient(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            context.colors.bgTop,
            context.colors.bgMid,
            context.colors.bgBottom,
          ],
          stops: const [0, 0.5, 1],
        ),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(1.1, -1.05),
            radius: 0.9,
            colors: [
              context.colors.aura.withValues(alpha: 0.85),
              context.colors.aura.withValues(alpha: 0),
            ],
          ),
        ),
        child: child,
      ),
    );
  }
}
