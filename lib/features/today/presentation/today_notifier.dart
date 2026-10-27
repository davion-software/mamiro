import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';
import 'package:mamiro/core/app_log.dart';
import 'package:mamiro/core/dose_event.dart';
import 'package:mamiro/core/dose_slot.dart';
import 'package:mamiro/core/medication.dart';
import 'package:mamiro/core/result.dart';
import 'package:mamiro/core/schedule.dart';
import 'package:mamiro/core/storage_failure.dart';
import 'package:mamiro/data/providers.dart';
import 'package:mamiro/data/repository.dart';
import 'package:mamiro/services/app_providers.dart';
import 'package:mamiro/services/async_combine.dart';

/// Doses that share a scheduled time.
@immutable
final class SlotGroup {
  const SlotGroup({required this.time, required this.slots});

  final DateTime time;
  final List<DoseSlot> slots;
}

List<SlotGroup> groupByTime(Iterable<DoseSlot> slots) {
  final groups = <SlotGroup>[];
  for (final slot in slots) {
    final last = groups.lastOrNull;
    if (last != null && last.time == slot.scheduledAt) {
      last.slots.add(slot);
    } else {
      groups.add(SlotGroup(time: slot.scheduledAt, slots: [slot]));
    }
  }
  return groups;
}

@immutable
final class TodayState {
  const TodayState({
    required this.now,
    required this.allSlots,
    required this.due,
    required this.next,
    required this.later,
    required this.done,
    required this.refillSoon,
    required this.hasMedications,
    required this.showBanner,
    this.failure,
    this.actionFailure,
  });

  factory TodayState.fromCabinet({
    required List<Medication> medications,
    required List<DoseEvent> events,
    required bool showBanner,
    required DateTime now,
    StorageFailure? failure,
  }) {
    final slots = slotsForDay(
      medications: medications,
      events: events,
      day: now,
      now: now,
    );
    final waiting = <DoseSlot>[];
    final upcoming = <DoseSlot>[];
    final done = <DoseSlot>[];
    for (final slot in slots) {
      switch (slot.status) {
        case SlotStatus.due:
        case SlotStatus.missed:
        case SlotStatus.snoozed:
          waiting.add(slot);
        case SlotStatus.later:
          upcoming.add(slot);
        case SlotStatus.taken:
        case SlotStatus.skipped:
          done.add(slot);
      }
    }
    final upcomingGroups = groupByTime(upcoming);
    return TodayState(
      now: now,
      allSlots: slots,
      due: groupByTime(waiting),
      next: upcomingGroups.firstOrNull,
      later: upcomingGroups.skip(1).toList(growable: false),
      done: done,
      refillSoon: medications.where((item) => item.needsRefill).toList(),
      hasMedications: medications.isNotEmpty,
      showBanner: showBanner,
      failure: failure,
    );
  }

  factory TodayState.unavailable(DateTime now, StorageFailure failure) {
    return TodayState(
      now: now,
      allSlots: const [],
      due: const [],
      next: null,
      later: const [],
      done: const [],
      refillSoon: const [],
      hasMedications: false,
      showBanner: false,
      failure: failure,
    );
  }

  final DateTime now;
  final List<DoseSlot> allSlots;

  /// Due, missed, and snoozed doses, by scheduled time.
  final List<SlotGroup> due;

  /// The next doses still to come today.
  final SlotGroup? next;
  final List<SlotGroup> later;
  final List<DoseSlot> done;
  final List<Medication> refillSoon;
  final bool hasMedications;
  final bool showBanner;
  final StorageFailure? failure;
  final StorageFailure? actionFailure;

  int get takenCount =>
      done.where((slot) => slot.status == SlotStatus.taken).length;

  int get waitingCount => due.fold(0, (sum, group) => sum + group.slots.length);

  TodayState copyWith({StorageFailure? actionFailure}) {
    return TodayState(
      now: now,
      allSlots: allSlots,
      due: due,
      next: next,
      later: later,
      done: done,
      refillSoon: refillSoon,
      hasMedications: hasMedications,
      showBanner: showBanner,
      failure: failure,
      actionFailure: actionFailure,
    );
  }
}

