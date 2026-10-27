import 'package:clock/clock.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mamiro/app.dart';
import 'package:mamiro/core/result.dart';
import 'package:mamiro/core/storage_failure.dart';
import 'package:mamiro/data/app_database.dart';
import 'package:mamiro/data/providers.dart';
import 'package:mamiro/data/repository.dart';
import 'package:mamiro/services/alarm_gateway.dart';
import 'package:mamiro/services/app_providers.dart';
import 'package:mamiro/theme/mamiro_colors.dart';

import '../../../support/fake_alarm_gateway.dart';

const _noNotifications = "Alarms won't ring while the app is closed";
const _noExactTiming = 'Alarms may ring late';

Future<void> _pumpToday(
  WidgetTester tester,
  FakeAlarmGateway gateway, {
  bool emptyCabinet = false,
}) async {
  tester.view
    ..physicalSize = const Size(1200, 2400)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  SharedPreferences.setMockInitialValues({});
  final now = DateTime(2026, 8, 26, 7);
  final database = AppDatabase(NativeDatabase.memory());
  addTearDown(database.close);
  final repository = MamiroRepository(database);
  expect(
    await repository.initialize(now: DateTime(2026, 8, 20)),
    isA<Ok<void, StorageFailure>>(),
  );
  expect(
    await repository.markPermissionPrimerShown(),
    isA<Ok<void, StorageFailure>>(),
  );
  if (emptyCabinet) {
    expect(await repository.clearAll(now), isA<Ok<void, StorageFailure>>());
  }
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        mamiroRepositoryProvider.overrideWithValue(repository),
        clockProvider.overrideWithValue(Clock.fixed(now)),
        idGeneratorProvider.overrideWithValue(() => 'banner-event'),
        currentMinuteProvider.overrideWithValue(AsyncData(now)),
        alarmGatewayProvider.overrideWithValue(gateway),
      ],
      child: const MamiroApp(),
    ),
  );
  for (var frame = 0; frame < 5; frame++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Color? _textColor(WidgetTester tester, String text) =>
    tester.widget<Text>(find.text(text)).style?.color;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('without notifications Today warns and opens settings', (
    tester,
  ) async {
    final gateway = FakeAlarmGateway(
      grantedAccess: const AlarmAccess(
        notifications: false,
        exactTiming: false,
      ),
    );
    await _pumpToday(tester, gateway);

    // Both are missing; only the serious one shows.
    expect(find.text(_noNotifications), findsOneWidget);
    expect(find.text(_noExactTiming), findsNothing);
    final context = tester.element(find.text(_noNotifications));
    expect(_textColor(tester, _noNotifications), context.colors.danger);

    await tester.tap(find.text('Turn on'));
    await tester.pump();

    expect(gateway.settingsOpened, 1);
    expect(gateway.exactTimingRequests, 0);
  });

  testWidgets('without exact timing Today warns and asks for it', (
    tester,
  ) async {
    final gateway = FakeAlarmGateway(
      grantedAccess: const AlarmAccess(notifications: true, exactTiming: false),
    );
    await _pumpToday(tester, gateway);

    expect(find.text(_noExactTiming), findsOneWidget);
    expect(find.text(_noNotifications), findsNothing);
    final context = tester.element(find.text(_noExactTiming));
    expect(_textColor(tester, _noExactTiming), context.colors.warning);

    await tester.tap(find.text('Allow'));
    await tester.pump();

    expect(gateway.exactTimingRequests, 1);
    expect(gateway.settingsOpened, 0);
  });

  for (final exactTiming in [true, null]) {
    testWidgets('with granted access ($exactTiming) Today shows no warning', (
      tester,
    ) async {
      await _pumpToday(
        tester,
        FakeAlarmGateway(
          grantedAccess: AlarmAccess(
            notifications: true,
            exactTiming: exactTiming,
          ),
        ),
      );

      expect(find.text(_noNotifications), findsNothing);
      expect(find.text(_noExactTiming), findsNothing);
    });
  }

  testWidgets('granting access removes the warning when the app resumes', (
    tester,
  ) async {
    final gateway = FakeAlarmGateway(
      grantedAccess: const AlarmAccess(
        notifications: false,
        exactTiming: false,
      ),
    );
    await _pumpToday(tester, gateway);
    expect(find.text(_noNotifications), findsOneWidget);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    gateway.grantedAccess = const AlarmAccess(
      notifications: true,
      exactTiming: true,
    );
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    for (var frame = 0; frame < 5; frame++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(find.text(_noNotifications), findsNothing);
    expect(find.text(_noExactTiming), findsNothing);
  });

  testWidgets('an empty cabinet shows no warning', (tester) async {
    await _pumpToday(
      tester,
      FakeAlarmGateway(
        grantedAccess: const AlarmAccess(
          notifications: false,
          exactTiming: false,
        ),
      ),
      emptyCabinet: true,
    );

    expect(find.text(_noNotifications), findsNothing);
    expect(find.text(_noExactTiming), findsNothing);
  });
}
