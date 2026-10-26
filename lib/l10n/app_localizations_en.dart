// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Mamiro';

  @override
  String get navToday => 'Today';

  @override
  String get navMeds => 'Meds';

  @override
  String get navHistory => 'History';

  @override
  String get navSettings => 'Settings';

  @override
  String get storageUnavailable => 'Storage is temporarily unavailable.';

  @override
  String get storageCorrupt => 'Saved data could not be read.';

  @override
  String get storageConstraint => 'That change could not be saved.';

  @override
  String get storageNotFound => 'That item is no longer available.';

  @override
  String get todayUnavailable => 'Today is temporarily unavailable.';

  @override
  String get cabinetUnavailable => 'The cabinet is temporarily unavailable.';

  @override
  String get historyUnavailable => 'History is temporarily unavailable.';

  @override
  String get settingsUnavailable => 'Settings are temporarily unavailable.';

  @override
  String get greetingMorning => 'Good morning';

  @override
  String get greetingAfternoon => 'Good afternoon';

  @override
  String get greetingEvening => 'Good evening';

  @override
  String todayNextOne(String name, String time) {
    return 'Next: $name at $time';
  }

  @override
  String todayNextMany(int count, String time) {
    return 'Next: $count doses at $time';
  }

  @override
  String get todayAllDone => 'All done for today';

  @override
  String todayWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count doses are waiting',
      one: '1 dose is waiting',
    );
    return '$_temp0';
  }

  @override
  String get sectionDueNow => 'Due now';

  @override
  String get sectionNext => 'Next';

  @override
  String get sectionLater => 'Later today';

  @override
  String get sectionDone => 'Done';

  @override
  String get sectionRefill => 'Refill soon';

  @override
  String get takeAction => 'Take';

  @override
  String takeAll(int count) {
    return 'Take all ($count)';
  }

  @override
  String get skipAction => 'Skip';

  @override
  String get takeEarly => 'Take now';

  @override
  String get moreActions => 'More actions';

  @override
  String get statusMissed => 'Missed';

  @override
  String statusSnoozedUntil(String time) {
    return 'Snoozed until $time';
  }

  @override
  String get statusTaken => 'Taken';

  @override
  String get statusSkipped => 'Skipped';

  @override
  String get statusLater => 'Upcoming';

  @override
  String get statusDue => 'Due now';

  @override
  String get statusSnoozed => 'Snoozed';

  @override
  String doneTakenAt(String time) {
    return 'Taken at $time';
  }

  @override
  String get undo => 'Undo';

  @override
  String pillsLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count left',
      one: '1 left',
    );
    return '$_temp0';
  }

  @override
  String get refillSoonTag => 'refill soon';

  @override
  String get restock => 'Restock';

  @override
  String restockTitle(String name) {
    return 'Restock $name';
  }

  @override
  String get restockField => 'Pills added';

  @override
  String get restockConfirm => 'Add';

  @override
  String get cancel => 'Cancel';

  @override
  String get emptyCabinetTitle => 'Your cabinet is empty.';

  @override
  String get emptyCabinetBody =>
      'Add what you take and Mamiro will ring at each dose.';

  @override
  String get addMedication => 'Add medication';

  @override
  String get addShort => 'Add';

  @override
  String get nothingToday => 'Nothing scheduled today.';

  @override
  String get alarmDoseDue => 'Dose due';

  @override
  String alarmCounter(int index, int count) {
    return '$index of $count';
  }

  @override
  String get alarmTestLabel => 'Test alarm';

  @override
  String get alarmOnTime => 'Right on time';

  @override
  String alarmLateMinutes(int minutes) {
    return 'Scheduled $minutes min ago';
  }

  @override
  String alarmLateHours(int hours, int minutes) {
    return 'Scheduled $hours h $minutes min ago';
  }

  @override
  String alarmAlsoDue(String names) {
    return 'Also due: $names';
  }

  @override
  String alarmSnooze(int minutes) {
    return 'Snooze $minutes min';
  }

  @override
  String get snoozeShort => 'Snooze';

  @override
  String alarmNotificationTitle(String name) {
    return 'Time for $name';
  }

  @override
  String get channelRingVibrate => 'Dose alarms';

  @override
  String get channelRing => 'Dose alarms (no vibration)';

  @override
  String get channelVibrate => 'Dose alarms (silent)';

  @override
  String get channelQuiet => 'Dose alarms (silent, no vibration)';

  @override
  String get channelDescription =>
      'Rings at dose time until you take, snooze, or skip';

  @override
  String get testNotificationBody => 'This is how Mamiro rings at dose time.';

  @override
  String get cabinetTitle => 'Cabinet';

  @override
  String get cabinetSubtitle => 'What you take, when, and on which days.';

  @override
  String get everyDay => 'Every day';

  @override
  String get editorAddTitle => 'Add medication';

  @override
  String get editorEditTitle => 'Edit medication';

  @override
  String get fieldName => 'Name';

  @override
  String get nameRequired => 'Give it a name';

  @override
  String get fieldDosage => 'Dosage';

  @override
  String get dosageHint => '10 mg';

  @override
  String get dosageRequired => 'Add a dosage';

  @override
  String get fieldNotes => 'Notes';

  @override
  String get notesHint => 'with breakfast';

  @override
  String get sectionTimes => 'Times';

  @override
  String get addTime => 'Add time';

  @override
  String get timeHelp => 'Tap a time to change it.';

  @override
  String get timesRequired => 'Add at least one time';

  @override
  String get sectionDays => 'Days';

  @override
  String get daysSpecific => 'Specific days';

  @override
  String get daysRequired => 'Pick at least one day';

  @override
  String get sectionInventory => 'Inventory';

  @override
  String get trackPills => 'Track remaining pills';

  @override
  String get trackPillsHelp =>
      'One pill is subtracted each time you take a dose.';

  @override
  String get pillCount => 'Pills on hand';

  @override
  String get countRequired => 'Add a count';

  @override
  String get thresholdField => 'Remind me to refill at';

  @override
  String get thresholdRequired => 'Add a refill level';

  @override
  String get wholeNumber => 'Enter a whole number';

  @override
  String get thresholdWarning =>
      'You\'re already at or below the refill level.';

  @override
  String get sectionAppearance => 'Appearance';

  @override
  String get shapeCapsule => 'Capsule';

  @override
  String get shapeTablet => 'Tablet';

  @override
  String get shapeSoftgel => 'Softgel';

  @override
  String get colorSage => 'Sage';

  @override
  String get colorMoss => 'Moss';

  @override
  String get colorTerracotta => 'Terracotta';

  @override
  String get colorClay => 'Clay';

  @override
  String get colorSand => 'Sand';

  @override
  String get colorSlate => 'Slate';

  @override
  String get colorInk => 'Ink';

  @override
  String get colorBlush => 'Blush';

  @override
  String get save => 'Save';

  @override
  String get deleteMedication => 'Delete medication';

  @override
  String get deleteTitle => 'Remove from the cabinet?';

  @override
  String deleteBody(String name) {
    return '$name will leave Today and its alarms will stop. Past history is kept.';
  }

  @override
  String get delete => 'Delete';

  @override
  String get historyTitle => 'Last 7 days';

  @override
  String historyTaken(int taken, int total) {
    return '$taken of $total doses taken';
  }

  @override
  String get historyNoData => 'No doses to count yet.';

  @override
  String get streakNone => 'No streak yet';

  @override
  String streakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count clean days in a row',
      one: '1 clean day in a row',
    );
    return '$_temp0';
  }

  @override
  String get sectionDayByDay => 'Day by day';

  @override
  String get legendComplete => 'All taken';

  @override
  String get legendMixed => 'Missed or skipped';

  @override
  String get legendPending => 'In progress';

  @override
  String get legendEmpty => 'No doses';

  @override
  String get dayHint => 'Tap a day to see its doses.';

  @override
  String get daySheetEmpty => 'No doses were scheduled.';

  @override
  String get sectionLog => 'Recent log';

  @override
  String get logEmpty => 'Takes, skips, and snoozes will land here.';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String logSkippedAt(String time) {
    return 'Skipped at $time';
  }

  @override
  String logSnoozedAt(String time) {
    return 'Snoozed at $time';
  }

  @override
  String logScheduled(String time) {
    return 'scheduled $time';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsIntro =>
      'Alarms ring at dose time, even when Mamiro is closed.';

  @override
  String get sectionAccess => 'Alarm access';

  @override
  String get accessNotifications => 'Notifications';

  @override
  String get accessNotificationsHelp => 'Needed to ring while closed';

  @override
  String get accessExact => 'Exact timing';

  @override
  String get accessExactHelp => 'Ring on the minute';

  @override
  String get accessFullScreen => 'Full-screen alarms';

  @override
  String get accessFullScreenHelp =>
      'Show over the lock screen. Android can\'t report this, so check it in system settings.';

  @override
  String get allow => 'Allow';

  @override
  String get open => 'Open';

  @override
  String get allowed => 'Allowed';

  @override
  String get sectionAlarm => 'Alarm';

  @override
  String get sound => 'Sound';

  @override
  String get soundHelp => 'Alarm tone at dose time';

  @override
  String get vibration => 'Vibration';

  @override
  String get vibrationHelp => 'Vibrate with the alarm';

  @override
  String get banners => 'Due-now strip';

  @override
  String get bannersHelp => 'Show waiting doses at the top of Today';

  @override
  String get sectionSnooze => 'Snooze length';

  @override
  String minutesShort(int minutes) {
    return '$minutes min';
  }

  @override
  String get sectionTest => 'Try it';

  @override
  String get testNow => 'Test alarm now';

  @override
  String get testClosed => 'Test with the app closed';

  @override
  String get testClosedHelp => 'Rings in 10 seconds. Close Mamiro to check it.';

  @override
  String testScheduled(String time) {
    return 'Test alarm set for $time';
  }

  @override
  String get sectionAdvanced => 'Advanced';

  @override
  String get restoreDemo => 'Restore demo cabinet';

  @override
  String get clearAll => 'Clear all data';

  @override
  String get demoRestored => 'Demo cabinet restored';

  @override
  String get cleared => 'All data cleared';

  @override
  String get clearTitle => 'Clear this device?';

  @override
  String get clearBody =>
      'This removes every medication and log from this phone. It cannot be undone.';

  @override
  String get clearConfirm => 'Clear all';

  @override
  String get notFoundTitle => 'We couldn\'t find that screen.';

  @override
  String get notFoundBody => 'It may have moved. Head back to Today.';

  @override
  String get goToday => 'Go to Today';

  @override
  String get demoVitaminD3 => 'Vitamin D3';

  @override
  String get demoMagnesium => 'Magnesium';

  @override
  String get demoWithBreakfast => 'with breakfast';

  @override
  String get demoSameTimes => 'same times each day';

  @override
  String get demoBeforeBed => 'before bed';

  @override
  String get sectionTheme => 'Theme';

  @override
  String get themeNightApricot => 'Night blue & apricot';

  @override
  String get themeCobaltPeach => 'Cobalt & peach';

  @override
  String get themeTealCoral => 'Teal & coral';

  @override
  String get themePlumPeach => 'Plum & peach';

  @override
  String get themeDefault => 'Default';

  @override
  String get primerTitle => 'So Mamiro rings on time';

  @override
  String get primerClosedApp =>
      'Alarms ring at dose time, even when the app is closed.';

  @override
  String get primerActions =>
      'Take, snooze, or skip right from the notification.';

  @override
  String get primerLater => 'You can change this anytime in Settings.';

  @override
  String get primerAllow => 'Allow alarms';

  @override
  String get primerNotNow => 'Not now';
}
