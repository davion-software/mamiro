import 'package:mamiro/core/alarm_plan.dart';
import 'package:mamiro/core/app_settings.dart';
import 'package:mamiro/services/alarm_gateway.dart';

final class FakeAlarmGateway implements AlarmGateway {
  FakeAlarmGateway({
    this.grantedAccess = const AlarmAccess(notifications: true),
  });

  final AlarmAccess grantedAccess;
  final applied = <(AlarmPlan, AppSettings)>[];
  int dismissals = 0;
  int notificationRequests = 0;

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
  Future<void> openNotificationSettings() async {}

  @override
  Future<void> requestExactTiming() async {}

  @override
  Future<void> requestFullScreen() async {}

  final scheduledTests = <DateTime>[];

  @override
  Future<void> scheduleTest(DateTime at, AppSettings settings) async =>
      scheduledTests.add(at);
}
