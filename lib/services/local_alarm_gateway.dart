import 'dart:async';
import 'dart:typed_data';

import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:mamiro/core/alarm_plan.dart';
import 'package:mamiro/core/app_log.dart';
import 'package:mamiro/core/app_settings.dart';
import 'package:mamiro/core/dose_event.dart';
import 'package:mamiro/core/dose_slot.dart';
import 'package:mamiro/core/medication.dart';
import 'package:mamiro/l10n/l10n.dart';
import 'package:mamiro/services/alarm_gateway.dart';

typedef AlarmResponseHandler = void Function(AlarmResponse response);

const _takeAction = 'take';
const _snoozeAction = 'snooze';
const _skipAction = 'skip';
const _iosCategory = 'dose_alarm';
const _payloadSeparator = '|';
final int _testNotificationId = alarmNotificationId(testAlarmSlotKey);

// Notification.FLAG_INSISTENT: repeat the sound until the alarm is handled.
const _flagInsistent = 4;
final _vibrationPattern = Int64List.fromList([0, 900, 500, 900, 500, 900]);
const _alarmTone = UriAndroidNotificationSound(
  'content://settings/system/alarm_alert',
);

/// Schedules dose alarms with the OS so they ring while Mamiro is closed.
///
/// Android gets an insistent full-screen alarm notification scheduled with
/// `setAlarmClock` when exact alarms are allowed. iOS gets a time-sensitive
/// notification. Both carry Take, Snooze, and Skip actions.
final class LocalAlarmGateway implements AlarmGateway {
  LocalAlarmGateway._(this._plugin, this._l10n)
    : _formats = Formats(
        _l10n,
        use24h: PlatformDispatcher.instance.alwaysUse24HourFormat,
      );

  final FlutterLocalNotificationsPlugin _plugin;
  final AppLocalizations _l10n;
  final Formats _formats;
  Future<void> _pending = Future.value();

  static Future<LocalAlarmGateway> create({
    required AlarmResponseHandler onResponse,
    required DidReceiveBackgroundNotificationResponseCallback
    onBackgroundResponse,
  }) async {
    final plugin = FlutterLocalNotificationsPlugin();
    final l10n = platformLocalizations();
    // Background isolates have no localization delegates to load these.
    await initializeDateFormatting(l10n.localeName);
    try {
      await plugin.initialize(
        settings: _initializationSettings(l10n),
        onDidReceiveNotificationResponse: (response) {
          final decoded = decodeAlarmResponse(response);
          if (decoded != null) onResponse(decoded);
        },
        onDidReceiveBackgroundNotificationResponse: onBackgroundResponse,
      );
    } on PlatformException catch (error, stack) {
      logUnexpected('mamiro.alarms', 'alarms.initialize', error, stack);
    }
    return LocalAlarmGateway._(plugin, l10n);
  }

  AndroidFlutterLocalNotificationsPlugin? get _android => _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  IOSFlutterLocalNotificationsPlugin? get _ios => _plugin
      .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin
      >();

  @override
  Future<void> apply(AlarmPlan plan, AppSettings settings) {
    // Serialize so overlapping syncs cannot interleave cancels and schedules.
    final next = _pending.then(
      (_) => _guard('alarms.apply', () => _apply(plan, settings)),
    );
    // An unexpected failure must not wedge every later sync behind it.
    _pending = next.catchError(
      unexpectedLogger('mamiro.alarms', 'alarms.chain'),
    );
    return next;
  }

