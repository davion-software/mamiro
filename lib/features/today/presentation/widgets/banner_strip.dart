import 'package:flutter/material.dart';
import 'package:mamiro/theme/palette.dart';
import 'package:mamiro/theme/widgets/coral_surface.dart';

final class BannerStrip extends StatelessWidget {
  const BannerStrip({required this.text, super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: coralSurface(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Text(
          text,
          style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(color: MamiroPalette.surface),
        ),
      ),
    );
  }
}
