import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mamiro/theme/mamiro_colors.dart';
import 'package:mamiro/core/medication.dart';
import 'package:mamiro/l10n/l10n.dart';
import 'package:mamiro/theme/palette.dart';

/// Every pill color on a single row, sized to the available width.
final class ColorPicker extends StatelessWidget {
  const ColorPicker({required this.color, required this.onChanged, super.key});

  final PillColor color;
  final ValueChanged<PillColor> onChanged;

  @override
  Widget build(BuildContext context) {
    final count = PillColor.values.length;
    const gap = 6.0;
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = math
            .min(40, (constraints.maxWidth - gap * (count - 1)) / count)
            .toDouble();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (final value in PillColor.values)
              Semantics(
                label: context.formats.color(value),
                selected: color == value,
                button: true,
                child: GestureDetector(
                  onTap: () => onChanged(value),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: colorFor(value),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: color == value
                            ? context.colors.ink
                            : Colors.transparent,
                        width: 2.4,
                      ),
                    ),
                    child: SizedBox.square(
                      dimension: size,
                      child: color == value
                          ? Icon(
                              Icons.check,
                              size: 18,
                              color: context.colors.surface,
                            )
                          : null,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
