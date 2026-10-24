import 'package:flutter/material.dart';
import 'package:mamiro/theme/palette.dart';

/// Flat coral for buttons and chips that carry white text (5:1).
BoxDecoration coralSurface({BoxShape shape = BoxShape.rectangle}) {
  return BoxDecoration(
    shape: shape,
    borderRadius: shape == BoxShape.circle ? null : BorderRadius.circular(999),
    color: MamiroPalette.coralButtonTop,
  );
}
