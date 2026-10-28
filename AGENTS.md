# AGENTS.md — Mamiro

## Purpose
A calm pill cabinet and alarm clock for iOS and Android (Davion Software). No accounts, no backend: all data stays on the device. See `README.md` for product behavior (Today, Meds, History, Settings; full-screen alarms; 2-hour due window; undo).

## Stack
- Flutter 3.47.1 / Dart 3.13.1
- State: Riverpod 3 (Notifiers) · Routing: go_router (single router, typed locations)
- Persistence: Drift + sqlite3 (legacy SharedPreferences snapshot migrated once)
- Alarms: flutter_local_notifications + timezone (next week, max 48 OS alarms, re-synced on change/app open)
- i18n: ARB (en, es) via `flutter gen-l10n`; follows device 12/24h
- Lints: very_good_analysis + riverpod_lint

## Structure
```text
lib/main.dart, bootstrap.dart, app.dart   entry, composition root, MaterialApp.router
lib/core/        pure domain values, typed Result, scheduling/adherence rules (no Flutter imports)
lib/data/        Drift schema, repository, migration boundary
lib/services/    injectable clock, ID generator, OS alarm providers
lib/routing/     GoRouter
lib/l10n/        ARB strings and formats
lib/theme/       tokens and reusable components
lib/features/*/presentation/   views + Riverpod Notifiers
test/            mirrors lib/
.cursor/skills/  project engineering skills — read the relevant one before changing an area
```

## Conventions
- Keep `core/` pure and deterministic; inject time and IDs (`clock`, id providers) — never call `DateTime.now()` directly.
- Errors as typed results (`core/result.dart`), not thrown exceptions across layers.
- All user-facing strings go in ARB files (en + es).
- Drift changes need a schema migration and regenerated code (`*.g.dart`).
- Tests mirror production paths; add/update tests with every behavior change.
- Branches + PRs; never commit secrets.

## Commands
```bash
flutter pub get
dart run build_runner build
dart format --output=none --set-exit-if-changed lib test
flutter analyze --fatal-infos --fatal-warnings
flutter test --test-randomize-ordering-seed random
flutter build apk --release
```
