import 'dart:async';

import 'package:clock/clock.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mamiro/app.dart';
import 'package:mamiro/core/dose_slot.dart';
import 'package:mamiro/core/medication.dart';
import 'package:mamiro/features/today/presentation/widgets/late_take_dialog.dart';
import 'package:mamiro/l10n/l10n.dart';
import 'package:mamiro/core/theme_choice.dart';
import 'package:mamiro/theme/mamiro_colors.dart';
import 'package:mamiro/features/alarm/presentation/alarm_overlay.dart';
import 'package:mamiro/core/result.dart';
import 'package:mamiro/core/storage_failure.dart';
import 'package:mamiro/data/app_database.dart';
import 'package:mamiro/data/providers.dart';
import 'package:mamiro/data/repository.dart';
import 'package:mamiro/services/alarm_gateway.dart';
import 'package:mamiro/services/app_providers.dart';

import 'support/fake_alarm_gateway.dart';

Future<void> pumpAppFrames(WidgetTester tester) async {
  for (var frame = 0; frame < 5; frame++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> pumpMamiro(
  WidgetTester tester, {
  DateTime? at,
  Stream<DateTime>? timeStream,
  Size size = const Size(1200, 2400),
  FakeAlarmGateway? alarmGateway,
  Locale? locale,
  DateTime? startedOn,
}) async {
  if (locale != null) {
    tester.platformDispatcher.localesTestValue = [locale];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
  }
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  SharedPreferences.setMockInitialValues({});
  final now = at ?? DateTime(2026, 8, 26, 7);
  final database = AppDatabase(NativeDatabase.memory());
  addTearDown(database.close);
  final repository = MamiroRepository(database);
  expect(
    await repository.initialize(now: startedOn ?? DateTime(2026, 8, 20)),
    isA<Ok<void, StorageFailure>>(),
  );
  var nextId = 0;
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        mamiroRepositoryProvider.overrideWithValue(repository),
        clockProvider.overrideWithValue(Clock.fixed(now)),
        idGeneratorProvider.overrideWithValue(() => 'widget-${nextId++}'),
        alarmGatewayProvider.overrideWithValue(
          alarmGateway ?? FakeAlarmGateway(),
        ),
        if (timeStream == null)
          currentMinuteProvider.overrideWithValue(AsyncData(now))
        else
          currentMinuteProvider.overrideWith((ref) => timeStream),
      ],
      child: const MamiroApp(),
    ),
  );
  await pumpAppFrames(tester);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('demo cabinet renders Today', (tester) async {
    await pumpMamiro(tester);

    expect(find.text('Good morning'), findsOneWidget);
    expect(find.text('Next: 3 doses at 8:00\u202fAM'), findsOneWidget);
    expect(find.textContaining('Vitamin D3'), findsWidgets);
    expect(find.text('0/5'), findsOneWidget);
    expect(find.text('Take all (3)'), findsOneWidget);
    expect(find.text('REFILL SOON'), findsOneWidget);
  });

  testWidgets('Today stays visible when the clock changes', (tester) async {
    final now = DateTime(2026, 8, 26, 7);
    final ticks = StreamController<DateTime>();
    addTearDown(ticks.close);
    await pumpMamiro(tester, at: now, timeStream: ticks.stream);
    expect(find.text('Good morning'), findsOneWidget);

    ticks.add(now.add(const Duration(minutes: 1)));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Good morning'), findsOneWidget);
    expect(find.textContaining('Vitamin D3'), findsWidgets);
  });

  testWidgets('four state-preserving shell branches open', (tester) async {
    await pumpMamiro(tester);

    await tester.tap(find.byTooltip('Meds'));
    await pumpAppFrames(tester);
    expect(find.text('Cabinet'), findsOneWidget);

    await tester.tap(find.byTooltip('History'));
    await pumpAppFrames(tester);
    expect(find.text('Last 7 days'), findsOneWidget);

    await tester.tap(find.byTooltip('Settings'));
    await pumpAppFrames(tester);
    expect(
      find.textContaining(
        'Alarms ring at dose time, even when Mamiro is closed',
      ),
      findsOneWidget,
    );
    expect(find.text('ALARM ACCESS'), findsOneWidget);
  });

  testWidgets('launch schedules OS alarms and asks for notifications', (
    tester,
  ) async {
    final gateway = FakeAlarmGateway();
    await pumpMamiro(tester, alarmGateway: gateway);

    expect(gateway.notificationRequests, 1);
    final (plan, _) = gateway.applied.last;
    expect(plan.upcoming.first.fireAt, DateTime(2026, 8, 26, 8));
    expect(plan.upcoming.first.slotKey, startsWith('demo-'));
  });

  testWidgets('a foreground alarm silences OS alarms only while on screen', (
    tester,
  ) async {
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    final gateway = FakeAlarmGateway();
    await pumpMamiro(
      tester,
      at: DateTime(2026, 8, 26, 8, 5),
      alarmGateway: gateway,
    );

    expect(find.text('Dose due · 1 of 3'), findsOneWidget);
    expect(gateway.dismissals, 1);

    await tester.pump(const Duration(seconds: 2));
    expect(gateway.dismissals, 2);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump(const Duration(seconds: 2));
    expect(gateway.dismissals, 2);
  });

  testWidgets('adding a medication returns to the cabinet', (tester) async {
    await pumpMamiro(tester);
    await tester.tap(find.byTooltip('Meds'));
    await pumpAppFrames(tester);
    await tester.tap(find.byIcon(Icons.add));
    await pumpAppFrames(tester);

    await tester.enterText(find.byType(TextFormField).at(0), 'Aspirin');
    await tester.enterText(find.byType(TextFormField).at(1), '81 mg');
    await tester.tap(find.text('Save'));
    await pumpAppFrames(tester);

    expect(find.text('Aspirin'), findsOneWidget);
  });

  testWidgets('a due dose opens an alarm that fits a short phone', (
    tester,
  ) async {
    await pumpMamiro(
      tester,
      at: DateTime(2026, 8, 26, 8, 5),
      size: const Size(320, 568),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Dose due · 1 of 3'), findsOneWidget);
    expect(find.text('Take now'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(AlarmOverlay),
        matching: find.text('Take all (3)'),
      ),
      findsOneWidget,
    );
    expect(find.text('Snooze 10 min'), findsOneWidget);
  });

  testWidgets('a fresh install shows no missed days before it started', (
    tester,
  ) async {
    await pumpMamiro(tester, startedOn: DateTime(2026, 8, 26, 6));
    await tester.tap(find.byTooltip('History'));
    await pumpAppFrames(tester);

    expect(find.text('—'), findsOneWidget);
    expect(find.text('No doses to count yet.'), findsOneWidget);
    expect(find.text('No streak yet'), findsOneWidget);
  });

  testWidgets('Spanish devices get Spanish copy and 24-hour times', (
    tester,
  ) async {
    await pumpMamiro(tester, locale: const Locale('es', 'ES'));

    expect(find.text('Buenos días'), findsOneWidget);
    expect(find.text('Próxima: 3 tomas a las 8:00'), findsOneWidget);
    expect(find.text('Hoy'), findsOneWidget);
    expect(find.text('REPONER PRONTO'), findsOneWidget);
  });

  testWidgets('unknown routes hide technical details', (tester) async {
    await pumpMamiro(tester);
    final context = tester.element(find.byType(Scaffold).first);
    GoRouter.of(context).go('/not-a-route');
    await pumpAppFrames(tester);

    expect(find.text("We couldn't find that screen."), findsOneWidget);
    expect(find.textContaining('GoException'), findsNothing);
  });

  testWidgets('choosing specific days requires at least one', (tester) async {
    await pumpMamiro(tester);
    await tester.tap(find.byTooltip('Meds'));
    await pumpAppFrames(tester);
    await tester.tap(find.byIcon(Icons.add).first);
    await pumpAppFrames(tester);

    await tester.enterText(find.byType(TextFormField).at(0), 'Aspirin');
    await tester.enterText(find.byType(TextFormField).at(1), '81 mg');
    await tester.tap(find.text('Specific days'));
    await pumpAppFrames(tester);
    await tester.tap(find.text('Save'));
    await pumpAppFrames(tester);

    expect(find.text('Pick at least one day'), findsOneWidget);
    expect(find.text('Add medication'), findsOneWidget);
  });

  testWidgets('the default theme is night blue and apricot', (tester) async {
    await pumpMamiro(tester);

    final context = tester.element(find.text('Good morning'));
    expect(context.colors, MamiroColors.nightApricot);
  });

  testWidgets('picking a theme in Settings restyles the app', (tester) async {
    await pumpMamiro(tester);
    await tester.tap(find.byTooltip('Settings'));
    await pumpAppFrames(tester);

    final option = find.text('Teal & coral');
    await tester.scrollUntilVisible(option, 200);
    await tester.tap(option);
    await pumpAppFrames(tester);

    final context = tester.element(find.text('Teal & coral'));
    expect(context.colors, MamiroColors.of(ThemeChoice.tealCoral));
    expect(find.text('Default'), findsOneWidget);
  });

  testWidgets('a late take asks when it was really taken', (tester) async {
    await pumpMamiro(tester, at: DateTime(2026, 8, 26, 10, 30));

    await tester.tap(find.text('Take').first);
    await pumpAppFrames(tester);
    expect(find.text('When did you take Lisinopril?'), findsOneWidget);
    expect(find.text('Now (10:30\u202fAM)'), findsOneWidget);

    await tester.tap(find.text('On time (8:00\u202fAM)'));
    await pumpAppFrames(tester);

    expect(find.text('When did you take Lisinopril?'), findsNothing);
    expect(find.text('Taken at 8:00\u202fAM'), findsOneWidget);
  });

  testWidgets('cancelling the late-take question records nothing', (
    tester,
  ) async {
    await pumpMamiro(tester, at: DateTime(2026, 8, 26, 10, 30));

    await tester.tap(find.text('Take all (3)'));
    await pumpAppFrames(tester);
    expect(find.text('When did you take these 3 doses?'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await pumpAppFrames(tester);
    expect(find.text('Take all (3)'), findsOneWidget);
    expect(find.textContaining('Taken at'), findsNothing);
  });

  testWidgets('a late group uses one answer for every dose', (tester) async {
    await pumpMamiro(tester, at: DateTime(2026, 8, 26, 10, 30));

    await tester.tap(find.text('Take all (3)'));
    await pumpAppFrames(tester);
    expect(find.text('When did you take these 3 doses?'), findsOneWidget);

    await tester.tap(find.text('On time (8:00\u202fAM)'));
    await pumpAppFrames(tester);

    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('Taken at 8:00\u202fAM'), findsNWidgets(3));
    expect(find.text('3/5'), findsOneWidget);
  });

  testWidgets('a late take can be recorded now', (tester) async {
    await pumpMamiro(tester, at: DateTime(2026, 8, 26, 10, 30));

    await tester.tap(find.text('Take').first);
    await pumpAppFrames(tester);
    await tester.tap(find.text('Now (10:30\u202fAM)'));
    await pumpAppFrames(tester);

    expect(find.text('Taken at 10:30\u202fAM'), findsOneWidget);
  });

  testWidgets('the late-take question uses Spanish times', (tester) async {
    await pumpMamiro(
      tester,
      at: DateTime(2026, 8, 26, 10, 30),
      locale: const Locale('es', 'ES'),
    );

    await tester.tap(find.text('Tomar').first);
    await pumpAppFrames(tester);
    expect(find.text('¿Cuándo tomaste Lisinopril?'), findsOneWidget);
    expect(find.text('Ahora (10:30)'), findsOneWidget);

    await tester.tap(find.text('A su hora (8:00)'));
    await pumpAppFrames(tester);
    expect(find.text('Tomada a las 8:00'), findsOneWidget);
  });

  for (final (hour, minute, expected, adjusted) in [
    ('9', '15', '9:15\u202fAM', false),
    ('7', '00', '8:00\u202fAM', true),
    ('11', '00', '10:30\u202fAM', true),
  ]) {
    testWidgets('another time $hour:$minute records $expected', (tester) async {
      await pumpMamiro(tester, at: DateTime(2026, 8, 26, 10, 30));
      await tester.tap(find.text('Take').first);
      await pumpAppFrames(tester);
      await tester.tap(find.text('Another time…'));
      await pumpAppFrames(tester);
      await tester.tap(find.byIcon(Icons.keyboard_outlined));
      await pumpAppFrames(tester);
      await tester.enterText(find.byType(TextFormField).at(0), hour);
      await tester.enterText(find.byType(TextFormField).at(1), minute);
      await tester.tap(find.text('OK'));
      await pumpAppFrames(tester);

      expect(find.text('Taken at $expected'), findsOneWidget);
      if (adjusted) {
        expect(
          find.text(
            'Set to $expected: it must be between the scheduled time and now.',
          ),
          findsOneWidget,
        );
      }
    });
  }

  testWidgets('doses within the threshold are taken without asking', (
    tester,
  ) async {
    late BuildContext context;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (built) {
            context = built;
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    final slot = DoseSlot(
      medication: const Medication.sample(),
      scheduledAt: DateTime(2026, 8, 26, 8),
      status: SlotStatus.due,
    );

    final answer = await askTakenAt(
      context,
      slots: [slot],
      now: DateTime(2026, 8, 26, 8, 20),
    );
    await tester.pump();

    expect(answer?.at, isNull);
    expect(answer, isNotNull);
    expect(find.byType(AlertDialog), findsNothing);
  });
}
