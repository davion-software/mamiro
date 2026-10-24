import 'dart:math' as math;

import 'package:flutter/painting.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:mamiro/core/theme_choice.dart';
import 'package:mamiro/theme/mamiro_colors.dart';

double contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

void main() {
  // WCAG 2.2 AA: 4.5:1 for text, 3:1 for control boundaries and graphics.
  for (final choice in ThemeChoice.values) {
    final c = MamiroColors.of(choice);

    group(choice.name, () {
      final backgrounds = {
        'bgTop': c.bgTop,
        'bgMid': c.bgMid,
        'bgBottom': c.bgBottom,
        'aura': c.aura,
        'surface': c.surface,
        'muted': c.muted,
      };

      for (final (name, color) in [
        ('ink', c.ink),
        ('inkSoft', c.inkSoft),
        ('primary', c.primary),
        ('danger', c.danger),
      ]) {
        test('$name reads on every background', () {
          for (final background in backgrounds.entries) {
            expect(
              contrast(color, background.value),
              greaterThanOrEqualTo(4.5),
              reason: '$name on ${background.key}',
            );
          }
        });
      }

      test('every fill has readable text', () {
        final pairs = {
          'onPrimary on primary': (c.onPrimary, c.primary),
          'onPrimaryContainer on primaryContainer': (
            c.onPrimaryContainer,
            c.primaryContainer,
          ),
          'onAccent on accent': (c.onAccent, c.accent),
          'onAccentContainer on accentContainer': (
            c.onAccentContainer,
            c.accentContainer,
          ),
          'success on surface': (c.success, c.surface),
          'success on successContainer': (c.success, c.successContainer),
          'onSuccess on success': (c.onSuccess, c.success),
          'warning on surface': (c.warning, c.surface),
          'warning on warningContainer': (c.warning, c.warningContainer),
          'danger on dangerContainer': (c.danger, c.dangerContainer),
          'onDanger on danger': (c.onDanger, c.danger),
          'ink on muted': (c.ink, c.muted),
          'primary on primaryContainer': (c.primary, c.primaryContainer),
          'inkSoft on primaryContainer': (c.inkSoft, c.primaryContainer),
        };
        for (final MapEntry(:key, value: (foreground, background))
            in pairs.entries) {
          expect(
            contrast(foreground, background),
            greaterThanOrEqualTo(4.5),
            reason: key,
          );
        }
      });

      test('control borders stand out', () {
        for (final background in [c.surface, c.bgTop]) {
          expect(contrast(c.outline, background), greaterThanOrEqualTo(3));
        }
      });

      test('danger and accent are different hues', () {
        // "Problem" must never read as "now".
        final accent = HSVColor.fromColor(c.accent).hue;
        final danger = HSVColor.fromColor(c.danger).hue;
        final distance = (accent - danger).abs();
        expect(math.min(distance, 360 - distance), greaterThanOrEqualTo(25));
      });
    });
  }

  test('the default theme is night blue and apricot', () {
    expect(ThemeChoice.fallback, ThemeChoice.nightApricot);
    expect(MamiroColors.of(ThemeChoice.fallback), MamiroColors.nightApricot);
  });
}
