import 'package:flutter/material.dart';
import 'package:mamiro/core/medication.dart';
import 'package:mamiro/theme/widgets/paper_card.dart';
import 'package:mamiro/theme/widgets/pill_glyph.dart';

final class RefillCard extends StatelessWidget {
  const RefillCard({required this.medication, super.key});

  final Medication medication;

  @override
  Widget build(BuildContext context) {
    return PaperCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          PillGlyph(shape: medication.shape, color: medication.color, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${medication.name} · ${medication.quantity} left',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ],
      ),
    );
  }
}
