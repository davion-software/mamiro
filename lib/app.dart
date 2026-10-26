import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mamiro/core/app_log.dart';
import 'package:mamiro/core/result.dart';
import 'package:mamiro/data/providers.dart';
import 'package:mamiro/features/alarm/presentation/alarm_overlay.dart';
import 'package:mamiro/features/alarm/presentation/alarm_notifier.dart';
import 'package:mamiro/features/undo/undo_snack_bar_host.dart';
import 'package:mamiro/l10n/l10n.dart';
import 'package:mamiro/routing/app_router.dart';
import 'package:mamiro/services/alarm_gateway.dart';
import 'package:mamiro/services/alarm_sync.dart';
import 'package:mamiro/services/app_providers.dart';
import 'package:mamiro/theme/mamiro_colors.dart';
import 'package:mamiro/theme/mamiro_theme.dart';
import 'package:mamiro/theme/theme_choice_provider.dart';
import 'package:mamiro/theme/widgets/sky_background.dart';

final class MamiroApp extends ConsumerStatefulWidget {
  const MamiroApp({super.key});

  @override
  ConsumerState<MamiroApp> createState() => _MamiroAppState();
}

final class _MamiroAppState extends ConsumerState<MamiroApp>
    with WidgetsBindingObserver {
  // Subscribed once in initState and closed in dispose.
  late final ProviderSubscription<AsyncValue<AlarmSchedule?>>
  _scheduleSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scheduleSubscription = ref.listenManual(
      alarmScheduleProvider,
      (previous, next) => _applySchedule(next.value),
      fireImmediately: true,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(
        _requestNotifications().catchError(
          unexpectedLogger('mamiro.alarms', 'alarms.request'),
        ),
      );
    });
  }

  @override
  void dispose() {
    _scheduleSubscription.close();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _applySchedule(AlarmSchedule? schedule) {
    if (schedule == null) return;
    unawaited(
      ref
          .read(alarmGatewayProvider)
          .apply(schedule.plan, schedule.settings)
          .catchError(unexpectedLogger('mamiro.alarms', 'alarms.apply')),
    );
  }

  Future<void> _requestNotifications() async {
    await ref.read(alarmGatewayProvider).requestNotifications();
    if (!mounted) return;
    ref.invalidate(alarmAccessProvider);
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      onGenerateTitle: (context) => context.l10n.appTitle,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      debugShowCheckedModeBanner: false,
      theme: mamiroTheme(MamiroColors.of(ref.watch(themeChoiceProvider))),
      routerConfig: router,
      builder: (context, child) {
        return SkyBackground(
          child: Stack(
            children: [
              child ?? const SizedBox.shrink(),
              const AlarmOverlay(),
              const UndoSnackBarHost(),
            ],
          ),
        );
      },
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        ref.read(mamiroRepositoryProvider).refreshWatchers();
        ref.invalidate(currentMinuteProvider);
        ref.invalidate(alarmNotifierProvider);
        ref.invalidate(alarmScheduleProvider);
        ref.invalidate(alarmAccessProvider);
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
        unawaited(
          _flush().catchError(
            unexpectedLogger('mamiro.lifecycle', 'lifecycle.flush'),
          ),
        );
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        break;
    }
  }

  Future<void> _flush() async {
    final result = await ref.read(mamiroRepositoryProvider).flush();
    switch (result) {
      case Ok():
        return;
      case Err(:final failure):
        logFailure('mamiro.lifecycle', failure);
    }
  }
}
