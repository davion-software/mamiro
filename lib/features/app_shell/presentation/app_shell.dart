import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mamiro/l10n/l10n.dart';
import 'package:mamiro/routing/routes.dart';
import 'package:mamiro/theme/palette.dart';
import 'package:mamiro/theme/widgets/coral_surface.dart';

final class AppShell extends StatelessWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final index = navigationShell.currentIndex;
    final l10n = context.l10n;
    return Scaffold(
      extendBody: true,
      body: SafeArea(bottom: false, child: navigationShell),
      floatingActionButton: index == 1
          ? Padding(
              padding: const EdgeInsets.only(bottom: 76),
              child: FloatingActionButton.extended(
                onPressed: () => context.push(Routes.newMedication),
                icon: const Icon(Icons.add),
                label: Text(l10n.addShort),
              ),
            )
          : null,
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Center(
            heightFactor: 1,
            // Narrow phones shrink the bar instead of overflowing.
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: _PillNavBar(
                index: index,
                onSelect: (destination) => navigationShell.goBranch(
                  destination,
                  initialLocation: destination == index,
                ),
                items: [
                  (Icons.wb_sunny_outlined, Icons.wb_sunny, l10n.navToday),
                  (Icons.medication_outlined, Icons.medication, l10n.navMeds),
                  (Icons.insights_outlined, Icons.insights, l10n.navHistory),
                  (Icons.tune_outlined, Icons.tune, l10n.navSettings),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Floating pill navigation: round icon buttons, the active one in coral
/// with its label.
final class _PillNavBar extends StatelessWidget {
  const _PillNavBar({
    required this.index,
    required this.onSelect,
    required this.items,
  });

  final int index;
  final ValueChanged<int> onSelect;
  final List<(IconData, IconData, String)> items;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: MamiroPalette.surface,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: MamiroPalette.cobalt.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final (i, (icon, selectedIcon, label)) in items.indexed)
              Padding(
                padding: EdgeInsets.only(left: i == 0 ? 0 : 6),
                child: _NavItem(
                  icon: i == index ? selectedIcon : icon,
                  label: label,
                  selected: i == index,
                  onTap: () => onSelect(i),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

final class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      label: label,
      excludeSemantics: true,
      child: Tooltip(
        message: label,
        child: DecoratedBox(
          decoration: selected
              ? coralSurface()
              : BoxDecoration(
                  color: MamiroPalette.surfaceMuted,
                  borderRadius: BorderRadius.circular(999),
                ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(999),
              child: AnimatedSize(
                duration: const Duration(milliseconds: 180),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: selected ? 16 : 13,
                    vertical: 13,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        icon,
                        size: 22,
                        color: selected
                            ? MamiroPalette.surface
                            : MamiroPalette.ink,
                      ),
                      if (selected) ...[
                        const SizedBox(width: 8),
                        Text(
                          label,
                          style: const TextStyle(
                            fontFamily: MamiroPalette.fontFamily,
                            fontWeight: FontWeight.w700,
                            color: MamiroPalette.surface,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
