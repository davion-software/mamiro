import 'dart:async';
import 'dart:developer' as developer;
import 'dart:math';

import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mamiro/app.dart';
import 'package:mamiro/core/app_log.dart';
import 'package:mamiro/core/id_generator.dart';
import 'package:mamiro/core/result.dart';
import 'package:mamiro/data/app_database.dart';
import 'package:mamiro/data/database_connection.dart';
import 'package:mamiro/data/providers.dart';
import 'package:mamiro/data/repository.dart';
import 'package:mamiro/services/alarm_background.dart';
import 'package:mamiro/services/alarm_gateway.dart';
import 'package:mamiro/services/alarm_sync.dart';
import 'package:mamiro/services/app_providers.dart';
import 'package:mamiro/services/local_alarm_gateway.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  _installErrorHandlers();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  final database = AppDatabase(await openDatabaseConnection());
  final repository = MamiroRepository(database);
  const appClock = Clock();
  final initialization = await repository.initialize(now: appClock.now());
  switch (initialization) {
    case Ok():
      break;
    case Err(:final failure):
      developer.log(failure.code, name: 'mamiro.bootstrap');
  }

  final idGenerator = createIdGenerator(appClock, Random.secure());
  final alarmGateway = await LocalAlarmGateway.create(
    onResponse: (response) => unawaited(
      _recordAlarmResponse(
        repository,
        response,
        appClock.now(),
        idGenerator(),
      ).catchError(unexpectedLogger('mamiro.alarms', 'alarms.response')),
    ),
    onBackgroundResponse: onAlarmBackgroundResponse,
  );
  runApp(
    ProviderScope(
      retry: (count, error) => null,
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        mamiroRepositoryProvider.overrideWithValue(repository),
        clockProvider.overrideWithValue(appClock),
        idGeneratorProvider.overrideWithValue(idGenerator),
        alarmGatewayProvider.overrideWithValue(alarmGateway),
      ],
      child: const MamiroApp(),
    ),
  );
}

Future<void> _recordAlarmResponse(
  MamiroRepository repository,
  AlarmResponse response,
  DateTime now,
  String eventId,
) async {
  final result = await recordAlarmResponse(
    repository: repository,
    response: response,
    now: now,
    eventId: eventId,
  );
  if (result case Err(:final failure)) logFailure('mamiro.alarms', failure);
}

void _installErrorHandlers() {
  FlutterError.onError = (details) {
    try {
      FlutterError.presentError(details);
      developer.log(
        details.exceptionAsString(),
        name: 'mamiro.flutter',
        error: details.exception,
        stackTrace: details.stack,
      );
      // Licensed error-handler swallow marker: // ignore: swallowed_catch
    } on Object catch (_) {
      // Error handlers must never throw and recursively invoke themselves.
    }
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    try {
      developer.log(
        'uncaught async error',
        name: 'mamiro.platform',
        error: error,
        stackTrace: stack,
      );
      if (kDebugMode) debugPrint('$error\n$stack');
      // Licensed error-handler swallow marker: // ignore: swallowed_catch
    } on Object catch (_) {
      // Error handlers must never throw and recursively invoke themselves.
    }
    return true;
  };
}
