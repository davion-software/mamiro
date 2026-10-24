import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';
import 'package:mamiro/core/alarm_plan.dart';
import 'package:mamiro/core/app_settings.dart';
import 'package:mamiro/core/dose_event.dart';

@immutable
final class AlarmAccess {
  const AlarmAccess({
    required this.notifications,
    this.exactTiming,
    this.canRequestFullScreen = false,
  });

  static const unknown = AlarmAccess(notifications: false);

  final bool notifications;

  /// Null where the platform has no separate exact-alarm switch.
  final bool? exactTiming;

  final bool canRequestFullScreen;
}

/// A tap on a delivered alarm. A null [action] means the body was tapped.
@immutable
final class AlarmResponse {
  const AlarmResponse({required this.slotKey, this.action});

  final String slotKey;
  final DoseAction? action;
}

/// The OS alarm scheduler. Implementations never throw; platform failures
/// are logged and leave the previous schedule in place.
abstract interface class AlarmGateway {
  /// Makes the OS schedule match [plan], replacing anything stale.
  Future<void> apply(AlarmPlan plan, AppSettings settings);

  /// Silences every delivered alarm once the in-app alarm takes over.
  Future<void> dismissDelivered();

  Future<AlarmAccess> access();

  /// Shows the system permission prompt if the user has not answered yet.
  Future<void> requestNotifications();

  Future<void> openNotificationSettings();

  Future<void> requestExactTiming();

  Future<void> requestFullScreen();

  /// Schedules a one-off alarm at [at] to check that alarms ring while the
  /// app is closed. Later syncs leave it alone.
  Future<void> scheduleTest(DateTime at, AppSettings settings);
}

final alarmGatewayProvider = Provider<AlarmGateway>(
  (ref) =>
      throw UnimplementedError('Override alarmGatewayProvider in bootstrap'),
);

final alarmAccessProvider = FutureProvider<AlarmAccess>(
  (ref) => ref.watch(alarmGatewayProvider).access(),
);