  Future<void> _apply(AlarmPlan plan, AppSettings settings) async {
    final upcomingIds = {
      for (final alarm in plan.upcoming) alarmNotificationId(alarm.slotKey),
    };
    final ringingIds = {
      for (final slotKey in plan.ringingSlotKeys) alarmNotificationId(slotKey),
    };
    final cancelled = <int>{};
    for (final active in await _plugin.getActiveNotifications()) {
      final id = active.id;
      if (id == null || id == _testNotificationId) continue;
      if (ringingIds.contains(id)) continue;
      await _plugin.cancel(id: id);
      cancelled.add(id);
    }
    final pendingPayloads = <int, String?>{};
    for (final pending in await _plugin.pendingNotificationRequests()) {
      if (pending.id == _testNotificationId) continue;
      if (upcomingIds.contains(pending.id)) {
        pendingPayloads[pending.id] = pending.payload;
      } else {
        await _plugin.cancel(id: pending.id);
      }
    }
    if (plan.upcoming.isEmpty) return;
    final mode = await _scheduleMode();
    for (final alarm in plan.upcoming) {
      final id = alarmNotificationId(alarm.slotKey);
      final payload = _payloadFor(alarm, settings, mode, _l10n.localeName);
      if (!cancelled.contains(id) && pendingPayloads[id] == payload) continue;
      final medication = alarm.slot.medication;
      await _plugin.zonedSchedule(
        id: id,
        title: _l10n.alarmNotificationTitle(medication.name),
        body: [
          if (medication.dosage.isNotEmpty) medication.dosage,
          _formats.clock(alarm.slot.scheduledAt),
          if (medication.notes.isNotEmpty) medication.notes,
        ].join(' · '),
        payload: payload,
        // An absolute instant: DST and day boundaries were resolved locally.
        scheduledDate: tz.TZDateTime.from(alarm.fireAt, tz.UTC),
        notificationDetails: _details(alarm, settings),
        androidScheduleMode: mode,
      );
    }
  }

  @override
  Future<void> scheduleTest(DateTime at, AppSettings settings) {
    return _guard('alarms.test', () async {
      final alarm = PlannedAlarm(
        slot: DoseSlot(
          medication: const Medication.sample(),
          scheduledAt: at,
          status: SlotStatus.later,
          isTest: true,
        ),
        fireAt: at,
      );
      await _plugin.zonedSchedule(
        id: _testNotificationId,
        title: _l10n.alarmTestLabel,
        body: _l10n.testNotificationBody,
        payload: testAlarmSlotKey,
        scheduledDate: tz.TZDateTime.from(at, tz.UTC),
        notificationDetails: _details(alarm, settings),
        androidScheduleMode: await _scheduleMode(),
      );
    });
  }

  Future<AndroidScheduleMode> _scheduleMode() async {
    final android = _android;
    if (android == null) return AndroidScheduleMode.alarmClock;
    final exact = await android.canScheduleExactNotifications() ?? false;
    return exact
        ? AndroidScheduleMode.alarmClock
        : AndroidScheduleMode.inexactAllowWhileIdle;
  }

  @override
  Future<void> dismissDelivered() {
    return _guard('alarms.dismiss', () async {
      for (final active in await _plugin.getActiveNotifications()) {
        final id = active.id;
        if (id != null) await _plugin.cancel(id: id);
      }
    });
  }

  @override
  Future<AlarmAccess> access() async {
    var access = AlarmAccess.unknown;
    await _guard('alarms.access', () async {
      final android = _android;
      final ios = _ios;
      if (android != null) {
        access = AlarmAccess(
          notifications: await android.areNotificationsEnabled() ?? false,
          exactTiming: await android.canScheduleExactNotifications() ?? false,
          canRequestFullScreen: true,
        );
      } else if (ios != null) {
        final options = await ios.checkPermissions();
        access = AlarmAccess(notifications: options?.isEnabled ?? false);
      }
    });
    return access;
  }

  @override
  Future<void> requestNotifications() {
    return _guard('alarms.request_notifications', () async {
      await _android?.requestNotificationsPermission();
      await _ios?.requestPermissions(alert: true, sound: true);
    });
  }

  @override
  Future<void> openNotificationSettings() {
    return _guard('alarms.open_settings', () async {
      await _plugin.openAppNotificationSettings();
    });
  }

  @override
  Future<void> requestExactTiming() {
    return _guard('alarms.request_exact', () async {
      await _android?.requestExactAlarmsPermission();
    });
  }

  @override
  Future<void> requestFullScreen() {
    return _guard('alarms.request_full_screen', () async {
      await _android?.requestFullScreenIntentPermission();
    });
  }

