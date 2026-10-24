import 'package:flutter/material.dart';
import 'package:mamiro/theme/mamiro_colors.dart';

/// A centered first-run message with one clear next step.
final class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.icon,
    required this.title,
    required this.body,
    required this.actionLabel,
    required this.onAction,
    super.key,
  });

  final IconData icon;
  final String title;
  final String body;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: context.colors.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: SizedBox.square(
            dimension: 88,
            child: Icon(icon, size: 40, color: context.colors.primary),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          title,
          style: textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          body,
          textAlign: TextAlign.center,
          style: textTheme.bodyLarge?.copyWith(color: context.colors.inkSoft),
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: onAction,
          icon: const Icon(Icons.add),
          label: Text(actionLabel),
        ),
      ],
    );
  }
}
