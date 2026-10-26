import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mamiro/theme/mamiro_colors.dart';
import 'package:mamiro/core/app_log.dart';
import 'package:mamiro/core/dose_slot.dart';
import 'package:mamiro/features/alarm/presentation/alarm_notifier.dart';
import 'package:mamiro/l10n/l10n.dart';
import 'package:mamiro/services/alarm_gateway.dart';
import 'package:mamiro/theme/widgets/coral_chip.dart';
import 'package:mamiro/theme/widgets/coral_surface.dart';
import 'package:mamiro/theme/widgets/pill_glyph.dart';
import 'package:mamiro/theme/widgets/sky_background.dart';

final class AlarmOverlay extends ConsumerStatefulWidget {
  const AlarmOverlay({super.key});

  @override
  ConsumerState<AlarmOverlay> createState() => _AlarmOverlayState();
}

final class _AlarmOverlayState extends ConsumerState<AlarmOverlay> {
  Timer? _pulse;
  String? _activeAlarmId;
  // Subscribed once in initState and closed in dispose.
  late final ProviderSubscription<AsyncValue<AlarmState?>> _alarmSubscription;

  @override
  void initState() {
    super.initState();
    _alarmSubscription = ref.listenManual(
      alarmNotifierProvider,
      (previous, next) => _syncFeedback(next.value),
      fireImmediately: true,
    );
  }

  @override
  void dispose() {
    _alarmSubscription.close();
    _stopFeedback();
    super.dispose();
  }

  /// While this overlay rings on screen it replaces the OS alarms, including
  /// ones the OS delivers a moment after the overlay appeared. In the
  /// background the OS alarms must keep ringing.
  void _takeOverSystemAlarms() {
    if (WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed) {
      return;
    }
    unawaited(
      ref
          .read(alarmGatewayProvider)
          .dismissDelivered()
          .catchError(unexpectedLogger('mamiro.alarm', 'alarm.dismiss')),
    );
  }

