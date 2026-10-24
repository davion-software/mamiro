import 'package:flutter_test/flutter_test.dart';
import 'package:mamiro/core/alarm_plan.dart';
import 'package:mamiro/core/dose_event.dart';
import 'package:mamiro/core/dose_slot.dart';
import 'package:mamiro/core/medication.dart';

Medication _medication({
  String id = 'morning',
  List<int> times = const [8 * 60],
  List<int> days = const [],
}) {
  return Medication(
    id: id,
    name: id,
    dosage: '1 tablet',
    notes: '',
    shape: PillShape.tablet,
    color: PillColor.sage,
    timesMinutes: times,
    daysOfWeek: days,
  );
}

DoseEvent _event(
  DateTime scheduledAt,
  DoseAction action, {
  String medicationId = 'morning',
  DateTime? snoozeUntil,
}) {
  return DoseEvent(
    id: '$medicationId-${action.name}-$scheduledAt',
    medicationId: medicationId,
    medicationName: medicationId,
    scheduledAt: scheduledAt,
    at: scheduledAt,
    action: action,
    snoozeUntil: snoozeUntil,
  );
}

void main() {
  final now = DateTime(2026, 8, 26, 7);

  test('schedules every upcoming dose in the horizon in firing order', () {
    final plan = planAlarms(
      medications: [
        _medication(times: const [20 * 60, 8 * 60]),
      ],
      events: const [],
      now: now,
    );

    expect(plan.ringingSlotKeys, isEmpty);
    expect(plan.upcoming.first.fireAt, DateTime(2026, 8, 26, 8));
    expect(plan.upcoming[1].fireAt, DateTime(2026, 8, 26, 20));
    expect(plan.upcoming.last.fireAt, DateTime(2026, 9, 1, 20));
    expect(plan.upcoming, hasLength(14));
  });

  test('a due dose rings instead of being rescheduled', () {
    final plan = planAlarms(
      medications: [_medication()],
      events: const [],
      now: DateTime(2026, 8, 26, 8, 30),
    );

    expect(plan.ringingSlotKeys, {'morning@2026-08-26T08:00'});
    expect(plan.upcoming.first.fireAt, DateTime(2026, 8, 27, 8));
  });

  test('taken and skipped doses never ring', () {
    final plan = planAlarms(
      medications: [
        _medication(times: const [8 * 60, 9 * 60]),
      ],
      events: [
        _event(DateTime(2026, 8, 26, 8), DoseAction.taken),
        _event(DateTime(2026, 8, 26, 9), DoseAction.skipped),
      ],
      now: now,
    );

    expect(plan.upcoming.first.fireAt, DateTime(2026, 8, 27, 8));
  });

  test('a snoozed dose fires again when the snooze ends', () {
    final scheduledAt = DateTime(2026, 8, 26, 8);
    final plan = planAlarms(
      medications: [_medication()],
      events: [
        _event(
          scheduledAt,
          DoseAction.snoozed,
          snoozeUntil: DateTime(2026, 8, 26, 8, 10),
        ),
      ],
      now: DateTime(2026, 8, 26, 8, 2),
    );

    final first = plan.upcoming.first;
    expect(first.fireAt, DateTime(2026, 8, 26, 8, 10));
    expect(first.slotKey, 'morning@2026-08-26T08:00');
    expect(first.silenceAt, DateTime(2026, 8, 26, 10));
    expect(plan.ringingSlotKeys, isEmpty);
  });

  test('a dose still ringing after midnight belongs to yesterday', () {
    final plan = planAlarms(
      medications: [
        _medication(times: const [23 * 60 + 30]),
      ],
      events: const [],
      now: DateTime(2026, 8, 27, 0, 15),
    );

    expect(plan.ringingSlotKeys, {'morning@2026-08-26T23:30'});
  });

  test('respects weekdays and the scheduling limit', () {
    final weekly = planAlarms(
      medications: [
        _medication(days: const [DateTime.monday]),
      ],
      events: const [],
      now: now,
    );
    expect(weekly.upcoming.map((alarm) => alarm.fireAt), [
      DateTime(2026, 8, 31, 8),
    ]);

    final capped = planAlarms(
      medications: [
        _medication(times: [for (var hour = 0; hour < 24; hour++) hour * 60]),
      ],
      events: const [],
      now: now,
    );
    expect(capped.upcoming, hasLength(maxScheduledAlarms));
    expect(capped.upcoming.first.fireAt, DateTime(2026, 8, 26, 8));
  });

  test('notification ids are stable, positive, and distinct per slot', () {
    final id = alarmNotificationId('morning@2026-08-26T08:00');
    expect(id, alarmNotificationId('morning@2026-08-26T08:00'));
    expect(id, isPositive);
    expect(id, lessThanOrEqualTo(0x7fffffff));
    expect(id, isNot(alarmNotificationId('morning@2026-08-26T20:00')));
  });

  test('slot keys parse back into a medication and local time', () {
    final key = doseSlotKey(
      medicationId: 'demo@home',
      scheduledAt: DateTime(2026, 8, 26, 8),
    );
    final parsed = SlotRef.parse(key);

    expect(parsed?.medicationId, 'demo@home');
    expect(parsed?.scheduledAt, DateTime(2026, 8, 26, 8));
    expect(SlotRef.parse('test-alarm'), isNull);
    expect(SlotRef.parse('med@not-a-time'), isNull);
  });
}
