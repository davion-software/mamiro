import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mamiro/core/app_settings.dart';
import 'package:mamiro/core/dose_event.dart';
import 'package:mamiro/core/result.dart';
import 'package:mamiro/core/snapshot.dart';
import 'package:mamiro/core/storage_failure.dart';
import 'package:mamiro/data/app_database.dart';
import 'package:mamiro/data/repository.dart';
import 'package:mamiro/services/alarm_gateway.dart';
import 'package:mamiro/services/alarm_sync.dart';

import '../support/fake_alarm_gateway.dart';

Future<MamiroRepository> _demoRepository() async {
  SharedPreferences.setMockInitialValues({});
  final database = AppDatabase(NativeDatabase.memory());
  addTearDown(database.close);
  final repository = MamiroRepository(database);
  expect(await repository.initialize(), isA<Ok<void, StorageFailure>>());
  return repository;
}

Future<Snapshot> _read(MamiroRepository repository) async {
  return switch (await repository.readSnapshot()) {
    Ok(:final value) => value,
    Err(:final failure) => fail('Unexpected storage failure: ${failure.code}'),
  };
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(SharedPreferences.resetStatic);

  const slotKey = 'demo-lisinopril@2026-08-26T08:00';
  final now = DateTime(2026, 8, 26, 8, 3);

  test('Take on an OS alarm logs the dose and counts the pill', () async {
    final repository = await _demoRepository();
    final before = (await _read(repository)).medications
        .firstWhere((medication) => medication.id == 'demo-lisinopril')
        .quantity;

    final result = await recordAlarmResponse(
      repository: repository,
      response: const AlarmResponse(slotKey: slotKey, action: DoseAction.taken),
      now: now,
      eventId: 'from-alarm',
    );

    expect(result, isA<Ok<void, StorageFailure>>());
    final snapshot = await _read(repository);
    final event = snapshot.events.single;
    expect(event.id, 'from-alarm');
    expect(event.action, DoseAction.taken);
    expect(event.scheduledAt, DateTime(2026, 8, 26, 8));
    final after = snapshot.medications
        .firstWhere((medication) => medication.id == 'demo-lisinopril')
        .quantity;
    expect(after, before == null ? null : before - 1);
  });

  test('Snooze on an OS alarm uses the configured snooze length', () async {
    final repository = await _demoRepository();
    expect(
      await repository.updateSettings(
        AppSettings.defaults.copyWith(snoozeMinutes: 15),
      ),
      isA<Ok<void, StorageFailure>>(),
    );

    await recordAlarmResponse(
      repository: repository,
      response: const AlarmResponse(
        slotKey: slotKey,
        action: DoseAction.snoozed,
      ),
      now: now,
      eventId: 'snooze',
    );

    final event = (await _read(repository)).events.single;
    expect(event.snoozeUntil, now.add(const Duration(minutes: 15)));
  });

  test('body taps and unknown slots record nothing', () async {
    final repository = await _demoRepository();

    await recordAlarmResponse(
      repository: repository,
      response: const AlarmResponse(slotKey: slotKey),
      now: now,
      eventId: 'tap',
    );
    await recordAlarmResponse(
      repository: repository,
      response: const AlarmResponse(
        slotKey: 'deleted@2026-08-26T08:00',
        action: DoseAction.taken,
      ),
      now: now,
      eventId: 'ghost',
    );
    await recordAlarmResponse(
      repository: repository,
      response: const AlarmResponse(
        slotKey: 'test-alarm',
        action: DoseAction.taken,
      ),
      now: now,
      eventId: 'test',
    );

    expect((await _read(repository)).events, isEmpty);
  });

  test('syncing from storage hands the gateway the current plan', () async {
    final repository = await _demoRepository();
    await recordAlarmResponse(
      repository: repository,
      response: const AlarmResponse(
        slotKey: slotKey,
        action: DoseAction.snoozed,
      ),
      now: now,
      eventId: 'snooze',
    );
    final gateway = FakeAlarmGateway();

    final result = await syncAlarmsFromStorage(
      repository: repository,
      gateway: gateway,
      now: now,
    );

    expect(result, isA<Ok<void, StorageFailure>>());
    final (plan, settings) = gateway.applied.single;
    expect(settings.snoozeMinutes, AppSettings.defaults.snoozeMinutes);
    expect(plan.upcoming.first.slotKey, slotKey);
    expect(plan.upcoming.first.fireAt, DateTime(2026, 8, 26, 8, 13));
    expect(plan.ringingSlotKeys, {
      'demo-vitamin-d3@2026-08-26T08:00',
      'demo-omega-3@2026-08-26T08:00',
    });
  });
}