  void _syncFeedback(AlarmState? alarm) {
    final alarmId = alarm?.slot.id;
    if (alarmId == _activeAlarmId) return;
    _stopFeedback();
    if (alarmId == null) return;
    _activeAlarmId = alarmId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _activeAlarmId != alarmId) return;
      _pingAndSchedule(alarmId);
    });
  }

  void _pingAndSchedule(String alarmId) {
    if (!mounted || _activeAlarmId != alarmId) return;
    final alarm = ref.read(alarmNotifierProvider).value;
    if (alarm == null || alarm.slot.id != alarmId) {
      _stopFeedback();
      return;
    }
    if (!alarm.slot.isTest) _takeOverSystemAlarms();
    if (alarm.settings.sound) {
      unawaited(
        SystemSound.play(SystemSoundType.alert)
            .catchError(unexpectedLogger('mamiro.alarm', 'alarm.feedback')),
      );
    }
    if (alarm.settings.vibration) {
      unawaited(
        HapticFeedback.heavyImpact().catchError(
          unexpectedLogger('mamiro.alarm', 'alarm.feedback'),
        ),
      );
    }
    _pulse = Timer(const Duration(seconds: 2), () => _pingAndSchedule(alarmId));
  }

  void _stopFeedback() {
    _pulse?.cancel();
    _pulse = null;
    _activeAlarmId = null;
  }

  @override
  Widget build(BuildContext context) {
    final alarm = ref.watch(alarmNotifierProvider).value;
    if (alarm == null) return const SizedBox.shrink();
    final l10n = context.l10n;
    final formats = context.formats;
    final slot = alarm.slot;
    final med = slot.medication;
    final others = [
      for (final other in alarm.dueSlots)
        if (other.id != slot.id) other,
    ];
    final count = others.length + 1;
    final notifier = ref.read(alarmNotifierProvider.notifier);
    final actionFailure = alarm.actionFailure;
    final detail = [
      if (med.dosage.isNotEmpty) med.dosage,
      if (med.notes.isNotEmpty) med.notes,
    ].join(' · ');
    final textTheme = Theme.of(context).textTheme;
    // A Scaffold of its own so snack bars, such as Undo, show above the
    // alarm and not only on the screen hidden behind it.
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SkyBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Column(
              children: [
                CoralChip(
                  icon: Icons.notifications_active_outlined,
                  label: slot.isTest
                      ? l10n.alarmTestLabel
                      : count > 1
                      ? '${l10n.alarmDoseDue} · ${l10n.alarmCounter(1, count)}'
                      : l10n.alarmDoseDue,
                ),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _PillArt(slot: slot),
                          const SizedBox(height: 24),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 330),
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(text: med.name),
                                  if (detail.isNotEmpty)
                                    TextSpan(
                                      text: '\n$detail',
                                      style: TextStyle(
                                        color: context.colors.inkSoft,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0,
                                        height: 1.6,
                                      ),
                                    ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                              style: textTheme.displayMedium?.copyWith(
                                fontSize: 38,
                              ),
                            ),
                          ),
                          if (others.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 320),
                              child: Text(
                                l10n.alarmAlsoDue(
                                  others
                                      .map((other) => other.medication.name)
                                      .join(', '),
                                ),
                                textAlign: TextAlign.center,
                                style: textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: context.colors.surface,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: context.colors.primary.withValues(alpha: 0.1),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                    child: Column(
                      children: [
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: context.colors.muted,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            child: Text(
                              _lateness(l10n, slot, alarm.now),
                              style: textTheme.labelLarge,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          formats.clock(slot.scheduledAt),
                          style: textTheme.displayMedium?.copyWith(
                            fontSize: 48,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _RoundAction(
                                icon: Icons.close,
                                label: l10n.skipAction,
                                onTap: () => notifier.skip(slot.id),
                              ),
                            ),
                            Expanded(
                              child: _RoundAction(
                                icon: Icons.check,
                                label: l10n.takeEarly,
                                primary: true,
                                onTap: () => notifier.take(slot.id),
                              ),
                            ),
                            Expanded(
                              child: _RoundAction(
                                icon: Icons.snooze,
                                label: l10n.alarmSnooze(
                                  alarm.settings.snoozeMinutes,
                                ),
                                onTap: () => notifier.snooze(slot.id),
                              ),
                            ),
                          ],
                        ),
                        if (count > 1)
                          TextButton.icon(
                            onPressed: notifier.takeAll,
                            icon: const Icon(Icons.done_all, size: 18),
                            label: Text(l10n.takeAll(count)),
                          ),
                        if (actionFailure != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              formats.storageFailure(actionFailure),
                              textAlign: TextAlign.center,
                              style: textTheme.bodyMedium?.copyWith(
                                color: context.colors.danger,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _lateness(AppLocalizations l10n, DoseSlot slot, DateTime now) {
    final late = now.difference(slot.scheduledAt).inMinutes;
    if (slot.isTest || late < 1) return l10n.alarmOnTime;
    if (late < 60) return l10n.alarmLateMinutes(late);
    return l10n.alarmLateHours(late ~/ 60, late % 60);
  }
}

/// The pill on a soft coral-to-sky tile, standing in for the reference's
/// blurred photography.
final class _PillArt extends StatelessWidget {
  const _PillArt({required this.slot});

  final DoseSlot slot;

  @override
  Widget build(BuildContext context) {
    final med = slot.medication;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(44),
        gradient: RadialGradient(
          center: const Alignment(-0.35, -0.4),
          radius: 1.1,
          // Light enough that a coral or dark pill still stands out.
          colors: [
            context.colors.surface,
            context.colors.accentContainer,
            context.colors.bgBottom,
          ],
          stops: const [0, 0.5, 1],
        ),
        border: Border.all(color: context.colors.surface, width: 4),
        boxShadow: [
          BoxShadow(
            color: context.colors.accent.withValues(alpha: 0.3),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: SizedBox.square(
        dimension: 168,
        child: Center(
          child: PillGlyph(shape: med.shape, color: med.color, size: 96),
        ),
      ),
    );
  }
}

final class _RoundAction extends StatelessWidget {
  const _RoundAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.primary = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final size = primary ? 76.0 : 56.0;
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            children: [
              SizedBox(
                height: 84,
                child: Center(
                  child: DecoratedBox(
                    decoration: primary
                        ? accentSurface(context.colors, shape: BoxShape.circle)
                        : BoxDecoration(
                            shape: BoxShape.circle,
                            color: context.colors.muted,
                          ),
                    child: SizedBox.square(
                      dimension: size,
                      child: Icon(
                        icon,
                        size: primary ? 34 : 24,
                        color: primary
                            ? context.colors.onAccent
                            : context.colors.ink,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
