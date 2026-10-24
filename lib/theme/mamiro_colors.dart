import 'package:flutter/material.dart';
import 'package:mamiro/core/theme_choice.dart';

/// Color roles for the active theme. Widgets read roles, never raw colors,
/// so every theme stays consistent and every pair is contrast-tested.
///
/// Each solid role has an `on` color for text on it; each container (pale
/// tint) has a matching text color. Meanings are fixed across themes:
/// primary acts, accent marks "now", success is taken, warning is refill,
/// danger is missed, skipped, delete, and errors.
@immutable
final class MamiroColors extends ThemeExtension<MamiroColors> {
  const MamiroColors({
    required this.bgTop,
    required this.bgMid,
    required this.bgBottom,
    required this.aura,
    required this.surface,
    required this.muted,
    required this.line,
    required this.outline,
    required this.ink,
    required this.inkSoft,
    required this.primary,
    required this.onPrimary,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.accent,
    required this.onAccent,
    required this.accentContainer,
    required this.onAccentContainer,
    required this.success,
    required this.onSuccess,
    required this.successContainer,
    required this.warning,
    required this.warningContainer,
    required this.danger,
    required this.onDanger,
    required this.dangerContainer,
  });

  /// Screen gradient, top to bottom, and the soft aura in the top corner.
  final Color bgTop;
  final Color bgMid;
  final Color bgBottom;
  final Color aura;

  /// Cards, quiet fills, dividers, and control borders (3:1).
  final Color surface;
  final Color muted;
  final Color line;
  final Color outline;

  final Color ink;
  final Color inkSoft;

  final Color primary;
  final Color onPrimary;
  final Color primaryContainer;
  final Color onPrimaryContainer;

  final Color accent;
  final Color onAccent;
  final Color accentContainer;
  final Color onAccentContainer;

  /// Text and marks; solid fills carry [onSuccess] or [onDanger].
  final Color success;
  final Color onSuccess;
  final Color successContainer;
  final Color warning;
  final Color warningContainer;
  final Color danger;
  final Color onDanger;
  final Color dangerContainer;

  static const _white = Color(0xFFFFFFFF);
  static const _success = Color(0xFF1D7350);
  static const _successContainer = Color(0xFFDCF1E7);
  static const _warning = Color(0xFF8A5300);
  static const _warningContainer = Color(0xFFFFEDC7);
  static const _danger = Color(0xFFB42346);
  static const _dangerContainer = Color(0xFFFCE4EA);

  /// Night blue and apricot: calm, with the highest contrast. Default.
  static const nightApricot = MamiroColors(
    bgTop: Color(0xFFF5F6FA),
    bgMid: Color(0xFFEEF1F8),
    bgBottom: Color(0xFFD3DEF0),
    aura: Color(0xFFFCEBDD),
    surface: _white,
    muted: Color(0xFFF1F3F8),
    line: Color(0xFFE5E9F1),
    outline: Color(0xFF7E879A),
    ink: Color(0xFF141A2B),
    inkSoft: Color(0xFF4E5568),
    primary: Color(0xFF1F3A68),
    onPrimary: _white,
    primaryContainer: Color(0xFFDCE3F1),
    onPrimaryContainer: Color(0xFF1A3159),
    accent: Color(0xFFF5B26B),
    onAccent: Color(0xFF1F2A44),
    accentContainer: Color(0xFFFFEBD3),
    onAccentContainer: Color(0xFF7A4310),
    success: _success,
    onSuccess: _white,
    successContainer: _successContainer,
    warning: _warning,
    warningContainer: _warningContainer,
    danger: _danger,
    onDanger: _white,
    dangerContainer: _dangerContainer,
  );

  /// Cobalt and peach: the original look with ordered roles.
  static const cobaltPeach = MamiroColors(
    bgTop: Color(0xFFF4F5F9),
    bgMid: Color(0xFFEEF3FA),
    bgBottom: Color(0xFFC9E1F4),
    aura: Color(0xFFF8E3EA),
    surface: _white,
    muted: Color(0xFFF1F4F9),
    line: Color(0xFFE6EBF2),
    outline: Color(0xFF848D9D),
    ink: Color(0xFF1A1C22),
    inkSoft: Color(0xFF535866),
    primary: Color(0xFF2C55B8),
    onPrimary: _white,
    primaryContainer: Color(0xFFDDE6F8),
    onPrimaryContainer: Color(0xFF1C3A86),
    accent: Color(0xFFB9502A),
    onAccent: _white,
    accentContainer: Color(0xFFFFE2D5),
    onAccentContainer: Color(0xFF7E2F12),
    success: _success,
    onSuccess: _white,
    successContainer: _successContainer,
    warning: _warning,
    warningContainer: _warningContainer,
    danger: _danger,
    onDanger: _white,
    dangerContainer: _dangerContainer,
  );

