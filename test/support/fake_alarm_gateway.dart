import 'package:mamiro/core/alarm_plan.dart';
import 'package:mamiro/core/app_settings.dart';
import 'package:mamiro/services/alarm_gateway.dart';

final class FakeAlarmGateway implements AlarmGateway {
  FakeAlarmGateway({
    this.grantedAccess = const AlarmAccess(notifications: true),
  });

  AlarmAccess grantedAccess;
  final applied = <(AlarmPlan, AppSettings)>[];
  int dismissals = 0;
  int notificationRequests = 0;
  int settingsOpened = 0;
  int exactTimingRequests = 0;

  @override
  Future<void> apply(AlarmPlan plan, AppSettings settings) async {
    applied.add((plan, settings));
  }

  @override
  Future<void> dismissDelivered() async => dismissals += 1;

  @override
  Future<AlarmAccess> access() async => grantedAccess;

  @override
  Future<void> requestNotifications() async => notificationRequests += 1;

  @override
  Future<void> openNotificationSettings() async => settingsOpened += 1;

  @override
  Future<void> requestExactTiming() async => exactTimingRequests += 1;

  @override
  Future<void> requestFullScreen() async {}

  final scheduledTests = <DateTime>[];

  @override
  Future<void> scheduleTest(DateTime at, AppSettings settings) async =>
      scheduledTests.add(at);
}
