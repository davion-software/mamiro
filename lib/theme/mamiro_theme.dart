import 'package:flutter/material.dart';
import 'package:mamiro/theme/mamiro_colors.dart';
import 'package:mamiro/theme/palette.dart';

/// Tabular figures keep times like 8:00 and 20:00 aligned.
const tabularFigures = [FontFeature.tabularFigures()];

ThemeData mamiroTheme([MamiroColors c = MamiroColors.nightApricot]) {
  final ink = c.ink;
  final inkSoft = c.inkSoft;
  final surface = c.surface;
  final cobalt = c.primary;
  const font = MamiroPalette.fontFamily;
  final textTheme = TextTheme(
    displayLarge: TextStyle(
      fontFamily: font,
      fontWeight: FontWeight.w800,
      fontSize: 56,
      height: 1.05,
      letterSpacing: -1,
      color: cobalt,
      fontFeatures: tabularFigures,
    ),
    displayMedium: TextStyle(
      fontFamily: font,
      fontWeight: FontWeight.w800,
      fontSize: 40,
      height: 1.1,
      letterSpacing: -0.8,
      color: cobalt,
      fontFeatures: tabularFigures,
    ),
    headlineLarge: TextStyle(
      fontFamily: font,
      fontWeight: FontWeight.w800,
      fontSize: 30,
      height: 1.15,
      letterSpacing: -0.5,
      color: cobalt,
    ),
    headlineMedium: TextStyle(
      fontFamily: font,
      fontWeight: FontWeight.w700,
      fontSize: 24,
      height: 1.2,
      letterSpacing: -0.3,
      color: cobalt,
    ),
    titleLarge: TextStyle(
      fontFamily: font,
      fontWeight: FontWeight.w700,
      fontSize: 20,
      height: 1.25,
      color: ink,
    ),
    titleMedium: TextStyle(
      fontFamily: font,
      fontWeight: FontWeight.w700,
      fontSize: 16,
      height: 1.3,
      color: ink,
      fontFeatures: tabularFigures,
    ),
    bodyLarge: TextStyle(
      fontFamily: font,
      fontWeight: FontWeight.w400,
      fontSize: 16,
      height: 1.45,
      color: ink,
    ),
    bodyMedium: TextStyle(
      fontFamily: font,
      fontWeight: FontWeight.w400,
      fontSize: 14,
      height: 1.45,
      color: inkSoft,
      fontFeatures: tabularFigures,
    ),
    bodySmall: TextStyle(
      fontFamily: font,
      fontWeight: FontWeight.w500,
      fontSize: 12,
      height: 1.35,
      color: inkSoft,
    ),
    labelLarge: TextStyle(
      fontFamily: font,
      fontWeight: FontWeight.w700,
      fontSize: 14,
      color: ink,
    ),
    labelSmall: TextStyle(
      fontFamily: font,
      fontWeight: FontWeight.w700,
      fontSize: 12,
      letterSpacing: 0.6,
      color: inkSoft,
      fontFeatures: tabularFigures,
    ),
  );

  final scheme = ColorScheme.light(
    primary: cobalt,
    onPrimary: c.onPrimary,
    primaryContainer: c.primaryContainer,
    onPrimaryContainer: cobalt,
    secondary: c.accent,
    onSecondary: c.onAccent,
    surface: surface,
    onSurface: ink,
    onSurfaceVariant: inkSoft,
    surfaceContainerHighest: c.muted,
    error: c.danger,
    onError: c.onDanger,
    outline: c.outline,
    outlineVariant: c.line,
  );

  final pill = RoundedRectangleBorder(borderRadius: BorderRadius.circular(999));
  const buttonText = TextStyle(
    fontFamily: font,
    fontWeight: FontWeight.w700,
    fontSize: 16,
  );

  return ThemeData(
    useMaterial3: true,
    extensions: [c],
    colorScheme: scheme,
    // Screens sit on the sky gradient painted behind the whole app.
    scaffoldBackgroundColor: Colors.transparent,
    canvasColor: surface,
    textTheme: textTheme,
    fontFamily: font,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: font,
        fontWeight: FontWeight.w800,
        fontSize: 22,
        color: cobalt,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: c.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: cobalt, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: c.danger),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: c.danger, width: 1.6),
      ),
      labelStyle: TextStyle(fontFamily: font, color: inkSoft),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return surface;
        return inkSoft;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return cobalt;
        return c.muted;
      }),
      trackOutlineColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return cobalt;
        return c.outline;
      }),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: cobalt,
        foregroundColor: surface,
        textStyle: buttonText,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: pill,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        backgroundColor: surface,
        foregroundColor: cobalt,
        side: BorderSide(color: c.outline),
        textStyle: buttonText,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: pill,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: cobalt,
        textStyle: const TextStyle(
          fontFamily: font,
          fontWeight: FontWeight.w700,
        ),
        shape: pill,
      ),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return cobalt;
          return surface;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return surface;
          return ink;
        }),
        side: WidgetStatePropertyAll(BorderSide(color: c.outline)),
        textStyle: const WidgetStatePropertyAll(
          TextStyle(fontFamily: font, fontWeight: FontWeight.w700),
        ),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: surface,
      selectedColor: cobalt,
      side: BorderSide(color: c.outline),
      shape: pill,
      labelStyle: TextStyle(
        fontFamily: font,
        fontWeight: FontWeight.w700,
        color: ink,
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: cobalt,
      foregroundColor: surface,
      shape: pill,
      extendedTextStyle: buttonText,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: surface,
      titleTextStyle: TextStyle(
        fontFamily: font,
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: cobalt,
      ),
      contentTextStyle: TextStyle(
        fontFamily: font,
        fontSize: 15,
        color: inkSoft,
        height: 1.4,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      textStyle: TextStyle(fontFamily: font, color: ink),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: ink,
      contentTextStyle: TextStyle(fontFamily: font, color: surface),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),
    timePickerTheme: TimePickerThemeData(
      backgroundColor: surface,
      dialHandColor: cobalt,
      hourMinuteTextColor: ink,
      dayPeriodColor: c.primaryContainer,
    ),
  );
}
