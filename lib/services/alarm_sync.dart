import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';
import 'package:mamiro/core/alarm_plan.dart';
import 'package:mamiro/core/app_settings.dart';
import 'package:mamiro/core/dose_slot.dart';
import 'package:mamiro/core/result.dart';
import 'package:mamiro/core/storage_failure.dart';
import 'package:mamiro/data/providers.dart';
import 'package:mamiro/data/repository.dart';
import 'package:mamiro/services/alarm_gateway.dart';
import 'package:mamiro/services/app_providers.dart';
import 'package:mamiro/services/async_combine.dart';

@immutable
final class AlarmSchedule {
  const AlarmSchedule({required this.plan, required this.settings});

  final AlarmPlan plan;
  final AppSettings settings;
}

/// The OS alarms the cabinet calls for right now. Null while storage is
/// unavailable, so a read failure never wipes the existing schedule.
final alarmScheduleProvider = Provider<AsyncValue<AlarmSchedule?>>((ref) {
  final now = ref.watch(clockProvider).now();
  return combineAsync3(
    ref.watch(medicationsProvider),
    ref.watch(doseEventsProvider),
    ref.watch(settingsProvider),
  ).whenData((results) {
    return foldResults3(
      first: results.$1,
      second: results.$2,
      third: results.$3,
      onErr: (_) => null,
      onOk: (medications, events, settings) => AlarmSchedule(
        plan: planAlarms(medications: medications, events: events, now: now),
        settings: settings,
      ),
    );
  });
});

/// Records a Take, Snooze, or Skip chosen on an OS alarm. Body taps carry no
/// action; the app opens and the in-app alarm handles them.
Future<Result<void, StorageFailure>> recordAlarmResponse({
  required MamiroRepository repository,
  required AlarmResponse response,
  required DateTime now,
  required String eventId,
}) async {
  final action = response.action;
  final target = SlotRef.parse(response.slotKey);
  if (action == null || target == null) return const Ok(null);
  final snapshot = await repository.readSnapshot();
  switch (snapshot) {
    case Err(:final failure):
      return Err(failure);
    case Ok(:final value):
      final medication = value.medications
          .where((medication) => medication.id == target.medicationId)
          .firstOrNull;
      if (medication == null) return const Ok(null);
      return await repository.recordSlot(
        slot: DoseSlot(
          medication: medication,
          scheduledAt: target.scheduledAt,
          status: SlotStatus.due,
        ),
        action: action,
        now: now,
        eventId: eventId,
        snoozeMinutes: value.settings.snoozeMinutes,
      );
  }
}

/// Rebuilds the OS schedule straight from storage, for isolates that run
/// without the provider tree.
Future<Result<void, StorageFailure>> syncAlarmsFromStorage({
  required MamiroRepository repository,
  required AlarmGateway gateway,
  required DateTime now,
}) async {
  final snapshot = await repository.readSnapshot();
  switch (snapshot) {
    case Err(:final failure):
      return Err(failure);
    case Ok(:final value):
      await gateway.apply(
        planAlarms(
          medications: value.medications,
          events: value.events,
          now: now,
        ),
        value.settings,
      );
      return const Ok(null);
  }
}
