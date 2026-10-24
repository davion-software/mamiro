import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mamiro/core/app_log.dart';
import 'package:mamiro/features/settings/presentation/settings_notifier.dart';
import 'package:mamiro/l10n/l10n.dart';
import 'package:mamiro/services/alarm_gateway.dart';
import 'package:mamiro/theme/palette.dart';
import 'package:mamiro/theme/widgets/async_page.dart';
import 'package:mamiro/theme/widgets/paper_card.dart';
import 'package:mamiro/theme/widgets/storage_banner.dart';

final class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(settingsFeedbackProvider, (previous, next) {
      final messenger = ScaffoldMessenger.of(context);
      final l10n = context.l10n;
      final notice = next.notice;
      if (notice != null && notice != previous?.notice) {
        final testAt = next.testAt;
        messenger.showSnackBar(
          SnackBar(
            content: Text(switch (notice) {
              SettingsNotice.demoRestored => l10n.demoRestored,
              SettingsNotice.cleared => l10n.cleared,
              SettingsNotice.testScheduled => l10n.testScheduled(
                testAt == null ? '' : context.formats.clock(testAt),
              ),
            }),
          ),
        );
        ref.read(settingsFeedbackProvider.notifier).clear();
      }
      final failure = next.failure;
      if (failure != null && failure != previous?.failure) {
        messenger.showSnackBar(
          SnackBar(content: Text(context.formats.storageFailure(failure))),
        );
        ref.read(settingsFeedbackProvider.notifier).clear();
      }
    });
    return AsyncPage(
      value: ref.watch(settingsNotifierProvider),
      errorMessage: context.l10n.settingsUnavailable,
      builder: (state) => _SettingsContent(state: state),
    );
  }
}

final class _SettingsContent extends ConsumerWidget {
  const _SettingsContent({required this.state});

  final SettingsState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final settings = state.settings;
    final notifier = ref.read(settingsNotifierProvider.notifier);
    return ListView(
      padding: const EdgeInsetsDirectional.fromSTEB(24, 16, 24, 120),
      children: [
        Text(l10n.settingsTitle, style: textTheme.headlineLarge),
        const SizedBox(height: 8),
        Text(l10n.settingsIntro, style: textTheme.bodyMedium),
        if (state.failure case final failure?) ...[
          const SizedBox(height: 16),
          StorageBanner(failure: failure),
        ],
        const SizedBox(height: 20),
        SectionLabel(l10n.sectionAccess),
        const _AlarmAccessCard(),
        const SizedBox(height: 20),
        SectionLabel(l10n.sectionAlarm),
        PaperCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Column(
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.sound),
                subtitle: Text(l10n.soundHelp),
                value: settings.sound,
                onChanged: notifier.setSound,
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.vibration),
                subtitle: Text(l10n.vibrationHelp),
                value: settings.vibration,
                onChanged: notifier.setVibration,
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.banners),
                subtitle: Text(l10n.bannersHelp),
                value: settings.banners,
                onChanged: notifier.setBanners,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SectionLabel(l10n.sectionSnooze),
        PaperCard(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              for (final minutes in const [5, 10, 15])
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      // The checkmark squeezed the label in a third of a row.
                      showCheckmark: false,
                      label: SizedBox(
                        width: double.infinity,
                        child: Text(
                          l10n.minutesShort(minutes),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      selected: settings.snoozeMinutes == minutes,
                      selectedColor: MamiroPalette.cobalt,
                      labelStyle: TextStyle(
                        fontFamily: MamiroPalette.fontFamily,
                        fontWeight: FontWeight.w600,
                        color: settings.snoozeMinutes == minutes
                            ? MamiroPalette.surface
                            : MamiroPalette.ink,
                      ),
                      onSelected: (selected) {
                        if (!selected) return;
                        notifier.setSnoozeMinutes(minutes);
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SectionLabel(l10n.sectionTest),
        FilledButton(
          onPressed: notifier.startTestAlarm,
          child: Text(l10n.testNow),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: notifier.scheduleClosedAppTest,
          child: Text(l10n.testClosed),
        ),
        const SizedBox(height: 6),
        Text(
          l10n.testClosedHelp,
          textAlign: TextAlign.center,
          style: textTheme.bodyMedium,
        ),
        const SizedBox(height: 20),
        PaperCard(
          padding: EdgeInsets.zero,
          child: Theme(
            // Drop the expansion tile's own divider lines.
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              title: Text(l10n.sectionAdvanced, style: textTheme.titleMedium),
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              children: [
                OutlinedButton(
                  onPressed: notifier.restoreDemo,
                  child: Text(l10n.restoreDemo),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => _startConfirmClear(context, ref),
                  style: TextButton.styleFrom(
                    foregroundColor: MamiroPalette.coralDeep,
                  ),
                  child: Text(l10n.clearAll),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _startConfirmClear(BuildContext context, WidgetRef ref) {
    unawaited(
      _confirmClear(context, ref).catchError(
        unexpectedLogger('mamiro.settings', 'settings.confirm_clear'),
      ),
    );
  }

  Future<void> _confirmClear(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.clearTitle),
          content: Text(l10n.clearBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(
                foregroundColor: MamiroPalette.coralDeep,
              ),
              child: Text(l10n.clearConfirm),
            ),
          ],
        );
      },
    );
    if (ok != true || !context.mounted) return;
    ref.read(settingsNotifierProvider.notifier).clearAll();
  }
}

final class _AlarmAccessCard extends ConsumerWidget {
  const _AlarmAccessCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final access = ref.watch(alarmAccessProvider).value ?? AlarmAccess.unknown;
    final notifier = ref.read(settingsNotifierProvider.notifier);
    return PaperCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        children: [
          _AccessTile(
            title: l10n.accessNotifications,
            subtitle: l10n.accessNotificationsHelp,
            granted: access.notifications,
            onAllow: notifier.openNotificationSettings,
          ),
          if (access.exactTiming case final exact?)
            _AccessTile(
              title: l10n.accessExact,
              subtitle: l10n.accessExactHelp,
              granted: exact,
              onAllow: notifier.requestExactTiming,
            ),
          if (access.canRequestFullScreen)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.accessFullScreen),
              subtitle: Text(l10n.accessFullScreenHelp),
              trailing: TextButton(
                onPressed: notifier.requestFullScreen,
                child: Text(l10n.open),
              ),
            ),
        ],
      ),
    );
  }
}

final class _AccessTile extends StatelessWidget {
  const _AccessTile({
    required this.title,
    required this.subtitle,
    required this.granted,
    required this.onAllow,
  });

  final String title;
  final String subtitle;
  final bool granted;
  final VoidCallback onAllow;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: granted
          ? Icon(
              Icons.check_circle,
              color: MamiroPalette.cobalt,
              semanticLabel: context.l10n.allowed,
            )
          : TextButton(onPressed: onAllow, child: Text(context.l10n.allow)),
    );
  }
}