  NotificationDetails _details(PlannedAlarm alarm, AppSettings settings) {
    final channel = _channelFor(settings, _l10n);
    return NotificationDetails(
      android: AndroidNotificationDetails(
        channel.id,
        channel.name,
        channelDescription: _l10n.channelDescription,
        icon: 'ic_stat_mamiro',
        importance: Importance.max,
        priority: Priority.max,
        category: AndroidNotificationCategory.alarm,
        visibility: NotificationVisibility.public,
        fullScreenIntent: true,
        autoCancel: false,
        audioAttributesUsage: AudioAttributesUsage.alarm,
        playSound: settings.sound,
        sound: settings.sound ? _alarmTone : null,
        enableVibration: settings.vibration,
        vibrationPattern: settings.vibration ? _vibrationPattern : null,
        additionalFlags: settings.sound
            ? Int32List.fromList(const [_flagInsistent])
            : null,
        when: alarm.slot.scheduledAt.millisecondsSinceEpoch,
        timeoutAfter: alarm.silenceAt.difference(alarm.fireAt).inMilliseconds,
        actions: [
          AndroidNotificationAction(_takeAction, _l10n.takeAction),
          AndroidNotificationAction(
            _snoozeAction,
            _l10n.alarmSnooze(settings.snoozeMinutes),
          ),
          AndroidNotificationAction(_skipAction, _l10n.skipAction),
        ],
      ),
      iOS: DarwinNotificationDetails(
        categoryIdentifier: _iosCategory,
        threadIdentifier: 'dose_alarms',
        interruptionLevel: InterruptionLevel.timeSensitive,
        // The plugin only attaches the default sound when this is set.
        presentSound: settings.sound,
      ),
    );
  }

  Future<void> _guard(String operation, Future<void> Function() body) async {
    try {
      await body();
    } on PlatformException catch (error, stack) {
      logUnexpected('mamiro.alarms', operation, error, stack);
    }
  }
}

AlarmResponse? decodeAlarmResponse(NotificationResponse response) {
  final payload = response.payload;
  if (payload == null || payload.isEmpty) return null;
  return AlarmResponse(
    slotKey: payload.split(_payloadSeparator).first,
    action: switch (response.actionId) {
      _takeAction => DoseAction.taken,
      _snoozeAction => DoseAction.snoozed,
      _skipAction => DoseAction.skipped,
      _ => null,
    },
  );
}

/// The slot key followed by everything that shapes the scheduled alarm, so
/// an unchanged pending alarm is left alone and a changed one is replaced.
String _payloadFor(
  PlannedAlarm alarm,
  AppSettings settings,
  AndroidScheduleMode mode,
  String localeName,
) {
  final medication = alarm.slot.medication;
  return [
    alarm.slotKey,
    localeName,
    alarm.fireAt.millisecondsSinceEpoch,
    _channelFor(settings).id,
    settings.snoozeMinutes,
    mode.name,
    medication.name,
    medication.dosage,
    medication.notes,
  ].join(_payloadSeparator);
}

typedef _Channel = ({String id, String name});

// Android fixes sound and vibration per channel when it is first created,
// so each combination of the two settings gets its own channel.
_Channel _channelFor(AppSettings settings, [AppLocalizations? l10n]) {
  return switch ((settings.sound, settings.vibration)) {
    (true, true) => (
      id: 'dose_alarm_ring_vibrate',
      name: l10n?.channelRingVibrate ?? '',
    ),
    (true, false) => (id: 'dose_alarm_ring', name: l10n?.channelRing ?? ''),
    (false, true) => (
      id: 'dose_alarm_vibrate',
      name: l10n?.channelVibrate ?? '',
    ),
    (false, false) => (id: 'dose_alarm_quiet', name: l10n?.channelQuiet ?? ''),
  };
}

InitializationSettings _initializationSettings(AppLocalizations l10n) {
  return InitializationSettings(
    android: const AndroidInitializationSettings('ic_stat_mamiro'),
    iOS: DarwinInitializationSettings(
      // Permission is requested explicitly once the first frame is up.
      requestAlertPermission: false,
      requestSoundPermission: false,
      requestBadgePermission: false,
      // In the foreground the in-app alarm rings instead.
      defaultPresentAlert: false,
      defaultPresentSound: false,
      defaultPresentBadge: false,
      defaultPresentBanner: false,
      defaultPresentList: false,
      notificationCategories: [
        DarwinNotificationCategory(
          _iosCategory,
          actions: [
            DarwinNotificationAction.plain(_takeAction, l10n.takeAction),
            DarwinNotificationAction.plain(_snoozeAction, l10n.snoozeShort),
            DarwinNotificationAction.plain(
              _skipAction,
              l10n.skipAction,
              options: {DarwinNotificationActionOption.destructive},
            ),
          ],
        ),
      ],
    ),
  );
}