final class TodayNotifier extends Notifier<AsyncValue<TodayState>> {
  @override
  AsyncValue<TodayState> build() {
    final now =
        ref.watch(currentMinuteProvider).value ??
        ref.watch(clockProvider).now();
    return combineAsync3(
      ref.watch(medicationsProvider),
      ref.watch(doseEventsProvider),
      ref.watch(settingsProvider),
    ).whenData((results) {
      return foldResults3(
        first: results.$1,
        second: results.$2,
        third: results.$3,
        onErr: (failure) => TodayState.unavailable(now, failure),
        onOk: (medications, events, settings) => TodayState.fromCabinet(
          medications: medications,
          events: events,
          showBanner: settings.banners,
          now: now,
        ),
      );
    });
  }

  /// Logs the dose as taken at [takenAt], or now when it is null.
  void take(String slotId, {DateTime? takenAt}) {
    unawaited(
      _record(
        slotId,
        DoseAction.taken,
        at: takenAt,
      ).catchError(unexpectedLogger('mamiro.today', 'today.intent')),
    );
  }

  void skip(String slotId) {
    unawaited(
      _record(
        slotId,
        DoseAction.skipped,
      ).catchError(unexpectedLogger('mamiro.today', 'today.intent')),
    );
  }

  void takeAll(List<String> slotIds, {DateTime? takenAt}) {
    unawaited(
      _recordAll(
        slotIds,
        DoseAction.taken,
        at: takenAt,
      ).catchError(unexpectedLogger('mamiro.today', 'today.intent')),
    );
  }

  void undo(String slotId) {
    unawaited(
      _undo(slotId)
          .catchError(unexpectedLogger('mamiro.today', 'today.intent')),
    );
  }

  void restock(String medicationId, int count) {
    if (count <= 0) return;
    unawaited(
      _write(
        (repository) => repository.addPills(
          medicationId: medicationId,
          count: count,
          now: ref.read(clockProvider).now(),
        ),
      ).catchError(unexpectedLogger('mamiro.today', 'today.intent')),
    );
  }

  Future<void> _recordAll(
    List<String> slotIds,
    DoseAction action, {
    DateTime? at,
  }) async {
    for (final slotId in slotIds) {
      await _record(slotId, action, at: at);
      if (!ref.mounted) return;
    }
  }

  Future<void> _undo(String slotId) async {
    final slot = state.value?.allSlots
        .where((item) => item.id == slotId)
        .firstOrNull;
    if (slot == null) return;
    await _write(
      (repository) => repository.undoSlot(
        medicationId: slot.medication.id,
        scheduledAt: slot.scheduledAt,
        now: ref.read(clockProvider).now(),
      ),
    );
  }

  Future<void> _write(
    Future<Result<void, StorageFailure>> Function(MamiroRepository repository)
    write,
  ) async {
    final current = state.value;
    final result = await write(ref.read(mamiroRepositoryProvider));
    if (!ref.mounted || current == null) return;
    if (result case Err(:final failure)) {
      logFailure('mamiro.today', failure);
      state = AsyncData(current.copyWith(actionFailure: failure));
    }
  }

  Future<void> _record(String slotId, DoseAction action, {DateTime? at}) async {
    final current = state.value;
    if (current == null) return;
    final slot = current.allSlots
        .where((item) => item.id == slotId)
        .firstOrNull;
    if (slot == null) return;
    final result = await ref
        .read(mamiroRepositoryProvider)
        .recordSlot(
          slot: slot,
          action: action,
          now: at ?? ref.read(clockProvider).now(),
          eventId: ref.read(idGeneratorProvider)(),
        );
    if (!ref.mounted) return;
    switch (result) {
      case Ok():
        return;
      case Err(:final failure):
        logFailure('mamiro.today', failure);
        state = AsyncData(current.copyWith(actionFailure: failure));
    }
  }
}

final todayNotifierProvider =
    NotifierProvider<TodayNotifier, AsyncValue<TodayState>>(TodayNotifier.new);
