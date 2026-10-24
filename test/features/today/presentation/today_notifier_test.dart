import 'dart:async';

import 'package:clock/clock.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mamiro/core/app_settings.dart';
import 'package:mamiro/core/dose_slot.dart';
import 'package:mamiro/core/result.dart';
import 'package:mamiro/core/storage_failure.dart';
import 'package:mamiro/data/app_database.dart';
import 'package:mamiro/data/providers.dart';
import 'package:mamiro/data/repository.dart';
import 'package:mamiro/features/today/presentation/today_notifier.dart';
import 'package:mamiro/services/app_providers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('take intent publishes a taken slot after it is persisted', () async {
    SharedPreferences.setMockInitialValues({});
    final now = DateTime(2026, 8, 26, 8, 5);
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = MamiroRepository(database);
    expect(await repository.initialize(), isA<Ok<void, StorageFailure>>());
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        mamiroRepositoryProvider.overrideWithValue(repository),
        clockProvider.overrideWithValue(Clock.fixed(now)),
        idGeneratorProvider.overrideWithValue(() => 'notifier-event'),
        currentMinuteProvider.overrideWithValue(AsyncData(now)),
      ],
    );
    addTearDown(container.dispose);

    final initial = await _waitForToday(
      container,
      (state) => state.due.isNotEmpty,
    );
    final slot = initial.due.first.slots.first;
    final updatedFuture = _waitForToday(
      container,
      (state) => state.done
          .where(
            (item) => item.id == slot.id && item.status == SlotStatus.taken,
          )
          .isNotEmpty,
    );

    container.read(todayNotifierProvider.notifier).take(slot.id);

    final updated = await updatedFuture;
    expect(updated.takenCount, 1);
  });

  test('settings writes complete while Today is subscribed', () async {
    SharedPreferences.setMockInitialValues({});
    final now = DateTime(2026, 8, 26, 8, 5);
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = MamiroRepository(database);
    expect(await repository.initialize(), isA<Ok<void, StorageFailure>>());
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        mamiroRepositoryProvider.overrideWithValue(repository),
        clockProvider.overrideWithValue(Clock.fixed(now)),
        idGeneratorProvider.overrideWithValue(() => 'notifier-event'),
        currentMinuteProvider.overrideWithValue(AsyncData(now)),
      ],
    );
    addTearDown(container.dispose);
    await _waitForToday(container, (state) => state.due.isNotEmpty);

    expect(
      await repository.updateSettings(
        AppSettings.defaults.copyWith(sound: false),
      ),
      isA<Ok<void, StorageFailure>>(),
    );
    final snapshot = await repository.readSnapshot();
    switch (snapshot) {
      case Ok(:final value):
        expect(value.settings.sound, isFalse);
      case Err(:final failure):
        fail('Unexpected storage failure: ${failure.code}');
    }
  });

  test('clock changes update Today without returning to loading', () async {
    SharedPreferences.setMockInitialValues({});
    final beforeDose = DateTime(2026, 8, 26, 7, 59, 59);
    final ticks = StreamController<DateTime>();
    addTearDown(ticks.close);
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = MamiroRepository(database);
    expect(await repository.initialize(), isA<Ok<void, StorageFailure>>());
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        mamiroRepositoryProvider.overrideWithValue(repository),
        clockProvider.overrideWithValue(Clock.fixed(beforeDose)),
        idGeneratorProvider.overrideWithValue(() => 'notifier-event'),
        currentMinuteProvider.overrideWith((ref) => ticks.stream),
      ],
    );
    addTearDown(container.dispose);
    final transitions = <AsyncValue<TodayState>>[];
    final subscription = container.listen(
      todayNotifierProvider,
      (previous, next) => transitions.add(next),
      fireImmediately: true,
    );
    addTearDown(subscription.close);

    final initial = await _waitForToday(
      container,
      (state) => state.next?.time.hour == 8,
    );
    final slotId = initial.next!.slots.first.id;
    transitions.clear();
    final updatedFuture = _waitForToday(
      container,
      (state) => _waiting(state).where((slot) => slot.id == slotId).isNotEmpty,
    );

    ticks.add(DateTime(2026, 8, 26, 8));

    final updated = await updatedFuture;
    expect(_waiting(updated).where((slot) => slot.id == slotId), isNotEmpty);
    expect(transitions, isNotEmpty);
    expect(transitions.every((state) => !state.isLoading), isTrue);
  });

  test('take all, undo, and restock keep the count honest', () async {
    SharedPreferences.setMockInitialValues({});
    final now = DateTime(2026, 8, 26, 8, 5);
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = MamiroRepository(database);
    expect(
      await repository.initialize(now: DateTime(2026, 8, 20)),
      isA<Ok<void, StorageFailure>>(),
    );
    var nextId = 0;
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        mamiroRepositoryProvider.overrideWithValue(repository),
        clockProvider.overrideWithValue(Clock.fixed(now)),
        idGeneratorProvider.overrideWithValue(() => 'event-${nextId++}'),
        currentMinuteProvider.overrideWithValue(AsyncData(now)),
      ],
    );
    addTearDown(container.dispose);
    final notifier = container.read(todayNotifierProvider.notifier);

    final initial = await _waitForToday(
      container,
      (state) => state.due.isNotEmpty,
    );
    final eight = initial.due.single;
    expect(eight.slots, hasLength(3));

    notifier.takeAll([for (final slot in eight.slots) slot.id]);
    final allTaken = await _waitForToday(
      container,
      (state) => state.takenCount == 3 && state.refillSoon.single.quantity == 7,
    );
    final vitamin = allTaken.done.firstWhere(
      (slot) => slot.medication.id == 'demo-vitamin-d3',
    );
    expect(vitamin.resolvedAt, now);
    expect(
      allTaken.refillSoon.single.quantity,
      7,
      reason: 'Vitamin D3 started at 8 and one was taken',
    );

    notifier.undo(vitamin.id);
    final undone = await _waitForToday(
      container,
      (state) => state.takenCount == 2 && state.refillSoon.single.quantity == 8,
    );
    expect(_waiting(undone).map((slot) => slot.id), contains(vitamin.id));
    expect(undone.refillSoon.single.quantity, 8);

    notifier.restock('demo-vitamin-d3', 30);
    final restocked = await _waitForToday(
      container,
      (state) => state.refillSoon.isEmpty,
    );
    expect(restocked.next?.time, DateTime(2026, 8, 26, 20));
  });
}

Future<TodayState> _waitForToday(
  ProviderContainer container,
  bool Function(TodayState state) predicate,
) async {
  final current = container.read(todayNotifierProvider).value;
  if (current != null && predicate(current)) return current;

  final completer = Completer<TodayState>();
  final subscription = container.listen(todayNotifierProvider, (
    previous,
    next,
  ) {
    final value = next.value;
    if (!completer.isCompleted && value != null && predicate(value)) {
      completer.complete(value);
    }
  });
  try {
    return await completer.future.timeout(const Duration(seconds: 2));
  } finally {
    subscription.close();
  }
}

List<DoseSlot> _waiting(TodayState state) => [
  for (final group in state.due) ...group.slots,
];
