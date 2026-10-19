import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mamiro/core/app_log.dart';
import 'package:mamiro/core/result.dart';
import 'package:mamiro/data/providers.dart';
import 'package:mamiro/features/alarm/presentation/alarm_overlay.dart';
import 'package:mamiro/features/alarm/presentation/alarm_notifier.dart';
import 'package:mamiro/routing/app_router.dart';
import 'package:mamiro/services/app_providers.dart';
import 'package:mamiro/theme/mamiro_theme.dart';

final class MamiroApp extends ConsumerStatefulWidget {
  const MamiroApp({super.key});

  @override
  ConsumerState<MamiroApp> createState() => _MamiroAppState();
}

final class _MamiroAppState extends ConsumerState<MamiroApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'Mamiro',
      debugShowCheckedModeBanner: false,
      theme: mamiroTheme(),
      routerConfig: router,
      builder: (context, child) {
        return Stack(
          children: [child ?? const SizedBox.shrink(), const AlarmOverlay()],
        );
      },
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        ref.invalidate(currentMinuteProvider);
        ref.invalidate(alarmNotifierProvider);
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
