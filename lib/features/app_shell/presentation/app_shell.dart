import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mamiro/routing/routes.dart';
import 'package:mamiro/theme/palette.dart';

final class AppShell extends StatelessWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final index = navigationShell.currentIndex;
    return Scaffold(
      backgroundColor: MamiroPalette.paper,
      body: SafeArea(child: navigationShell),
      floatingActionButton: index == 1
          ? FloatingActionButton.extended(
              onPressed: () => context.push(Routes.newMedication),
              backgroundColor: MamiroPalette.sage,
              foregroundColor: MamiroPalette.paper,
              icon: const Icon(Icons.add),
              label: const Text('Add'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (destination) {
          navigationShell.goBranch(
            destination,
            initialLocation: destination == navigationShell.currentIndex,
          );
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.wb_sunny_outlined),
            selectedIcon: Icon(Icons.wb_sunny),
            label: 'Today',
          ),
          NavigationDestination(
            icon: Icon(Icons.grid_view_outlined),
            selectedIcon: Icon(Icons.grid_view),
            label: 'Meds',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_graph_outlined),
            selectedIcon: Icon(Icons.auto_graph),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.tune_outlined),
            selectedIcon: Icon(Icons.tune),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
