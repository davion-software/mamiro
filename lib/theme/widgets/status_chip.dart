import 'package:flutter/material.dart';
import 'package:mamiro/theme/mamiro_colors.dart';
import 'package:mamiro/theme/palette.dart';

enum StatusTone { success, warning, danger, neutral }

/// A pale, tinted pill for a dose or stock state. Each tone pairs its text
/// color with its container, and carries an icon so color is never the only
/// cue.
final class StatusChip extends StatelessWidget {
  const StatusChip({
    required this.label,
    required this.tone,
    this.icon,
    super.key,
  });

  final String label;
  final StatusTone tone;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final (background, foreground) = switch (tone) {
      StatusTone.success => (colors.successContainer, colors.success),
      StatusTone.warning => (colors.warningContainer, colors.warning),
      StatusTone.danger => (colors.dangerContainer, colors.danger),
      StatusTone.neutral => (colors.muted, colors.ink),
    };
    final icon = this.icon;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: foreground),
              const SizedBox(width: 4),
            ],
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: MamiroPalette.fontFamily,
                  fontWeight: FontWeight.w700,
                  fontSize: 12.5,
                  color: foreground,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
