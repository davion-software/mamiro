import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';
import 'package:mamiro/core/app_log.dart';
import 'package:mamiro/core/app_settings.dart';
import 'package:mamiro/core/result.dart';
import 'package:mamiro/core/storage_failure.dart';
import 'package:mamiro/data/providers.dart';
import 'package:mamiro/services/alarm_gateway.dart';
import 'package:mamiro/services/app_providers.dart';

const closedAppTestDelay = Duration(seconds: 10);

enum SettingsNotice { demoRestored, cleared, testScheduled }

@immutable
final class SettingsFeedback {
  const SettingsFeedback({this.notice, this.failure, this.testAt});

  final SettingsNotice? notice;
  final StorageFailure? failure;

  /// When the closed-app test alarm will ring.
  final DateTime? testAt;
}

final class SettingsFeedbackNotifier extends Notifier<SettingsFeedback> {
  @override
  SettingsFeedback build() => const SettingsFeedback();

  void succeed(SettingsNotice notice, {DateTime? testAt}) =>
      state = SettingsFeedback(notice: notice, testAt: testAt);

  void fail(StorageFailure failure) =>
      state = SettingsFeedback(failure: failure);

  void clear() => state = const SettingsFeedback();
}

final settingsFeedbackProvider =
    NotifierProvider<SettingsFeedbackNotifier, SettingsFeedback>(
      SettingsFeedbackNotifier.new,
    );

@immutable
final class SettingsState {
  const SettingsState({required this.settings, this.failure});

  final AppSettings settings;
  final StorageFailure? failure;
}

final class SettingsNotifier extends Notifier<AsyncValue<SettingsState>> {
  @override
  AsyncValue<SettingsState> build() {
    return ref.watch(settingsProvider).whenData((result) {
      return switch (result) {
        Ok(:final value) => SettingsState(settings: value),
        Err(:final failure) => SettingsState(
          settings: AppSettings.defaults,
          failure: failure,
        ),
      };
    });
  }

  void setSound(bool value) =>
      _update((settings) => settings.copyWith(sound: value));

  void setVibration(bool value) =>
      _update((settings) => settings.copyWith(vibration: value));

  void setBanners(bool value) =>
      _update((settings) => settings.copyWith(banners: value));

  void setSnoozeMinutes(int value) =>
      _update((settings) => settings.copyWith(snoozeMinutes: value));

  void startTestAlarm() => ref.read(testAlarmProvider.notifier).start();

  /// Rings shortly through the OS, so it can be checked with the app closed.
  void scheduleClosedAppTest() {
    final settings = state.value?.settings;
    if (settings == null) return;
    final at = ref.read(clockProvider).now().add(closedAppTestDelay);
    unawaited(
      ref
          .read(alarmGatewayProvider)
          .scheduleTest(at, settings)
          .then((_) {
            if (!ref.mounted) return;
            ref
                .read(settingsFeedbackProvider.notifier)
                .succeed(SettingsNotice.testScheduled, testAt: at);
          })
          .catchError(unexpectedLogger('mamiro.settings', 'settings.test')),
    );
  }

  // Each opens a system screen; access is re-read when the app resumes.
  void openNotificationSettings() =>
      _openSystem((gateway) => gateway.openNotificationSettings());

  void requestExactTiming() =>
      _openSystem((gateway) => gateway.requestExactTiming());

  void requestFullScreen() =>
      _openSystem((gateway) => gateway.requestFullScreen());

  void _openSystem(Future<void> Function(AlarmGateway gateway) open) {
    unawaited(
      open(ref.read(alarmGatewayProvider)).catchError(
        unexpectedLogger('mamiro.settings', 'settings.alarm_access'),
      ),
    );
  }

  void restoreDemo() {
    unawaited(
      _restoreDemo().catchError(
        unexpectedLogger('mamiro.settings', 'settings.intent'),
      ),
    );
  }

  void clearAll() {
    unawaited(
      _clearAll().catchError(
        unexpectedLogger('mamiro.settings', 'settings.intent'),
      ),
    );
  }

  void _update(AppSettings Function(AppSettings) change) {
    final current = state.value?.settings;
    if (current == null) return;
    unawaited(
      _persistSettings(change(current))
          .catchError(unexpectedLogger('mamiro.settings', 'settings.intent')),
    );
  }

  Future<void> _persistSettings(AppSettings settings) async {
    final result = await ref
        .read(mamiroRepositoryProvider)
        .updateSettings(settings);
    if (!ref.mounted) return;
    _applyWrite(result);
  }

  Future<void> _restoreDemo() async {
    final result = await ref
        .read(mamiroRepositoryProvider)
        .restoreDemo(ref.read(clockProvider).now());
    if (!ref.mounted) return;
    _applyWrite(result, notice: SettingsNotice.demoRestored);
  }

  Future<void> _clearAll() async {
    final result = await ref
        .read(mamiroRepositoryProvider)
        .clearAll(ref.read(clockProvider).now());
    if (!ref.mounted) return;
    _applyWrite(result, notice: SettingsNotice.cleared);
  }

  void _applyWrite(
    Result<void, StorageFailure> result, {
    SettingsNotice? notice,
  }) {
    switch (result) {
      case Ok():
        if (notice != null) {
          ref.read(settingsFeedbackProvider.notifier).succeed(notice);
        }
      case Err(:final failure):
        logFailure('mamiro.settings', failure);
        ref.read(settingsFeedbackProvider.notifier).fail(failure);
    }
  }
}

final settingsNotifierProvider =
    NotifierProvider<SettingsNotifier, AsyncValue<SettingsState>>(
      SettingsNotifier.new,
    );
