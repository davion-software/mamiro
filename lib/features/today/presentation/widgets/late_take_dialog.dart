import 'package:flutter/material.dart';
import 'package:mamiro/core/dose_slot.dart';
import 'package:mamiro/core/schedule.dart';
import 'package:mamiro/l10n/l10n.dart';

/// When the user says the doses were taken. A null [at] means now.
@immutable
final class TakenAt {
  const TakenAt(this.at, {this.adjusted = false});

  final DateTime? at;
  final bool adjusted;
}

enum _LateChoice { now, onTime, other }

/// Asks when late [slots] were really taken, so the log keeps the true time.
///
/// [slots] share one scheduled time (a single dose or a "Take all" group).
/// Doses within [lateTakeThreshold] skip the question and count as taken
/// now. Returns null when the user cancels: nothing should be recorded.
Future<TakenAt?> askTakenAt(
  BuildContext context, {
  required List<DoseSlot> slots,
  required DateTime now,
}) async {
  if (slots.isEmpty) return null;
  final scheduledAt = slots.first.scheduledAt;
  if (!isLateTake(scheduledAt: scheduledAt, now: now)) {
    return const TakenAt(null);
  }
  final l10n = context.l10n;
  final formats = context.formats;
  final choice = await showDialog<_LateChoice>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(
        slots.length == 1
            ? l10n.lateTakeTitleOne(slots.single.medication.name)
            : l10n.lateTakeTitleMany(slots.length),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FilledButton(
            onPressed: () => Navigator.pop(context, _LateChoice.now),
            child: Text(l10n.lateTakeNow(formats.clock(now))),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: () => Navigator.pop(context, _LateChoice.onTime),
            child: Text(l10n.lateTakeOnTime(formats.clock(scheduledAt))),
          ),
          const SizedBox(height: 4),
          TextButton(
            onPressed: () => Navigator.pop(context, _LateChoice.other),
            child: Text(l10n.lateTakeOther),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
      ],
    ),
  );
  if (!context.mounted) return null;
  switch (choice) {
    case null:
      return null;
    case _LateChoice.now:
      return const TakenAt(null);
    case _LateChoice.onTime:
      return TakenAt(scheduledAt);
    case _LateChoice.other:
      return await _pickTime(context, scheduledAt: scheduledAt, now: now);
  }
}

Future<TakenAt?> _pickTime(
  BuildContext context, {
  required DateTime scheduledAt,
  required DateTime now,
}) async {
  final picked = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.fromDateTime(scheduledAt),
  );
  if (picked == null || !context.mounted) return null;
  final chosen = DateTime(
    scheduledAt.year,
    scheduledAt.month,
    scheduledAt.day,
    picked.hour,
    picked.minute,
  );
  final at = clampTakenAt(chosen, scheduledAt: scheduledAt, now: now);
  return TakenAt(at, adjusted: at != chosen);
}
