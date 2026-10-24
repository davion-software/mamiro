# Mamiro

A calm pill cabinet and alarm clock from Davion Software. Never miss a dose.

Private rhythm keeper for iOS and Android. No accounts. No backend. Data stays on the device.

## What it does

Tell Mamiro what you take, when, and on which days. Today shows the next doses up top, grouped by time, with the rest of the day below. At dose time a full-screen alarm holds until you Take, Snooze, or Skip, and doses due together can be taken at once. Doses stay due for two hours past the scheduled time, then show as missed so you can still Take or Skip. Any Take or Skip can be undone.

The app follows the device language (English or Spanish) and its 12/24-hour setting.

Alarms ring even when Mamiro is closed. The next week of doses (up to 48 alarms) is handed to the OS scheduler and re-synced whenever the cabinet, the log, or settings change, and each time the app opens. Take, Snooze, and Skip work straight from the alarm without opening the app.

- **Android** — an exact `setAlarmClock` alarm that shows full screen over the lock screen and repeats its alarm-volume tone until handled or the dose turns missed. Exact timing and full-screen alarms can be granted under Settings → Alarm access; without exact timing alarms may arrive a few minutes late. Alarms survive reboots.
- **iOS** — a time-sensitive notification with the default sound. iOS does not allow third-party apps to ring continuously or take over the lock screen.

While the app is open, the in-app alarm takes over and silences the OS alarm.

## Tabs

- **Today** — due now, next, later, and done (with undo), a taken/total ring, and a refill strip with Restock
- **Meds** — the cabinet: add, edit, delete
- **History** — adherence and day-by-day marks for the last 7 days (tap a day for its doses), clean-day streak, and a log grouped by day. Days before a medication was added are not counted
- **Settings** — alarm access, sound, vibration, banners, snooze length, test alarms (in app or with the app closed), and an Advanced section to restore the demo cabinet or clear data

## Requirements

- [Flutter](https://docs.flutter.dev/get-started/install) 3.47.1 (Dart 3.13.1)
- Android Studio / Android SDK for Android
- macOS, Xcode, and CocoaPods for iOS

```bash
flutter doctor
```

## Run

```bash
git clone git@github.com:davion-software/mamiro.git
cd mamiro
flutter pub get
dart run build_runner build
flutter run
```

First launch seeds a demo cabinet (Vitamin D3, Omega-3, Lisinopril,
Magnesium). Existing `SharedPreferences` snapshots are migrated once to the
Drift database and removed only after a successful transaction.

## Checks

```bash
dart run build_runner build
dart format --output=none --set-exit-if-changed lib test
flutter analyze --fatal-infos --fatal-warnings
flutter test --test-randomize-ordering-seed random
flutter build apk --release
```

## Layout

```text
lib/main.dart                 Thin entrypoint
lib/bootstrap.dart            Composition root and provider overrides
lib/app.dart                  MaterialApp.router and lifecycle handling
lib/core/                     Pure values, typed results, scheduling rules
lib/data/                     Drift schema, repository, migration boundary
lib/services/                 Injectable clock, ID, and OS alarm providers
lib/routing/                  Single GoRouter and typed route locations
lib/l10n/                     ARB strings (en, es), generated localizations, formats
lib/theme/                    Theme tokens and reusable visual components
lib/features/*/presentation/  Consumer views and Riverpod Notifiers
test/                         Tests mirroring the production structure
.cursor/skills/               Project-local engineering skills
android/ ios/                 Native hosts
```

Internal Davion Software project. Do not distribute the code without authorization.
