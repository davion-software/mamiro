import 'package:flutter/material.dart';
import 'package:mamiro/core/medication.dart';
import 'package:mamiro/theme/palette.dart';

final class ColorPicker extends StatelessWidget {
  const ColorPicker({required this.color, required this.onChanged, super.key});

  final PillColor color;
  final ValueChanged<PillColor> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final value in PillColor.values)
          Semantics(
            label: pillColorName(value),
            button: true,
            child: GestureDetector(
              onTap: () => onChanged(value),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colorFor(value),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: color == value
                        ? MamiroPalette.ink
                        : Colors.transparent,
                    width: 2.4,
                  ),
                ),
                child: const SizedBox(width: 36, height: 36),
              ),
            ),
          ),
      ],
    );
  }
}
