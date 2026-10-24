import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mamiro/theme/mamiro_colors.dart';
import 'package:mamiro/l10n/l10n.dart';
import 'package:mamiro/routing/routes.dart';

/// Shown for unknown routes. The technical cause goes to the log, never to
/// the screen.
final class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsetsDirectional.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.explore_off_outlined,
                  size: 48,
                  color: context.colors.inkSoft,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.notFoundTitle,
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.notFoundBody,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge
                      ?.copyWith(color: context.colors.inkSoft),
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: () => context.go(Routes.today),
                  child: Text(l10n.goToday),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
