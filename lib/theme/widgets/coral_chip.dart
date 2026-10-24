import 'package:flutter/material.dart';
import 'package:mamiro/theme/mamiro_colors.dart';
import 'package:mamiro/theme/palette.dart';
import 'package:mamiro/theme/widgets/coral_surface.dart';

/// The coral pill that tags a screen, as in "Wednesday, August 26".
final class CoralChip extends StatelessWidget {
  const CoralChip({required this.label, this.icon, super.key});

  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final icon = this.icon;
    return DecoratedBox(
      decoration: accentSurface(context.colors),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: context.colors.onAccent),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: MamiroPalette.fontFamily,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: context.colors.onAccent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
