import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mamiro/core/result.dart';
import 'package:mamiro/core/theme_choice.dart';
import 'package:mamiro/data/providers.dart';

/// The theme saved in settings; the default while loading or if storage
/// is unavailable, so the app never flashes an unstyled frame.
final themeChoiceProvider = Provider<ThemeChoice>((ref) {
  final settings = ref.watch(settingsProvider).value;
  return switch (settings) {
    Ok(:final value) => value.theme,
    _ => ThemeChoice.fallback,
  };
});
