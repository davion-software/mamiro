import 'package:flutter_test/flutter_test.dart';
import 'package:mamiro/core/schedule.dart';

void main() {
  final scheduledAt = DateTime(2026, 8, 26, 8);

  test('a dose is late only beyond the threshold', () {
    expect(lateTakeThreshold, const Duration(minutes: 30));
    expect(
      isLateTake(scheduledAt: scheduledAt, now: DateTime(2026, 8, 26, 7, 50)),
      isFalse,
    );
    expect(
      isLateTake(scheduledAt: scheduledAt, now: DateTime(2026, 8, 26, 8, 30)),
      isFalse,
    );
    expect(
      isLateTake(scheduledAt: scheduledAt, now: DateTime(2026, 8, 26, 8, 31)),
      isTrue,
    );
    expect(
      isLateTake(scheduledAt: scheduledAt, now: DateTime(2026, 8, 26, 11)),
      isTrue,
    );
  });

  test('a reported time stays between the schedule and now', () {
    final now = DateTime(2026, 8, 26, 11);
    expect(
      clampTakenAt(
        DateTime(2026, 8, 26, 7),
        scheduledAt: scheduledAt,
        now: now,
      ),
      scheduledAt,
    );
    expect(
      clampTakenAt(
        DateTime(2026, 8, 26, 12),
        scheduledAt: scheduledAt,
        now: now,
      ),
      now,
    );
    final inside = DateTime(2026, 8, 26, 9, 15);
    expect(clampTakenAt(inside, scheduledAt: scheduledAt, now: now), inside);
  });
}
