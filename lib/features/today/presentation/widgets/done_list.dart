import 'package:flutter/material.dart';
import 'package:mamiro/core/dose_slot.dart';
import 'package:mamiro/l10n/l10n.dart';
import 'package:mamiro/theme/palette.dart';
import 'package:mamiro/theme/widgets/paper_card.dart';
import 'package:mamiro/theme/widgets/pill_glyph.dart';

/// Taken and skipped doses as quiet single lines, each one undoable.
final class DoneList extends StatelessWidget {
  const DoneList({required this.slots, required this.onUndo, super.key});

  final List<DoseSlot> slots;
  final ValueChanged<String> onUndo;

  @override
  Widget build(BuildContext context) {
    return PaperCard(
      padding: const EdgeInsetsDirectional.fromSTEB(14, 4, 4, 4),
      child: Column(
        children: [
          for (final (index, slot) in slots.indexed) ...[
            if (index > 0) const Divider(height: 1, color: MamiroPalette.line),
            _DoneRow(key: ValueKey(slot.id), slot: slot, onUndo: onUndo),
          ],
        ],
      ),
    );
  }
}

final class _DoneRow extends StatelessWidget {
  const _DoneRow({required this.slot, required this.onUndo, super.key});

  final DoseSlot slot;
  final ValueChanged<String> onUndo;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final med = slot.medication;
    final taken = slot.status == SlotStatus.taken;
    final resolvedAt = slot.resolvedAt;
    final status = taken && resolvedAt != null
        ? l10n.doneTakenAt(context.formats.clock(resolvedAt))
        : taken
        ? l10n.statusTaken
        : l10n.statusSkipped;
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        Opacity(
          opacity: 0.6,
          child: PillGlyph(shape: med.shape, color: med.color, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  med.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleMedium?.copyWith(
                    color: MamiroPalette.inkSoft,
                  ),
                ),
                Text(
                  status,
                  style: textTheme.bodyMedium?.copyWith(
                    color: taken ? MamiroPalette.cobalt : MamiroPalette.inkSoft,
                  ),
                ),
              ],
            ),
          ),
        ),
        TextButton(onPressed: () => onUndo(slot.id), child: Text(l10n.undo)),
      ],
    );
  }
}
