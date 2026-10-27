/// The color themes a user can pick in Settings. The first is the default.
enum ThemeChoice {
  nightApricot,
  cobaltPeach,
  tealCoral,
  plumPeach;

  static const ThemeChoice fallback = ThemeChoice.nightApricot;

  /// Unknown names (say, from a newer app version) fall back to the default
  /// instead of failing to read settings.
  static ThemeChoice byName(String name) {
    for (final value in values) {
      if (value.name == name) return value;
    }
    return fallback;
  }
}
