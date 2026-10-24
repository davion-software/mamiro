import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:clock/clock.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mamiro/core/app_log.dart';
import 'package:mamiro/core/id_generator.dart';
import 'package:mamiro/core/result.dart';
import 'package:mamiro/data/app_database.dart';
import 'package:mamiro/data/database_connection.dart';
import 'package:mamiro/data/repository.dart';
import 'package:mamiro/services/alarm_sync.dart';
import 'package:mamiro/services/local_alarm_gateway.dart';

/// Entry point for Take, Snooze, and Skip chosen on an OS alarm while the
/// app is closed. The plugin runs it in a fresh background isolate.
@pragma('vm:entry-point')
void onAlarmBackgroundResponse(NotificationResponse notification) {
  unawaited(
    _handle(notification)
        .catchError(unexpectedLogger('mamiro.alarms', 'alarms.background')),
  );
}

Future<void> _handle(NotificationResponse notification) async {
  final response = decodeAlarmResponse(notification);
  if (response == null || response.action == null) return;
  DartPluginRegistrant.ensureInitialized();
  final database = AppDatabase(await openDatabaseConnection());
  try {
    final repository = MamiroRepository(database);
    const appClock = Clock();
    final recorded = await recordAlarmResponse(
      repository: repository,
      response: response,
      now: appClock.now(),
      eventId: createIdGenerator(appClock, Random.secure())(),
    );
    if (recorded case Err(:final failure)) {
      logFailure('mamiro.alarms', failure);
      return;
    }
    final gateway = await LocalAlarmGateway.create(
      onResponse: (_) {},
      onBackgroundResponse: onAlarmBackgroundResponse,
    );
    final synced = await syncAlarmsFromStorage(
      repository: repository,
      gateway: gateway,
      now: appClock.now(),
    );
    if (synced case Err(:final failure)) logFailure('mamiro.alarms', failure);
  } finally {
    await database.close();
  }
}
