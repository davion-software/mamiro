import 'package:flutter/material.dart';
import 'package:mamiro/core/dose_slot.dart';
import 'package:mamiro/core/schedule.dart';
import 'package:mamiro/l10n/l10n.dart';

/// Asks before taking doses more than [earlyTakeWindow] ahead of time, so a
/// stray tap at 7:00 cannot log the 20:00 dose. Returns true when the doses
/// can be recorded: either none is early or the user confirmed.
Future<bool> confirmEarlyTake(
  BuildContext context, {
  required List<DoseSlot> slots,
  required DateTime now,
}) async {
  final early = [
    for (final slot in slots)
      if (isEarlyTake(scheduledAt: slot.scheduledAt, now: now)) slot,
  ];
  if (early.isEmpty) return true;
  final l10n = context.l10n;
  final first = early.first;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.earlyTakeTitle(slots.length, first.medication.name)),
      content: Text(
        l10n.earlyTakeBody(context.formats.clock(first.scheduledAt)),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(l10n.takeEarly),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}
