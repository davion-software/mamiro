import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:mamiro/core/medication.dart';
import 'package:mamiro/core/storage_failure.dart';
import 'package:mamiro/core/theme_choice.dart';
import 'package:mamiro/l10n/app_localizations.dart';

export 'package:mamiro/l10n/app_localizations.dart';

extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);

  /// Locale-aware dates and times that honor the system 24-hour setting.
  Formats get formats => Formats(
    AppLocalizations.of(this),
    use24h: MediaQuery.alwaysUse24HourFormatOf(this),
  );
}

/// Localizations for code that runs without a widget tree, such as OS alarm
/// scheduling in a background isolate.
AppLocalizations platformLocalizations() {
  final locale = basicLocaleListResolution(
    PlatformDispatcher.instance.locales,
    AppLocalizations.supportedLocales,
  );
  return lookupAppLocalizations(locale);
}

final class Formats {
  const Formats(this.l10n, {required this.use24h});

  final AppLocalizations l10n;

  /// When false, the locale decides (Spanish already uses 24 hours).
  final bool use24h;

  String get _locale => l10n.localeName;

  String clock(DateTime time) {
    final format = use24h ? DateFormat.Hm(_locale) : DateFormat.jm(_locale);
    return format.format(time);
  }

  String minutes(int minutes) {
    final wrapped = ((minutes % (24 * 60)) + (24 * 60)) % (24 * 60);
    return clock(DateTime(2000, 1, 1, wrapped ~/ 60, wrapped % 60));
  }

  String times(List<int> timesMinutes) {
    final sorted = [...timesMinutes]..sort();
    return sorted.map(minutes).join(' · ');
  }

  /// "Wednesday, August 26" / "Miércoles, 26 de agosto".
  String longDate(DateTime day) =>
      _capitalize(DateFormat.MMMMEEEEd(_locale).format(day));

  /// "Mon, Aug 24" / "Lun, 24 ago".
  String shortDate(DateTime day) =>
      _capitalize(DateFormat.MMMEd(_locale).format(day));

  String weekdayShort(int weekday) =>
      _capitalize(DateFormat.E(_locale).format(_dayFor(weekday)));

  String weekdayNarrow(int weekday) =>
      DateFormat.EEEEE(_locale).format(_dayFor(weekday)).toUpperCase();

  String days(List<int> daysOfWeek) {
    if (daysOfWeek.isEmpty || daysOfWeek.length == 7) return l10n.everyDay;
    final sorted = [...daysOfWeek]..sort();
    return sorted.map(weekdayShort).join(', ');
  }

  /// "Today", "Yesterday", or a short date.
  String relativeDay(DateTime day, DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(day.year, day.month, day.day);
    final difference = today.difference(target).inDays;
    if (difference == 0) return l10n.today;
    if (difference == 1) return l10n.yesterday;
    return shortDate(day);
  }

  String greeting(DateTime now) {
    if (now.hour < 12) return l10n.greetingMorning;
    // Spanish afternoons ("tardes") run until dinner.
    final eveningStarts = _locale.startsWith('es') ? 20 : 17;
    if (now.hour < eveningStarts) return l10n.greetingAfternoon;
    return l10n.greetingEvening;
  }

  String storageFailure(StorageFailure failure) {
    return switch (failure) {
      StorageUnavailable() => l10n.storageUnavailable,
      StorageCorrupt() => l10n.storageCorrupt,
      StorageConstraintViolation() => l10n.storageConstraint,
      StorageNotFound() => l10n.storageNotFound,
    };
  }

  String shape(PillShape shape) => switch (shape) {
    PillShape.capsule => l10n.shapeCapsule,
    PillShape.tablet => l10n.shapeTablet,
    PillShape.softgel => l10n.shapeSoftgel,
  };

  String color(PillColor color) => switch (color) {
    PillColor.sage => l10n.colorSage,
    PillColor.moss => l10n.colorMoss,
    PillColor.terracotta => l10n.colorTerracotta,
    PillColor.clay => l10n.colorClay,
    PillColor.sand => l10n.colorSand,
    PillColor.slate => l10n.colorSlate,
    PillColor.ink => l10n.colorInk,
    PillColor.blush => l10n.colorBlush,
  };

  String theme(ThemeChoice choice) => switch (choice) {
    ThemeChoice.nightApricot => l10n.themeNightApricot,
    ThemeChoice.cobaltPeach => l10n.themeCobaltPeach,
    ThemeChoice.tealCoral => l10n.themeTealCoral,
    ThemeChoice.plumPeach => l10n.themePlumPeach,
  };

  // 2024-01-01 was a Monday, so weekday 1..7 maps onto that week.
  static DateTime _dayFor(int weekday) => DateTime(2024, 1, weekday);

  static String _capitalize(String value) =>
      value.isEmpty ? value : '${value[0].toUpperCase()}${value.substring(1)}';
}
