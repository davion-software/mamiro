import 'dart:developer' as developer;
import 'dart:math';

import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mamiro/app.dart';
import 'package:mamiro/core/id_generator.dart';
import 'package:mamiro/core/result.dart';
import 'package:mamiro/data/app_database.dart';
import 'package:mamiro/data/database_connection.dart';
import 'package:mamiro/data/providers.dart';
import 'package:mamiro/data/repository.dart';
import 'package:mamiro/services/app_providers.dart';
import 'package:mamiro/theme/palette.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  _installErrorHandlers();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: MamiroPalette.paper,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  final database = AppDatabase(await openDatabaseConnection());
  final repository = MamiroRepository(database);
  final initialization = await repository.initialize();
  switch (initialization) {
    case Ok():
      break;
    case Err(:final failure):
      developer.log(failure.code, name: 'mamiro.bootstrap');
  }

  const appClock = Clock();
  final idGenerator = _createIdGenerator(appClock, Random.secure());
  runApp(
    ProviderScope(
      retry: (count, error) => null,
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        mamiroRepositoryProvider.overrideWithValue(repository),
        clockProvider.overrideWithValue(appClock),
        idGeneratorProvider.overrideWithValue(idGenerator),
      ],
      child: const MamiroApp(),
    ),
  );
}

IdGenerator _createIdGenerator(Clock appClock, Random random) {
  return () {
    final timestamp = appClock.now().microsecondsSinceEpoch.toRadixString(36);
    final noise = random.nextInt(0x7fffffff).toRadixString(36);
    return '$timestamp$noise';
  };
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