  /// Teal and coral: complementary, a warm take on pharmacy colors.
  static const tealCoral = MamiroColors(
    bgTop: Color(0xFFF3F7F7),
    bgMid: Color(0xFFEDF5F5),
    bgBottom: Color(0xFFC8E6E4),
    aura: Color(0xFFFBE4DC),
    surface: _white,
    muted: Color(0xFFEFF5F5),
    line: Color(0xFFE2ECEC),
    outline: Color(0xFF7F8C8C),
    ink: Color(0xFF14201F),
    inkSoft: Color(0xFF4C5A59),
    primary: Color(0xFF0E6A6C),
    onPrimary: _white,
    primaryContainer: Color(0xFFD3EDEC),
    onPrimaryContainer: Color(0xFF0A4A4C),
    accent: Color(0xFFBF4F2E),
    onAccent: _white,
    accentContainer: Color(0xFFFFE1D6),
    onAccentContainer: Color(0xFF7D2D14),
    // A leafier green than usual so it stays apart from the teal.
    success: Color(0xFF2B6A1F),
    onSuccess: _white,
    successContainer: Color(0xFFE3F2DA),
    warning: _warning,
    warningContainer: _warningContainer,
    danger: _danger,
    onDanger: _white,
    dangerContainer: _dangerContainer,
  );

  /// Plum and peach: the warmest, close to the reference's pink haze.
  static const plumPeach = MamiroColors(
    bgTop: Color(0xFFFBF6F8),
    bgMid: Color(0xFFF7EEF2),
    bgBottom: Color(0xFFEED9E4),
    aura: Color(0xFFFFE6D9),
    surface: _white,
    muted: Color(0xFFF7F1F4),
    line: Color(0xFFEFE5EA),
    outline: Color(0xFF8C8290),
    ink: Color(0xFF221722),
    inkSoft: Color(0xFF5A4F5C),
    primary: Color(0xFF6E2B66),
    onPrimary: _white,
    primaryContainer: Color(0xFFF3DDEF),
    onPrimaryContainer: Color(0xFF561F50),
    accent: Color(0xFFB9502A),
    onAccent: _white,
    accentContainer: Color(0xFFFFE2D5),
    onAccentContainer: Color(0xFF7E2F12),
    success: _success,
    onSuccess: _white,
    successContainer: _successContainer,
    warning: _warning,
    warningContainer: _warningContainer,
    danger: _danger,
    onDanger: _white,
    dangerContainer: _dangerContainer,
  );

  static MamiroColors of(ThemeChoice choice) => switch (choice) {
    ThemeChoice.nightApricot => nightApricot,
    ThemeChoice.cobaltPeach => cobaltPeach,
    ThemeChoice.tealCoral => tealCoral,
    ThemeChoice.plumPeach => plumPeach,
  };

  @override
  MamiroColors copyWith() => this;

  @override
  MamiroColors lerp(MamiroColors? other, double t) {
    if (other == null) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t) ?? b;
    return MamiroColors(
      bgTop: mix(bgTop, other.bgTop),
      bgMid: mix(bgMid, other.bgMid),
      bgBottom: mix(bgBottom, other.bgBottom),
      aura: mix(aura, other.aura),
      surface: mix(surface, other.surface),
      muted: mix(muted, other.muted),
      line: mix(line, other.line),
      outline: mix(outline, other.outline),
      ink: mix(ink, other.ink),
      inkSoft: mix(inkSoft, other.inkSoft),
      primary: mix(primary, other.primary),
      onPrimary: mix(onPrimary, other.onPrimary),
      primaryContainer: mix(primaryContainer, other.primaryContainer),
      onPrimaryContainer: mix(onPrimaryContainer, other.onPrimaryContainer),
      accent: mix(accent, other.accent),
      onAccent: mix(onAccent, other.onAccent),
      accentContainer: mix(accentContainer, other.accentContainer),
      onAccentContainer: mix(onAccentContainer, other.onAccentContainer),
      success: mix(success, other.success),
      onSuccess: mix(onSuccess, other.onSuccess),
      successContainer: mix(successContainer, other.successContainer),
      warning: mix(warning, other.warning),
      warningContainer: mix(warningContainer, other.warningContainer),
      danger: mix(danger, other.danger),
      onDanger: mix(onDanger, other.onDanger),
      dangerContainer: mix(dangerContainer, other.dangerContainer),
    );
  }
}

extension MamiroColorsContext on BuildContext {
  /// The active theme's color roles.
  MamiroColors get colors =>
      Theme.of(this).extension<MamiroColors>() ?? MamiroColors.nightApricot;
}
