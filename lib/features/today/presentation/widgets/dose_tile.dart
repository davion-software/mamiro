import 'package:flutter/material.dart';
import 'package:mamiro/theme/mamiro_colors.dart';
import 'package:mamiro/core/dose_slot.dart';
import 'package:mamiro/l10n/l10n.dart';
import 'package:mamiro/theme/widgets/paper_card.dart';
import 'package:mamiro/theme/widgets/pill_glyph.dart';
import 'package:mamiro/theme/widgets/status_chip.dart';

enum _DoseMenu { take, skip }

/// One open dose. Prominent tiles get a Take button; quiet tiles for doses
/// later in the day keep Take and Skip in the overflow menu.
final class DoseTile extends StatelessWidget {
  const DoseTile({
    required this.slot,
    required this.onTake,
    required this.onSkip,
    this.prominent = true,
    super.key,
  });

  final DoseSlot slot;
  final ValueChanged<String> onTake;
  final ValueChanged<String> onSkip;
  final bool prominent;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final med = slot.medication;
    final detail = [
      if (med.dosage.isNotEmpty) med.dosage,
      if (med.notes.isNotEmpty) med.notes,
    ].join(' · ');
    final status = _statusLine(context);
    final textTheme = Theme.of(context).textTheme;
    return PaperCard(
      padding: const EdgeInsetsDirectional.fromSTEB(14, 10, 4, 10),
      child: Row(
        children: [
          PillGlyph(
            shape: med.shape,
            color: med.color,
            size: prominent ? 36 : 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  med.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: prominent
                      ? textTheme.titleLarge?.copyWith(fontSize: 19)
                      : textTheme.titleMedium,
                ),
                if (detail.isNotEmpty)
                  Text(
                    detail,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyMedium,
                  ),
                if (status != null) ...[const SizedBox(height: 4), status],
              ],
            ),
          ),
          if (prominent) ...[
            const SizedBox(width: 8),
            FilledButton(
              onPressed: () => onTake(slot.id),
              style: FilledButton.styleFrom(
                minimumSize: const Size(72, 40),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: Text(l10n.takeAction),
            ),
          ],
          PopupMenuButton<_DoseMenu>(
            tooltip: l10n.moreActions,
            icon: Icon(Icons.more_vert, color: context.colors.inkSoft),
            onSelected: (choice) => switch (choice) {
              _DoseMenu.take => onTake(slot.id),
              _DoseMenu.skip => onSkip(slot.id),
            },
            itemBuilder: (context) => [
              if (!prominent)
                PopupMenuItem(
                  value: _DoseMenu.take,
                  child: Text(l10n.takeEarly),
                ),
              PopupMenuItem(
                value: _DoseMenu.skip,
                child: Text(l10n.skipAction),
              ),
            ],
          ),
        ],
      ),
    );
  }

  StatusChip? _statusLine(BuildContext context) {
    final l10n = context.l10n;
    switch (slot.status) {
      case SlotStatus.missed:
        return StatusChip(
          label: l10n.statusMissed,
          tone: StatusTone.danger,
          icon: Icons.error_outline,
        );
      case SlotStatus.snoozed:
        final until = slot.snoozeUntil;
        return StatusChip(
          label: until == null
              ? l10n.statusSnoozed
              : l10n.statusSnoozedUntil(context.formats.clock(until)),
          tone: StatusTone.neutral,
          icon: Icons.snooze,
        );
      case SlotStatus.due:
      case SlotStatus.later:
      case SlotStatus.taken:
      case SlotStatus.skipped:
        return null;
    }
  }
}
