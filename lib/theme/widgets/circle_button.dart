import 'package:flutter/material.dart';
import 'package:mamiro/theme/mamiro_colors.dart';

/// A round white icon button, used for back and header actions.
final class CircleButton extends StatelessWidget {
  const CircleButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.size = 48,
    super.key,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: context.colors.surface,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox.square(
            dimension: size,
            child: Icon(icon, size: 22, color: context.colors.ink),
          ),
        ),
      ),
    );
  }
}
