import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';
import 'package:mamiro/core/adherence.dart';
import 'package:mamiro/core/day_summary.dart';
import 'package:mamiro/core/dose_event.dart';
import 'package:mamiro/core/medication.dart';
import 'package:mamiro/core/schedule.dart';
import 'package:mamiro/core/storage_failure.dart';
import 'package:mamiro/data/providers.dart';
import 'package:mamiro/services/app_providers.dart';
import 'package:mamiro/services/async_combine.dart';

/// Logged events for one calendar day, newest first.
@immutable
final class LogDay {
  const LogDay({required this.day, required this.events});

  final DateTime day;
  final List<DoseEvent> events;
}

@immutable
final class HistoryState {
  const HistoryState({
    required this.now,
    required this.adherence,
    required this.streak,
    required this.days,
    required this.log,
    this.failure,
  });

  factory HistoryState.fromCabinet({
    required List<Medication> medications,
    required List<DoseEvent> events,
    required DateTime now,
  }) {
    final today = dateOnly(now);
    final recent = ([...events]..sort((a, b) => b.at.compareTo(a.at))).take(30);
    final log = <LogDay>[];
    for (final event in recent) {
      final day = dateOnly(event.at);
      final last = log.lastOrNull;
      if (last != null && last.day == day) {
        last.events.add(event);
      } else {
        log.add(LogDay(day: day, events: [event]));
      }
    }
    return HistoryState(
      now: now,
      // The same seven days as the strip below it.
      adherence: adherenceForRange(
        medications: medications,
        events: events,
        from: today.subtract(const Duration(days: 6)),
        to: today,
        now: now,
      ),
      streak: cleanStreak(medications: medications, events: events, now: now),
      days: lastSevenDays(medications: medications, events: events, now: now),
      log: log,
    );
  }

  factory HistoryState.unavailable(DateTime now, StorageFailure failure) {
    return HistoryState(
      now: now,
      adherence: const Adherence(taken: 0, skipped: 0, missed: 0),
      streak: 0,
      days: const [],
      log: const [],
      failure: failure,
    );
  }

  final DateTime now;
  final Adherence adherence;
  final int streak;
  final List<DaySummary> days;
  final List<LogDay> log;
  final StorageFailure? failure;
}

final class HistoryNotifier extends Notifier<AsyncValue<HistoryState>> {
  @override
  AsyncValue<HistoryState> build() {
    final now =
        ref.watch(currentMinuteProvider).value ??
        ref.watch(clockProvider).now();
    return combineAsync2(
      ref.watch(medicationsProvider),
      ref.watch(doseEventsProvider),
    ).whenData((results) {
      return foldResults2(
        first: results.$1,
        second: results.$2,
        onErr: (failure) => HistoryState.unavailable(now, failure),
        onOk: (medications, events) => HistoryState.fromCabinet(
          medications: medications,
          events: events,
          now: now,
        ),
      );
    });
  }
}

final historyNotifierProvider =
    NotifierProvider<HistoryNotifier, AsyncValue<HistoryState>>(
      HistoryNotifier.new,
    );
