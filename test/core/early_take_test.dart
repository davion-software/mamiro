import 'package:flutter_test/flutter_test.dart';
import 'package:mamiro/core/schedule.dart';

void main() {
  final now = DateTime(2026, 8, 26, 7);

  test('exactly one hour early needs no confirmation', () {
    expect(
      isEarlyTake(scheduledAt: now.add(earlyTakeWindow), now: now),
      isFalse,
    );
  });

  test('one hour and a minute early asks first', () {
    expect(
      isEarlyTake(
        scheduledAt: now.add(earlyTakeWindow + const Duration(minutes: 1)),
        now: now,
      ),
      isTrue,
    );
  });

  test('a dose already due or overdue is never early', () {
    expect(isEarlyTake(scheduledAt: now, now: now), isFalse);
    expect(
      isEarlyTake(
        scheduledAt: now.subtract(const Duration(hours: 3)),
        now: now,
      ),
      isFalse,
    );
  });
}
