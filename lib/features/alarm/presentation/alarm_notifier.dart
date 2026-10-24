import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';
import 'package:mamiro/core/app_log.dart';
import 'package:mamiro/core/app_settings.dart';
import 'package:mamiro/core/dose_event.dart';
import 'package:mamiro/core/dose_slot.dart';
import 'package:mamiro/core/medication.dart';
import 'package:mamiro/core/result.dart';
import 'package:mamiro/core/schedule.dart';
import 'package:mamiro/core/storage_failure.dart';
import 'package:mamiro/data/providers.dart';
import 'package:mamiro/services/app_providers.dart';
import 'package:mamiro/services/async_combine.dart';

@immutable
final class AlarmState {
  const AlarmState({
    required this.slot,
    required this.settings,
    required this.now,
    this.dueSlots = const [],
    this.actionFailure,
  });

  /// The dose on screen.
  final DoseSlot slot;

  /// Every dose due right now, [slot] first.
  final List<DoseSlot> dueSlots;
  final AppSettings settings;
  final DateTime now;
  final StorageFailure? actionFailure;

  AlarmState copyWith({StorageFailure? actionFailure}) {
    return AlarmState(
      slot: slot,
      dueSlots: dueSlots,
      settings: settings,
      now: now,
      actionFailure: actionFailure,
    );
  }
}

final class AlarmNotifier extends Notifier<AsyncValue<AlarmState?>> {
  Timer? _refreshTimer;

  @override
  AsyncValue<AlarmState?> build() {
    ref.onDispose(_cancelRefresh);
    ref.watch(currentMinuteProvider);
    final now = ref.watch(clockProvider).now();
    final testAlarm = ref.watch(testAlarmProvider);
    return combineAsync3(
      ref.watch(medicationsProvider),
      ref.watch(doseEventsProvider),
      ref.watch(settingsProvider),
    ).whenData((results) {
      return foldResults3(
        first: results.$1,
        second: results.$2,
        third: results.$3,
        onErr: (_) => _storageUnavailable(),
        onOk: (medications, events, settings) {
          if (testAlarm) return _testAlarm(medications, settings, now);
          return _scheduledAlarm(medications, events, settings, now);
        },
      );
    });
  }

  AlarmState? _storageUnavailable() {
    _cancelRefresh();
    return null;
  }

  AlarmState _testAlarm(
    List<Medication> medications,
    AppSettings settings,
    DateTime now,
  ) {
    _cancelRefresh();
    return AlarmState(
      slot: DoseSlot(
        medication: medications.isEmpty
            ? const Medication.sample()
            : medications.first,
        scheduledAt: now,
        status: SlotStatus.due,
        isTest: true,
      ),
      settings: settings,
      now: now,
    );
  }

  AlarmState? _scheduledAlarm(
    List<Medication> medications,
    List<DoseEvent> events,
    AppSettings settings,
    DateTime now,
  ) {
    _armRefresh(medications, events, now);
    return _dueAlarm(settings, medications, events, now);
  }

  void _armRefresh(
    List<Medication> medications,
    List<DoseEvent> events,
    DateTime now,
  ) {
    _cancelRefresh();
    final next = nextAlarmChange(
      medications: medications,
      events: events,
      now: now,
    );
    _refreshTimer = Timer(next.difference(now), () {
      _refreshTimer = null;
      if (!ref.mounted) return;
      ref.invalidateSelf();
    });
  }

  void _cancelRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  void take(String slotId) {
    unawaited(
      _record(
        slotId,
        DoseAction.taken,
      ).catchError(unexpectedLogger('mamiro.alarm', 'alarm.intent')),
    );
  }

  /// Takes every dose that is due now, the one on screen included.
  void takeAll() {
    unawaited(
      _takeAll().catchError(unexpectedLogger('mamiro.alarm', 'alarm.intent')),
    );
  }

  Future<void> _takeAll() async {
    final alarm = state.value;
    if (alarm == null || alarm.slot.isTest) return;
    final now = ref.read(clockProvider).now();
    for (final slot in alarm.dueSlots) {
      final result = await ref
          .read(mamiroRepositoryProvider)
          .recordSlot(
            slot: slot,
            action: DoseAction.taken,
            now: now,
            eventId: ref.read(idGeneratorProvider)(),
          );
      if (!ref.mounted) return;
      if (result case Err(:final failure)) {
        logFailure('mamiro.alarm', failure);
        state = AsyncData(alarm.copyWith(actionFailure: failure));
        return;
      }
    }
  }

  void skip(String slotId) {
    unawaited(
      _record(
        slotId,
        DoseAction.skipped,
      ).catchError(unexpectedLogger('mamiro.alarm', 'alarm.intent')),
    );
  }

  void snooze(String slotId) {
    unawaited(
      _record(
        slotId,
        DoseAction.snoozed,
      ).catchError(unexpectedLogger('mamiro.alarm', 'alarm.intent')),
    );
  }

  Future<void> _record(String slotId, DoseAction action) async {
    final alarm = state.value;
    if (alarm == null || alarm.slot.id != slotId) return;
    if (alarm.slot.isTest) {
      ref.read(testAlarmProvider.notifier).stop();
      return;
    }
    final result = await ref
        .read(mamiroRepositoryProvider)
        .recordSlot(
          slot: alarm.slot,
          action: action,
          now: ref.read(clockProvider).now(),
          eventId: ref.read(idGeneratorProvider)(),
          snoozeMinutes: alarm.settings.snoozeMinutes,
        );
    if (!ref.mounted) return;
    switch (result) {
      case Ok():
        return;
      case Err(:final failure):
        logFailure('mamiro.alarm', failure);
        state = AsyncData(alarm.copyWith(actionFailure: failure));
    }
  }

  AlarmState? _dueAlarm(
    AppSettings settings,
    List<Medication> medications,
    List<DoseEvent> events,
    DateTime now,
  ) {
    final slots = slotsForDay(
      medications: medications,
      events: events,
      day: now,
      now: now,
    );
    final due = slots.where((slot) => slot.status == SlotStatus.due).toList();
    if (due.isEmpty) return null;
    return AlarmState(
      slot: due.first,
      dueSlots: due,
      settings: settings,
      now: now,
    );
  }
}

final alarmNotifierProvider =
    NotifierProvider<AlarmNotifier, AsyncValue<AlarmState?>>(AlarmNotifier.new);
