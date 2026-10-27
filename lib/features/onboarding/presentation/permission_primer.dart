import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mamiro/core/result.dart';
import 'package:mamiro/data/providers.dart';
import 'package:mamiro/l10n/l10n.dart';
import 'package:mamiro/services/alarm_gateway.dart';
import 'package:mamiro/theme/mamiro_colors.dart';
import 'package:mamiro/theme/widgets/paper_card.dart';

/// Whether to explain alarm permissions before the system asks: only when
/// notifications are not granted and the explanation was never shown.
final FutureProvider<bool> permissionPrimerNeededProvider =
    FutureProvider<bool>((ref) async {
      final access = await ref.watch(alarmGatewayProvider).access();
      if (access.notifications) return false;
      final shown = await ref
          .watch(mamiroRepositoryProvider)
          .permissionPrimerShown();
      return switch (shown) {
        Ok(:final value) => !value,
        // If storage is unreadable, stay quiet rather than risk asking twice.
        Err() => false,
      };
    });

/// Shows the explanation once. Returns true when the person chose to allow
/// alarms, false for "Not now" or dismissing the sheet.
Future<bool> showPermissionPrimer(BuildContext context) async {
  final allow = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => const PermissionPrimerSheet(),
  );
  return allow ?? false;
}

final class PermissionPrimerSheet extends StatelessWidget {
  const PermissionPrimerSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: colors.accentContainer,
                shape: BoxShape.circle,
              ),
              child: SizedBox.square(
                dimension: 80,
                child: Icon(
                  Icons.alarm,
                  size: 40,
                  color: colors.onAccentContainer,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.primerTitle,
              textAlign: TextAlign.center,
              style: textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            PaperCard(
              color: colors.muted,
              child: Column(
                children: [
                  _Point(
                    icon: Icons.notifications_active_outlined,
                    text: l10n.primerClosedApp,
                  ),
                  const SizedBox(height: 12),
                  _Point(
                    icon: Icons.touch_app_outlined,
                    text: l10n.primerActions,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.primerLater,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(l10n.primerAllow),
              ),
            ),
            const SizedBox(height: 4),
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.primerNotNow),
            ),
          ],
        ),
      ),
    );
  }
}

final class _Point extends StatelessWidget {
  const _Point({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 22, color: context.colors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text, style: Theme.of(context).textTheme.bodyLarge),
        ),
      ],
    );
  }
}
