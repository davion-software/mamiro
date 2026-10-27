import 'package:clock/clock.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mamiro/app.dart';
import 'package:mamiro/core/result.dart';
import 'package:mamiro/core/snapshot.dart';
import 'package:mamiro/core/storage_failure.dart';
import 'package:mamiro/data/app_database.dart';
import 'package:mamiro/data/providers.dart';
import 'package:mamiro/data/repository.dart';
import 'package:mamiro/services/alarm_gateway.dart';
import 'package:mamiro/services/app_providers.dart';

import '../../support/fake_alarm_gateway.dart';

Future<void> frames(WidgetTester tester) async {
  // Long enough for the snack bar to finish sliding in.
  for (var frame = 0; frame < 10; frame++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<MamiroRepository> pumpAt(
  WidgetTester tester,
  DateTime now, {
  bool failWrites = false,
}) async {
  tester.view
    ..physicalSize = const Size(1200, 2400)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  SharedPreferences.setMockInitialValues({});
  final database = AppDatabase(NativeDatabase.memory());
  addTearDown(database.close);
  final repository = MamiroRepository(database);
  expect(
    await repository.initialize(now: DateTime(2026, 8, 20)),
    isA<Ok<void, StorageFailure>>(),
  );
  if (failWrites) {
    await database.customStatement('''
      CREATE TRIGGER reject_dose BEFORE INSERT ON dose_events
      BEGIN SELECT RAISE(ABORT, 'test write failure'); END;
    ''');
  }
  var id = 0;
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        mamiroRepositoryProvider.overrideWithValue(repository),
        clockProvider.overrideWithValue(Clock.fixed(now)),
        idGeneratorProvider.overrideWithValue(() => 'event-${id++}'),
        alarmGatewayProvider.overrideWithValue(FakeAlarmGateway()),
        currentMinuteProvider.overrideWithValue(AsyncData(now)),
      ],
      child: const MamiroApp(),
    ),
  );
  await frames(tester);
  return repository;
}

Future<Snapshot> read(WidgetTester tester, MamiroRepository repository) async {
  final result = await tester.runAsync(repository.readSnapshot);
  return switch (result) {
    Ok(:final value) => value,
    _ => fail('Snapshot unavailable'),
  };
}

int? quantityOf(Snapshot snapshot, String id) => snapshot.medications
    .firstWhere((medication) => medication.id == id)
    .quantity;

// Snack bars show on every root Scaffold; the last one is painted on top
// (above the alarm when it is open).
Finder undoAction() => find.widgetWithText(SnackBarAction, 'Undo').last;

