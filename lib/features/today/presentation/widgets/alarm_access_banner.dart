import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mamiro/core/app_log.dart';
import 'package:mamiro/l10n/l10n.dart';
import 'package:mamiro/services/alarm_gateway.dart';
import 'package:mamiro/theme/mamiro_colors.dart';
import 'package:mamiro/theme/palette.dart';

/// Warns on Today when the OS will not ring alarms reliably. Missing
/// notifications outrank missing exact timing: without them nothing rings.
/// It disappears once access is granted, since resuming the app refreshes
/// [alarmAccessProvider].
final class AlarmAccessBanner extends ConsumerWidget {
  const AlarmAccessBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // While loading or on error, say nothing rather than raise a false alarm.
    final access = ref.watch(alarmAccessProvider).value;
    if (access == null) return const SizedBox.shrink();
    final l10n = context.l10n;
    final colors = context.colors;
    final gateway = ref.read(alarmGatewayProvider);
    final issue = !access.notifications
        ? (
            message: l10n.accessBannerNotifications,
            action: l10n.accessBannerEnable,
            background: colors.dangerContainer,
            foreground: colors.danger,
            icon: Icons.notifications_off_outlined,
            fix: gateway.openNotificationSettings,
          )
        : access.exactTiming == false
        ? (
            message: l10n.accessBannerExact,
            action: l10n.allow,
            background: colors.warningContainer,
            foreground: colors.warning,
            icon: Icons.schedule,
            fix: gateway.requestExactTiming,
          )
        : null;
    if (issue == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Semantics(
        liveRegion: true,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: issue.background,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 10, 8, 10),
            child: Row(
              children: [
                Icon(issue.icon, color: issue.foreground),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    issue.message,
                    style: TextStyle(
                      fontFamily: MamiroPalette.fontFamily,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      height: 1.3,
                      color: issue.foreground,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => unawaited(
                    issue.fix().catchError(
                      unexpectedLogger('mamiro.today', 'today.alarm_access'),
                    ),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: issue.foreground,
                  ),
                  child: Text(issue.action),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
