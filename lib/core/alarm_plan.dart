import 'package:meta/meta.dart';
import 'package:mamiro/core/dose_event.dart';
import 'package:mamiro/core/dose_slot.dart';
import 'package:mamiro/core/medication.dart';
import 'package:mamiro/core/schedule.dart';

/// How far ahead OS alarms are handed to the platform scheduler.
const alarmHorizon = Duration(days: 7);

/// iOS keeps at most 64 pending notifications per app; stay well below it.
const maxScheduledAlarms = 48;

@immutable
final class PlannedAlarm {
  const PlannedAlarm({required this.slot, required this.fireAt});

  final DoseSlot slot;
  final DateTime fireAt;

  String get slotKey => slot.id;

  /// When the slot turns missed and its alarm should stop ringing.
  DateTime get silenceAt => slot.scheduledAt.add(missAfter);
}

@immutable
final class AlarmPlan {
  const AlarmPlan({required this.upcoming, required this.ringingSlotKeys});

  static const empty = AlarmPlan(upcoming: [], ringingSlotKeys: {});

  /// Future alarms in firing order, capped at [maxScheduledAlarms].
  final List<PlannedAlarm> upcoming;

  /// Slots that are due now. Their delivered alarms stay on screen.
  final Set<String> ringingSlotKeys;
}

AlarmPlan planAlarms({
  required List<Medication> medications,
  required List<DoseEvent> events,
  required DateTime now,
  Duration horizon = alarmHorizon,
  int limit = maxScheduledAlarms,
}) {
  final eventsBySlot = indexEventsBySlot(events);
  final until = now.add(horizon);
  final upcoming = <PlannedAlarm>[];
  final ringing = <String>{};
  final days = horizon.inDays + 1;
  // Start yesterday so late-evening doses still ringing after midnight count.
  for (var offset = -1; offset <= days; offset++) {
    final day = DateTime(now.year, now.month, now.day + offset);
    for (final slot in slotsForDay(
      medications: medications,
      events: const [],
      eventsBySlot: eventsBySlot,
      day: day,
      now: now,
    )) {
      if (slot.status == SlotStatus.due) {
        ringing.add(slot.id);
        continue;
      }
      final fireAt = switch (slot.status) {
        SlotStatus.later => slot.scheduledAt,
        SlotStatus.snoozed => slot.snoozeUntil,
        _ => null,
      };
      if (fireAt == null || !fireAt.isAfter(now) || fireAt.isAfter(until)) {
        continue;
      }
      if (!fireAt.isBefore(slot.scheduledAt.add(missAfter))) continue;
      upcoming.add(PlannedAlarm(slot: slot, fireAt: fireAt));
    }
  }
  upcoming.sort((a, b) => a.fireAt.compareTo(b.fireAt));
  return AlarmPlan(
    upcoming: upcoming.take(limit).toList(growable: false),
    ringingSlotKeys: ringing,
  );
}

/// Stable, positive 31-bit notification id for a slot key (FNV-1a).
int alarmNotificationId(String slotKey) {
  var hash = 0x811c9dc5;
  for (final unit in slotKey.codeUnits) {
    hash ^= unit;
    hash = (hash * 0x01000193) & 0xffffffff;
  }
  return hash & 0x7fffffff;
}

@immutable
final class SlotRef {
  const SlotRef({required this.medicationId, required this.scheduledAt});

  final String medicationId;
  final DateTime scheduledAt;

  static SlotRef? parse(String slotKey) {
    final separator = slotKey.lastIndexOf('@');
    if (separator <= 0) return null;
    final scheduledAt = DateTime.tryParse(slotKey.substring(separator + 1));
    if (scheduledAt == null) return null;
    return SlotRef(
      medicationId: slotKey.substring(0, separator),
      scheduledAt: scheduledAt,
    );
  }
}