void main() {
  testWidgets('Take on Today offers Undo, which returns the pill', (
    tester,
  ) async {
    final repository = await pumpAt(tester, DateTime(2026, 8, 26, 19, 30));
    final before = quantityOf(
      await read(tester, repository),
      'demo-lisinopril',
    );
    final pendingCount = find
        .widgetWithText(FilledButton, 'Take')
        .evaluate()
        .length;

    // At 19:30 the 8:00 doses are missed; take the first of them.
    await tester.tap(find.widgetWithText(FilledButton, 'Take').first);
    await frames(tester);
    await tester.tap(find.text('Now (7:30\u202fPM)'));
    await frames(tester);
    expect(find.text('Taken: Lisinopril'), findsOneWidget);
    final taken = await read(tester, repository);
    expect(taken.events, hasLength(1));
    expect(taken.events.single.at, DateTime(2026, 8, 26, 19, 30));
    expect(quantityOf(taken, 'demo-lisinopril'), before! - 1);

    await tester.tap(undoAction());
    await frames(tester);
    final after = await read(tester, repository);
    expect(after.events, isEmpty);
    expect(quantityOf(after, 'demo-lisinopril'), before);
    expect(
      find.widgetWithText(FilledButton, 'Take'),
      findsNWidgets(pendingCount),
    );
  });

  testWidgets('an early take can be confirmed and undone', (tester) async {
    final repository = await pumpAt(tester, DateTime(2026, 8, 26, 7));
    final before = quantityOf(
      await read(tester, repository),
      'demo-lisinopril',
    );

    await tester.tap(find.byTooltip('More actions').at(3));
    await frames(tester);
    await tester.tap(find.text('Take now'));
    await frames(tester);
    expect(find.text('Take Lisinopril now?'), findsOneWidget);
    expect((await read(tester, repository)).events, isEmpty);

    await tester.tap(find.widgetWithText(TextButton, 'Take now'));
    await frames(tester);
    final taken = await read(tester, repository);
    expect(taken.events, hasLength(1));
    expect(taken.events.single.scheduledAt, DateTime(2026, 8, 26, 20));
    expect(quantityOf(taken, 'demo-lisinopril'), before! - 1);

    await tester.tap(undoAction());
    await frames(tester);
    final after = await read(tester, repository);
    expect(after.events, isEmpty);
    expect(quantityOf(after, 'demo-lisinopril'), before);
  });

  testWidgets('Skip on the alarm offers Undo above the alarm', (tester) async {
    final repository = await pumpAt(tester, DateTime(2026, 8, 26, 8, 5));

    await tester.tap(find.text('Skip'));
    await frames(tester);
    expect(find.text('Skipped: Lisinopril'), findsWidgets);
    expect((await read(tester, repository)).events, hasLength(1));

    await tester.tap(undoAction());
    await frames(tester);
    expect((await read(tester, repository)).events, isEmpty);
    expect(find.text('Dose due · 1 of 3'), findsOneWidget);
  });

  for (final alarm in [false, true]) {
    testWidgets(
      'Take all on ${alarm ? 'alarm' : 'Today'} undoes all three doses',
      (tester) async {
        tester.platformDispatcher.localesTestValue = [const Locale('es', 'ES')];
        addTearDown(tester.platformDispatcher.clearLocalesTestValue);
        final repository = await pumpAt(
          tester,
          DateTime(2026, 8, 26, alarm ? 8 : 19, alarm ? 5 : 30),
        );
        final before = await read(tester, repository);

        await tester.tap(find.text('Tomar todas (3)').last);
        await frames(tester);
        if (!alarm) {
          await tester.tap(find.text('Ahora (19:30)'));
          await frames(tester);
        }
        expect(find.text('3 tomas registradas'), findsWidgets);
        final taken = await read(tester, repository);
        expect(taken.events, hasLength(3));
        for (final event in taken.events) {
          expect(
            quantityOf(taken, event.medicationId),
            quantityOf(before, event.medicationId)! - 1,
          );
        }

        await tester.tap(find.widgetWithText(SnackBarAction, 'Deshacer').last);
        await frames(tester);
        final after = await read(tester, repository);
        expect(after.events, isEmpty);
        for (final medication in before.medications) {
          expect(quantityOf(after, medication.id), medication.quantity);
        }
        expect(find.text('Tomar todas (3)'), findsWidgets);
      },
    );
  }

  testWidgets('Skip in the Today menu offers Undo', (tester) async {
    final repository = await pumpAt(tester, DateTime(2026, 8, 26, 19, 30));
    final before = quantityOf(
      await read(tester, repository),
      'demo-lisinopril',
    );

    await tester.tap(find.byTooltip('More actions').first);
    await frames(tester);
    await tester.tap(find.text('Skip'));
    await frames(tester);
    expect(find.text('Skipped: Lisinopril'), findsOneWidget);
    expect((await read(tester, repository)).events, hasLength(1));

    await tester.tap(undoAction());
    await frames(tester);
    final after = await read(tester, repository);
    expect(after.events, isEmpty);
    expect(quantityOf(after, 'demo-lisinopril'), before);
  });

  testWidgets('Take on the alarm offers Undo above the next alarm', (
    tester,
  ) async {
    final repository = await pumpAt(tester, DateTime(2026, 8, 26, 8, 5));
    final before = quantityOf(
      await read(tester, repository),
      'demo-lisinopril',
    );

    await tester.tap(find.text('Take now'));
    await frames(tester);
    expect(find.text('Taken: Lisinopril'), findsWidgets);
    expect((await read(tester, repository)).events, hasLength(1));

    await tester.tap(undoAction());
    await frames(tester);
    final after = await read(tester, repository);
    expect(after.events, isEmpty);
    expect(quantityOf(after, 'demo-lisinopril'), before);
    expect(find.text('Dose due · 1 of 3'), findsOneWidget);
  });

  for (final alarm in [false, true]) {
    testWidgets(
      'Failed write on ${alarm ? 'alarm' : 'Today'} keeps the error',
      (tester) async {
        final repository = await pumpAt(
          tester,
          DateTime(2026, 8, 26, alarm ? 8 : 19, alarm ? 5 : 30),
          failWrites: true,
        );

        await tester.tap(
          alarm
              ? find.text('Skip')
              : find.widgetWithText(FilledButton, 'Take').first,
        );
        await frames(tester);

        if (!alarm) {
          await tester.tap(find.text('Now (7:30\u202fPM)'));
          await frames(tester);
        }

        expect(find.text('That change could not be saved.'), findsOneWidget);
        expect(find.byType(SnackBarAction), findsNothing);
        expect((await read(tester, repository)).events, isEmpty);
      },
    );
  }

  testWidgets('Undo leaves an already pending dose and pill count alone', (
    tester,
  ) async {
    final now = DateTime(2026, 8, 26, 19, 30);
    final repository = await pumpAt(tester, now);
    final before = quantityOf(
      await read(tester, repository),
      'demo-lisinopril',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Take').first);
    await frames(tester);
    await tester.tap(find.text('Now (7:30\u202fPM)'));
    await frames(tester);
    final event = (await read(tester, repository)).events.single;
    expect(
      await tester.runAsync(
        () => repository.undoSlot(
          medicationId: event.medicationId,
          scheduledAt: event.scheduledAt,
          now: now,
        ),
      ),
      isA<Ok<void, StorageFailure>>(),
    );

    await tester.tap(undoAction());
    await frames(tester);
    final after = await read(tester, repository);
    expect(after.events, isEmpty);
    expect(quantityOf(after, 'demo-lisinopril'), before);
  });

  testWidgets('Undo expires after five seconds', (tester) async {
    final repository = await pumpAt(tester, DateTime(2026, 8, 26, 19, 30));
    await tester.tap(find.widgetWithText(FilledButton, 'Take').first);
    await frames(tester);
    await tester.tap(find.text('Now (7:30\u202fPM)'));
    await frames(tester);
    expect(find.text('Taken: Lisinopril'), findsOneWidget);

    await tester.pump(const Duration(seconds: 5));
    await frames(tester);

    expect(find.byType(SnackBar), findsNothing);
    expect((await read(tester, repository)).events, hasLength(1));
  });

  testWidgets('Snooze does not offer Undo', (tester) async {
    await pumpAt(tester, DateTime(2026, 8, 26, 8, 5));

    await tester.tap(find.text('Snooze 10 min'));
    await frames(tester);

    expect(find.byType(SnackBar), findsNothing);
  });
}
