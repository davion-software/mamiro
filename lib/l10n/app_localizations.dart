import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Mamiro'**
  String get appTitle;

  /// No description provided for @navToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get navToday;

  /// No description provided for @navMeds.
  ///
  /// In en, this message translates to:
  /// **'Meds'**
  String get navMeds;

  /// No description provided for @navHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get navHistory;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @storageUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Storage is temporarily unavailable.'**
  String get storageUnavailable;

  /// No description provided for @storageCorrupt.
  ///
  /// In en, this message translates to:
  /// **'Saved data could not be read.'**
  String get storageCorrupt;

  /// No description provided for @storageConstraint.
  ///
  /// In en, this message translates to:
  /// **'That change could not be saved.'**
  String get storageConstraint;

  /// No description provided for @storageNotFound.
  ///
  /// In en, this message translates to:
  /// **'That item is no longer available.'**
  String get storageNotFound;

  /// No description provided for @todayUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Today is temporarily unavailable.'**
  String get todayUnavailable;

  /// No description provided for @cabinetUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The cabinet is temporarily unavailable.'**
  String get cabinetUnavailable;

  /// No description provided for @historyUnavailable.
  ///
  /// In en, this message translates to:
  /// **'History is temporarily unavailable.'**
  String get historyUnavailable;

  /// No description provided for @settingsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Settings are temporarily unavailable.'**
  String get settingsUnavailable;

  /// No description provided for @greetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get greetingMorning;

  /// No description provided for @greetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get greetingAfternoon;

  /// No description provided for @greetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get greetingEvening;

  /// No description provided for @todayNextOne.
  ///
  /// In en, this message translates to:
  /// **'Next: {name} at {time}'**
  String todayNextOne(String name, String time);

  /// No description provided for @todayNextMany.
  ///
  /// In en, this message translates to:
  /// **'Next: {count} doses at {time}'**
  String todayNextMany(int count, String time);

  /// No description provided for @todayAllDone.
  ///
  /// In en, this message translates to:
  /// **'All done for today'**
  String get todayAllDone;

  /// No description provided for @todayWaiting.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 dose is waiting} other{{count} doses are waiting}}'**
  String todayWaiting(int count);

  /// No description provided for @sectionDueNow.
  ///
  /// In en, this message translates to:
  /// **'Due now'**
  String get sectionDueNow;

  /// No description provided for @sectionNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get sectionNext;

  /// No description provided for @sectionLater.
  ///
  /// In en, this message translates to:
  /// **'Later today'**
  String get sectionLater;

  /// No description provided for @sectionDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get sectionDone;

  /// No description provided for @sectionRefill.
  ///
  /// In en, this message translates to:
  /// **'Refill soon'**
  String get sectionRefill;

  /// No description provided for @takeAction.
  ///
  /// In en, this message translates to:
  /// **'Take'**
  String get takeAction;

  /// No description provided for @takeAll.
  ///
  /// In en, this message translates to:
  /// **'Take all ({count})'**
  String takeAll(int count);

  /// No description provided for @skipAction.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skipAction;

  /// No description provided for @takeEarly.
  ///
  /// In en, this message translates to:
  /// **'Take now'**
  String get takeEarly;

  /// No description provided for @moreActions.
  ///
  /// In en, this message translates to:
  /// **'More actions'**
  String get moreActions;

  /// No description provided for @statusMissed.
  ///
  /// In en, this message translates to:
  /// **'Missed'**
  String get statusMissed;

  /// No description provided for @statusSnoozedUntil.
  ///
  /// In en, this message translates to:
  /// **'Snoozed until {time}'**
  String statusSnoozedUntil(String time);

  /// No description provided for @statusTaken.
  ///
  /// In en, this message translates to:
  /// **'Taken'**
  String get statusTaken;

  /// No description provided for @statusSkipped.
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get statusSkipped;

  /// No description provided for @statusLater.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get statusLater;

  /// No description provided for @statusDue.
  ///
  /// In en, this message translates to:
  /// **'Due now'**
  String get statusDue;

  /// No description provided for @statusSnoozed.
  ///
  /// In en, this message translates to:
  /// **'Snoozed'**
  String get statusSnoozed;

  /// No description provided for @doneTakenAt.
  ///
  /// In en, this message translates to:
  /// **'Taken at {time}'**
  String doneTakenAt(String time);

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @pillsLeft.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 left} other{{count} left}}'**
  String pillsLeft(int count);

  /// No description provided for @refillSoonTag.
  ///
  /// In en, this message translates to:
  /// **'refill soon'**
  String get refillSoonTag;

  /// No description provided for @restock.
  ///
  /// In en, this message translates to:
  /// **'Restock'**
  String get restock;

  /// No description provided for @restockTitle.
  ///
  /// In en, this message translates to:
  /// **'Restock {name}'**
  String restockTitle(String name);

  /// No description provided for @restockField.
  ///
  /// In en, this message translates to:
  /// **'Pills added'**
  String get restockField;

  /// No description provided for @restockConfirm.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get restockConfirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @emptyCabinetTitle.
  ///
  /// In en, this message translates to:
  /// **'Your cabinet is empty.'**
  String get emptyCabinetTitle;

  /// No description provided for @emptyCabinetBody.
  ///
  /// In en, this message translates to:
  /// **'Add what you take and Mamiro will ring at each dose.'**
  String get emptyCabinetBody;

  /// No description provided for @addMedication.
  ///
  /// In en, this message translates to:
  /// **'Add medication'**
  String get addMedication;

  /// No description provided for @addShort.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addShort;

  /// No description provided for @nothingToday.
  ///
  /// In en, this message translates to:
  /// **'Nothing scheduled today.'**
  String get nothingToday;

  /// No description provided for @alarmDoseDue.
  ///
  /// In en, this message translates to:
  /// **'Dose due'**
  String get alarmDoseDue;

  /// No description provided for @alarmCounter.
  ///
  /// In en, this message translates to:
  /// **'{index} of {count}'**
  String alarmCounter(int index, int count);

  /// No description provided for @alarmTestLabel.
  ///
  /// In en, this message translates to:
  /// **'Test alarm'**
  String get alarmTestLabel;

  /// No description provided for @alarmOnTime.
  ///
  /// In en, this message translates to:
  /// **'Right on time'**
  String get alarmOnTime;

  /// No description provided for @alarmLateMinutes.
  ///
  /// In en, this message translates to:
  /// **'Scheduled {minutes} min ago'**
  String alarmLateMinutes(int minutes);

  /// No description provided for @alarmLateHours.
  ///
  /// In en, this message translates to:
  /// **'Scheduled {hours} h {minutes} min ago'**
  String alarmLateHours(int hours, int minutes);

  /// No description provided for @alarmAlsoDue.
  ///
  /// In en, this message translates to:
  /// **'Also due: {names}'**
  String alarmAlsoDue(String names);

  /// No description provided for @alarmSnooze.
  ///
  /// In en, this message translates to:
  /// **'Snooze {minutes} min'**
  String alarmSnooze(int minutes);

  /// No description provided for @snoozeShort.
  ///
  /// In en, this message translates to:
  /// **'Snooze'**
  String get snoozeShort;

  /// No description provided for @alarmNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Time for {name}'**
  String alarmNotificationTitle(String name);

  /// No description provided for @channelRingVibrate.
  ///
  /// In en, this message translates to:
  /// **'Dose alarms'**
  String get channelRingVibrate;

  /// No description provided for @channelRing.
  ///
  /// In en, this message translates to:
  /// **'Dose alarms (no vibration)'**
  String get channelRing;

  /// No description provided for @channelVibrate.
  ///
  /// In en, this message translates to:
  /// **'Dose alarms (silent)'**
  String get channelVibrate;

  /// No description provided for @channelQuiet.
  ///
  /// In en, this message translates to:
  /// **'Dose alarms (silent, no vibration)'**
  String get channelQuiet;

  /// No description provided for @channelDescription.
  ///
  /// In en, this message translates to:
  /// **'Rings at dose time until you take, snooze, or skip'**
  String get channelDescription;

  /// No description provided for @testNotificationBody.
  ///
  /// In en, this message translates to:
  /// **'This is how Mamiro rings at dose time.'**
  String get testNotificationBody;

  /// No description provided for @cabinetTitle.
  ///
  /// In en, this message translates to:
  /// **'Cabinet'**
  String get cabinetTitle;

  /// No description provided for @cabinetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'What you take, when, and on which days.'**
  String get cabinetSubtitle;

  /// No description provided for @everyDay.
  ///
  /// In en, this message translates to:
  /// **'Every day'**
  String get everyDay;

  /// No description provided for @editorAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add medication'**
  String get editorAddTitle;

  /// No description provided for @editorEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit medication'**
  String get editorEditTitle;

  /// No description provided for @fieldName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get fieldName;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Give it a name'**
  String get nameRequired;

  /// No description provided for @fieldDosage.
  ///
  /// In en, this message translates to:
  /// **'Dosage'**
  String get fieldDosage;

  /// No description provided for @dosageHint.
  ///
  /// In en, this message translates to:
  /// **'10 mg'**
  String get dosageHint;

  /// No description provided for @dosageRequired.
  ///
  /// In en, this message translates to:
  /// **'Add a dosage'**
  String get dosageRequired;

  /// No description provided for @fieldNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get fieldNotes;

  /// No description provided for @notesHint.
  ///
  /// In en, this message translates to:
  /// **'with breakfast'**
  String get notesHint;

  /// No description provided for @sectionTimes.
  ///
  /// In en, this message translates to:
  /// **'Times'**
  String get sectionTimes;

  /// No description provided for @addTime.
  ///
  /// In en, this message translates to:
  /// **'Add time'**
  String get addTime;

  /// No description provided for @timeHelp.
  ///
  /// In en, this message translates to:
  /// **'Tap a time to change it.'**
  String get timeHelp;

  /// No description provided for @timesRequired.
  ///
  /// In en, this message translates to:
  /// **'Add at least one time'**
  String get timesRequired;

  /// No description provided for @sectionDays.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get sectionDays;

  /// No description provided for @daysSpecific.
  ///
  /// In en, this message translates to:
  /// **'Specific days'**
  String get daysSpecific;

  /// No description provided for @daysRequired.
  ///
  /// In en, this message translates to:
  /// **'Pick at least one day'**
  String get daysRequired;

  /// No description provided for @sectionInventory.
  ///
  /// In en, this message translates to:
  /// **'Inventory'**
  String get sectionInventory;

  /// No description provided for @trackPills.
  ///
  /// In en, this message translates to:
  /// **'Track remaining pills'**
  String get trackPills;

  /// No description provided for @trackPillsHelp.
  ///
  /// In en, this message translates to:
  /// **'One pill is subtracted each time you take a dose.'**
  String get trackPillsHelp;

  /// No description provided for @pillCount.
  ///
  /// In en, this message translates to:
  /// **'Pills on hand'**
  String get pillCount;

  /// No description provided for @countRequired.
  ///
  /// In en, this message translates to:
  /// **'Add a count'**
  String get countRequired;

  /// No description provided for @thresholdField.
  ///
  /// In en, this message translates to:
  /// **'Remind me to refill at'**
  String get thresholdField;

  /// No description provided for @thresholdRequired.
  ///
  /// In en, this message translates to:
  /// **'Add a refill level'**
  String get thresholdRequired;

  /// No description provided for @wholeNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a whole number'**
  String get wholeNumber;

  /// No description provided for @thresholdWarning.
  ///
  /// In en, this message translates to:
  /// **'You\'re already at or below the refill level.'**
  String get thresholdWarning;

  /// No description provided for @sectionAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get sectionAppearance;

  /// No description provided for @shapeCapsule.
  ///
  /// In en, this message translates to:
  /// **'Capsule'**
  String get shapeCapsule;

  /// No description provided for @shapeTablet.
  ///
  /// In en, this message translates to:
  /// **'Tablet'**
  String get shapeTablet;

  /// No description provided for @shapeSoftgel.
  ///
  /// In en, this message translates to:
  /// **'Softgel'**
  String get shapeSoftgel;

  /// No description provided for @colorSage.
  ///
  /// In en, this message translates to:
  /// **'Sage'**
  String get colorSage;

  /// No description provided for @colorMoss.
  ///
  /// In en, this message translates to:
  /// **'Moss'**
  String get colorMoss;

  /// No description provided for @colorTerracotta.
  ///
  /// In en, this message translates to:
  /// **'Terracotta'**
  String get colorTerracotta;

  /// No description provided for @colorClay.
  ///
  /// In en, this message translates to:
  /// **'Clay'**
  String get colorClay;

  /// No description provided for @colorSand.
  ///
  /// In en, this message translates to:
  /// **'Sand'**
  String get colorSand;

  /// No description provided for @colorSlate.
  ///
  /// In en, this message translates to:
  /// **'Slate'**
  String get colorSlate;

  /// No description provided for @colorInk.
  ///
  /// In en, this message translates to:
  /// **'Ink'**
  String get colorInk;

  /// No description provided for @colorBlush.
  ///
  /// In en, this message translates to:
  /// **'Blush'**
  String get colorBlush;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @deleteMedication.
  ///
  /// In en, this message translates to:
  /// **'Delete medication'**
  String get deleteMedication;

  /// No description provided for @deleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove from the cabinet?'**
  String get deleteTitle;

  /// No description provided for @deleteBody.
  ///
  /// In en, this message translates to:
  /// **'{name} will leave Today and its alarms will stop. Past history is kept.'**
  String deleteBody(String name);

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get historyTitle;

  /// No description provided for @historyTaken.
  ///
  /// In en, this message translates to:
  /// **'{taken} of {total} doses taken'**
  String historyTaken(int taken, int total);

  /// No description provided for @historyNoData.
  ///
  /// In en, this message translates to:
  /// **'No doses to count yet.'**
  String get historyNoData;

  /// No description provided for @streakNone.
  ///
  /// In en, this message translates to:
  /// **'No streak yet'**
  String get streakNone;

  /// No description provided for @streakDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 clean day in a row} other{{count} clean days in a row}}'**
  String streakDays(int count);

  /// No description provided for @sectionDayByDay.
  ///
  /// In en, this message translates to:
  /// **'Day by day'**
  String get sectionDayByDay;

  /// No description provided for @legendComplete.
  ///
  /// In en, this message translates to:
  /// **'All taken'**
  String get legendComplete;

  /// No description provided for @legendMixed.
  ///
  /// In en, this message translates to:
  /// **'Missed or skipped'**
  String get legendMixed;

  /// No description provided for @legendPending.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get legendPending;

  /// No description provided for @legendEmpty.
  ///
  /// In en, this message translates to:
  /// **'No doses'**
  String get legendEmpty;

  /// No description provided for @dayHint.
  ///
  /// In en, this message translates to:
  /// **'Tap a day to see its doses.'**
  String get dayHint;

  /// No description provided for @daySheetEmpty.
  ///
  /// In en, this message translates to:
  /// **'No doses were scheduled.'**
  String get daySheetEmpty;

  /// No description provided for @sectionLog.
  ///
  /// In en, this message translates to:
  /// **'Recent log'**
  String get sectionLog;

  /// No description provided for @logEmpty.
  ///
  /// In en, this message translates to:
  /// **'Takes, skips, and snoozes will land here.'**
  String get logEmpty;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @logSkippedAt.
  ///
  /// In en, this message translates to:
  /// **'Skipped at {time}'**
  String logSkippedAt(String time);

  /// No description provided for @logSnoozedAt.
  ///
  /// In en, this message translates to:
  /// **'Snoozed at {time}'**
  String logSnoozedAt(String time);

  /// No description provided for @logScheduled.
  ///
  /// In en, this message translates to:
  /// **'scheduled {time}'**
  String logScheduled(String time);

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsIntro.
  ///
  /// In en, this message translates to:
  /// **'Alarms ring at dose time, even when Mamiro is closed.'**
  String get settingsIntro;

  /// No description provided for @sectionAccess.
  ///
  /// In en, this message translates to:
  /// **'Alarm access'**
  String get sectionAccess;

  /// No description provided for @accessNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get accessNotifications;

  /// No description provided for @accessNotificationsHelp.
  ///
  /// In en, this message translates to:
  /// **'Needed to ring while closed'**
  String get accessNotificationsHelp;

  /// No description provided for @accessExact.
  ///
  /// In en, this message translates to:
  /// **'Exact timing'**
  String get accessExact;

  /// No description provided for @accessExactHelp.
  ///
  /// In en, this message translates to:
  /// **'Ring on the minute'**
  String get accessExactHelp;

  /// No description provided for @accessFullScreen.
  ///
  /// In en, this message translates to:
  /// **'Full-screen alarms'**
  String get accessFullScreen;

  /// No description provided for @accessFullScreenHelp.
  ///
  /// In en, this message translates to:
  /// **'Show over the lock screen. Android can\'t report this, so check it in system settings.'**
  String get accessFullScreenHelp;

  /// No description provided for @allow.
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get allow;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @allowed.
  ///
  /// In en, this message translates to:
  /// **'Allowed'**
  String get allowed;

  /// No description provided for @sectionAlarm.
  ///
  /// In en, this message translates to:
  /// **'Alarm'**
  String get sectionAlarm;

  /// No description provided for @sound.
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get sound;

  /// No description provided for @soundHelp.
  ///
  /// In en, this message translates to:
  /// **'Alarm tone at dose time'**
  String get soundHelp;

  /// No description provided for @vibration.
  ///
  /// In en, this message translates to:
  /// **'Vibration'**
  String get vibration;

  /// No description provided for @vibrationHelp.
  ///
  /// In en, this message translates to:
  /// **'Vibrate with the alarm'**
  String get vibrationHelp;

  /// No description provided for @banners.
  ///
  /// In en, this message translates to:
  /// **'Due-now strip'**
  String get banners;

  /// No description provided for @bannersHelp.
  ///
  /// In en, this message translates to:
  /// **'Show waiting doses at the top of Today'**
  String get bannersHelp;

  /// No description provided for @sectionSnooze.
  ///
  /// In en, this message translates to:
  /// **'Snooze length'**
  String get sectionSnooze;

  /// No description provided for @minutesShort.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String minutesShort(int minutes);

  /// No description provided for @sectionTest.
  ///
  /// In en, this message translates to:
  /// **'Try it'**
  String get sectionTest;

  /// No description provided for @testNow.
  ///
  /// In en, this message translates to:
  /// **'Test alarm now'**
  String get testNow;

  /// No description provided for @testClosed.
  ///
  /// In en, this message translates to:
  /// **'Test with the app closed'**
  String get testClosed;

  /// No description provided for @testClosedHelp.
  ///
  /// In en, this message translates to:
  /// **'Rings in 10 seconds. Close Mamiro to check it.'**
  String get testClosedHelp;

  /// No description provided for @testScheduled.
  ///
  /// In en, this message translates to:
  /// **'Test alarm set for {time}'**
  String testScheduled(String time);

  /// No description provided for @sectionAdvanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get sectionAdvanced;

  /// No description provided for @restoreDemo.
  ///
  /// In en, this message translates to:
  /// **'Restore demo cabinet'**
  String get restoreDemo;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all data'**
  String get clearAll;

  /// No description provided for @demoRestored.
  ///
  /// In en, this message translates to:
  /// **'Demo cabinet restored'**
  String get demoRestored;

  /// No description provided for @cleared.
  ///
  /// In en, this message translates to:
  /// **'All data cleared'**
  String get cleared;

  /// No description provided for @clearTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear this device?'**
  String get clearTitle;

  /// No description provided for @clearBody.
  ///
  /// In en, this message translates to:
  /// **'This removes every medication and log from this phone. It cannot be undone.'**
  String get clearBody;

  /// No description provided for @clearConfirm.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get clearConfirm;

  /// No description provided for @notFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find that screen.'**
  String get notFoundTitle;

  /// No description provided for @notFoundBody.
  ///
  /// In en, this message translates to:
  /// **'It may have moved. Head back to Today.'**
  String get notFoundBody;

  /// No description provided for @goToday.
  ///
  /// In en, this message translates to:
  /// **'Go to Today'**
  String get goToday;

  /// No description provided for @demoVitaminD3.
  ///
  /// In en, this message translates to:
  /// **'Vitamin D3'**
  String get demoVitaminD3;

  /// No description provided for @demoMagnesium.
  ///
  /// In en, this message translates to:
  /// **'Magnesium'**
  String get demoMagnesium;

  /// No description provided for @demoWithBreakfast.
  ///
  /// In en, this message translates to:
  /// **'with breakfast'**
  String get demoWithBreakfast;

  /// No description provided for @demoSameTimes.
  ///
  /// In en, this message translates to:
  /// **'same times each day'**
  String get demoSameTimes;

  /// No description provided for @demoBeforeBed.
  ///
  /// In en, this message translates to:
  /// **'before bed'**
  String get demoBeforeBed;

  /// No description provided for @sectionTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get sectionTheme;

  /// No description provided for @themeNightApricot.
  ///
  /// In en, this message translates to:
  /// **'Night blue & apricot'**
  String get themeNightApricot;

  /// No description provided for @themeCobaltPeach.
  ///
  /// In en, this message translates to:
  /// **'Cobalt & peach'**
  String get themeCobaltPeach;

  /// No description provided for @themeTealCoral.
  ///
  /// In en, this message translates to:
  /// **'Teal & coral'**
  String get themeTealCoral;

  /// No description provided for @themePlumPeach.
  ///
  /// In en, this message translates to:
  /// **'Plum & peach'**
  String get themePlumPeach;

  /// No description provided for @themeDefault.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get themeDefault;

  /// No description provided for @undoTaken.
  ///
  /// In en, this message translates to:
  /// **'Taken: {name}'**
  String undoTaken(String name);

  /// No description provided for @undoSkipped.
  ///
  /// In en, this message translates to:
  /// **'Skipped: {name}'**
  String undoSkipped(String name);

  /// No description provided for @undoRecorded.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 dose recorded} other{{count} doses recorded}}'**
  String undoRecorded(int count);

  /// No description provided for @lateTakeTitleOne.
  ///
  /// In en, this message translates to:
  /// **'When did you take {name}?'**
  String lateTakeTitleOne(String name);

  /// No description provided for @lateTakeTitleMany.
  ///
  /// In en, this message translates to:
  /// **'When did you take these {count} doses?'**
  String lateTakeTitleMany(int count);

  /// No description provided for @lateTakeNow.
  ///
  /// In en, this message translates to:
  /// **'Now ({time})'**
  String lateTakeNow(String time);

  /// No description provided for @lateTakeOnTime.
  ///
  /// In en, this message translates to:
  /// **'On time ({time})'**
  String lateTakeOnTime(String time);

  /// No description provided for @lateTakeOther.
  ///
  /// In en, this message translates to:
  /// **'Another time…'**
  String get lateTakeOther;

  /// No description provided for @lateTakeAdjusted.
  ///
  /// In en, this message translates to:
  /// **'Set to {time}: it must be between the scheduled time and now.'**
  String lateTakeAdjusted(String time);

  /// No description provided for @accessBannerNotifications.
  ///
  /// In en, this message translates to:
  /// **'Alarms won\'t ring while the app is closed'**
  String get accessBannerNotifications;

  /// No description provided for @accessBannerExact.
  ///
  /// In en, this message translates to:
  /// **'Alarms may ring late'**
  String get accessBannerExact;

  /// No description provided for @accessBannerEnable.
  ///
  /// In en, this message translates to:
  /// **'Turn on'**
  String get accessBannerEnable;

  /// No description provided for @primerTitle.
  ///
  /// In en, this message translates to:
  /// **'So Mamiro rings on time'**
  String get primerTitle;

  /// No description provided for @primerClosedApp.
  ///
  /// In en, this message translates to:
  /// **'Alarms ring at dose time, even when the app is closed.'**
  String get primerClosedApp;

  /// No description provided for @primerActions.
  ///
  /// In en, this message translates to:
  /// **'Take, snooze, or skip right from the notification.'**
  String get primerActions;

  /// No description provided for @primerLater.
  ///
  /// In en, this message translates to:
  /// **'You can change this anytime in Settings.'**
  String get primerLater;

  /// No description provided for @primerAllow.
  ///
  /// In en, this message translates to:
  /// **'Allow alarms'**
  String get primerAllow;

  /// No description provided for @primerNotNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get primerNotNow;

  /// No description provided for @earlyTakeTitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Take {name} now?} other{Take {count} doses now?}}'**
  String earlyTakeTitle(int count, String name);

  /// No description provided for @earlyTakeBody.
  ///
  /// In en, this message translates to:
  /// **'It\'s scheduled for {time}.'**
  String earlyTakeBody(String time);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
