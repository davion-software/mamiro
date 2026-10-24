import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mamiro/features/app_shell/presentation/app_shell.dart';
import 'package:mamiro/features/history/presentation/history_screen.dart';
import 'package:mamiro/features/medications/presentation/medication_editor_screen.dart';
import 'package:mamiro/features/medications/presentation/medications_screen.dart';
import 'package:mamiro/features/settings/presentation/settings_screen.dart';
import 'package:mamiro/features/today/presentation/today_screen.dart';
import 'package:mamiro/routing/error_screen.dart';
import 'package:mamiro/routing/routes.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: Routes.today,
    errorBuilder: (context, state) {
      developer.log(
        'route not found: ${state.uri}',
        name: 'mamiro.routing',
        error: state.error,
      );
      return const ErrorScreen();
    },
    routes: [
      GoRoute(
        path: Routes.newMedication,
        builder: (context, state) => const MedicationEditorScreen(),
      ),
      GoRoute(
        path: '/medications/:id/edit',
        builder: (context, state) {
          final id = state.pathParameters['id'];
          if (id == null) return const ErrorScreen();
          return MedicationEditorScreen(medicationId: id);
        },
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.today,
                builder: (context, state) => const TodayScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.medications,
                builder: (context, state) => const MedicationsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.history,
                builder: (context, state) => const HistoryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.settings,
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
