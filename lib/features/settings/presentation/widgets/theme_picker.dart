import 'package:flutter/material.dart';
import 'package:mamiro/core/theme_choice.dart';
import 'package:mamiro/l10n/l10n.dart';
import 'package:mamiro/theme/mamiro_colors.dart';
import 'package:mamiro/theme/widgets/paper_card.dart';

/// One row per theme, each previewed with its own background, primary, and
/// accent, so people can compare before choosing.
final class ThemePicker extends StatelessWidget {
  const ThemePicker({
    required this.selected,
    required this.onChanged,
    super.key,
  });

  final ThemeChoice selected;
  final ValueChanged<ThemeChoice> onChanged;

  @override
  Widget build(BuildContext context) {
    return PaperCard(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        children: [
          for (final (index, choice) in ThemeChoice.values.indexed) ...[
            if (index > 0)
              Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: context.colors.line,
              ),
            _ThemeOption(
              key: ValueKey(choice),
              choice: choice,
              selected: choice == selected,
              onTap: () => onChanged(choice),
            ),
          ],
        ],
      ),
    );
  }
}

final class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.choice,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final ThemeChoice choice;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    return Semantics(
      inMutuallyExclusiveGroup: true,
      selected: selected,
      button: true,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              _Preview(palette: MamiroColors.of(choice)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.formats.theme(choice),
                      style: textTheme.titleMedium,
                    ),
                    if (choice == ThemeChoice.fallback)
                      Text(l10n.themeDefault, style: textTheme.bodySmall),
                  ],
                ),
              ),
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: selected ? colors.primary : colors.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The theme in miniature: its sky, with a primary and an accent dot.
final class _Preview extends StatelessWidget {
  const _Preview({required this.palette});

  final MamiroColors palette;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.colors.line),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [palette.bgTop, palette.bgBottom],
        ),
      ),
      child: SizedBox(
        width: 56,
        height: 40,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _Dot(color: palette.primary),
            const SizedBox(width: 6),
            _Dot(color: palette.accent),
          ],
        ),
      ),
    );
  }
}

final class _Dot extends StatelessWidget {
  const _Dot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: const SizedBox.square(dimension: 16),
    );
  }
}
