import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:mamiro/theme/palette.dart';

double contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

/// Every color text or a control can sit on.
const Map<String, Color> backgrounds = {
  'skyTop': MamiroPalette.skyTop,
  'skyMid': MamiroPalette.skyMid,
  'skyBottom': MamiroPalette.skyBottom,
  'blushAura': MamiroPalette.blushAura,
  'surface': MamiroPalette.surface,
  'surfaceMuted': MamiroPalette.surfaceMuted,
};

void main() {
  // WCAG 2.2 AA: 4.5:1 for text, 3:1 for control boundaries and graphics.
  group('text reads on every background', () {
    for (final (name, color) in [
      ('ink', MamiroPalette.ink),
      ('inkSoft', MamiroPalette.inkSoft),
      ('cobalt', MamiroPalette.cobalt),
      ('coralDeep', MamiroPalette.coralDeep),
    ]) {
      for (final background in backgrounds.entries) {
        test('$name on ${background.key}', () {
          expect(contrast(color, background.value), greaterThanOrEqualTo(4.5));
        });
      }
    }
  });

  test('text on filled colors', () {
    final pairs = {
      'white on cobalt': (MamiroPalette.surface, MamiroPalette.cobalt),
      'white on coralDeep': (MamiroPalette.surface, MamiroPalette.coralDeep),
      'ink on coral': (MamiroPalette.ink, MamiroPalette.coral),
      'cobalt on cobaltMist': (MamiroPalette.cobalt, MamiroPalette.cobaltMist),
      'inkSoft on cobaltMist': (
        MamiroPalette.inkSoft,
        MamiroPalette.cobaltMist,
      ),
      'coralDeep on coralMist': (
        MamiroPalette.coralDeep,
        MamiroPalette.coralMist,
      ),
      'white on ink': (MamiroPalette.surface, MamiroPalette.ink),
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

  test('control boundaries and graphics stand out', () {
    for (final background in [MamiroPalette.surface, MamiroPalette.skyTop]) {
      expect(
        contrast(MamiroPalette.outlineStrong, background),
        greaterThanOrEqualTo(3),
      );
      expect(
        contrast(MamiroPalette.coralStrong, background),
        greaterThanOrEqualTo(3),
      );
      expect(
        contrast(MamiroPalette.cobalt, background),
        greaterThanOrEqualTo(3),
      );
    }
  });

  test('plain coral is never used for text', () {
    // Documented as fill-only: white or coral text would fail.
    expect(contrast(MamiroPalette.coral, MamiroPalette.surface), lessThan(3));
  });
}
