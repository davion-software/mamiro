import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mamiro/core/dose_event.dart';
import 'package:mamiro/core/dose_slot.dart';
import 'package:mamiro/core/medication.dart';
import 'package:mamiro/core/storage_failure.dart';
import 'package:mamiro/l10n/l10n.dart';

void main() {
  test('enum byName round-trips every known value', () {
    for (final shape in PillShape.values) {
      expect(PillShape.byName(shape.name), shape);
    }
    for (final color in PillColor.values) {
      expect(PillColor.byName(color.name), color);
    }
    for (final action in DoseAction.values) {
      expect(DoseAction.byName(action.name), action);
    }
    expect(PillShape.byName('unknown'), isNull);
    expect(PillColor.byName('unknown'), isNull);
    expect(DoseAction.byName('unknown'), isNull);
  });

  test('DoseSlot.toEvent copies identity and snooze window', () {
    const medication = Medication.sample();
    final scheduledAt = DateTime(2026, 8, 26, 8);
    final slot = DoseSlot(
      medication: medication,
      scheduledAt: scheduledAt,
      status: SlotStatus.due,
    );
    final event = slot.toEvent(
      id: 'event-1',
      at: DateTime(2026, 8, 26, 8, 1),
      action: DoseAction.snoozed,
      snoozeMinutes: 10,
    );
    expect(event.medicationId, medication.id);
    expect(event.scheduledAt, scheduledAt);
    expect(event.snoozeUntil, DateTime(2026, 8, 26, 8, 11));
  });

  test('every storage failure has English and Spanish copy', () {
    for (final locale in const [Locale('en'), Locale('es')]) {
      final formats = Formats(lookupAppLocalizations(locale), use24h: false);
      final messages = {
        for (final failure in const <StorageFailure>[
          StorageUnavailable(),
          StorageCorrupt(),
          StorageConstraintViolation('write'),
          StorageNotFound('id'),
        ])
          formats.storageFailure(failure),
      };
      expect(messages, hasLength(4));
      expect(messages, everyElement(isNotEmpty));
    }
  });

  test('times follow the locale and the 24-hour setting', () async {
    await initializeDateFormatting();
    final eight = DateTime(2026, 8, 26, 20, 5);
    final english = lookupAppLocalizations(const Locale('en'));
    final spanish = lookupAppLocalizations(const Locale('es'));

    expect(Formats(english, use24h: false).clock(eight), '8:05\u202fPM');
    expect(Formats(english, use24h: true).clock(eight), '20:05');
    expect(Formats(spanish, use24h: false).clock(eight), '20:05');
    expect(Formats(spanish, use24h: false).days(const []), 'Todos los días');
    expect(
      Formats(spanish, use24h: false).longDate(eight),
      'Miércoles, 26 de agosto',
    );
  });
}
