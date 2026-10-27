import 'package:flutter/material.dart';
import 'package:mamiro/theme/mamiro_colors.dart';

/// The solid accent for chips and buttons that mark "now". Text and icons
/// on it use [MamiroColors.onAccent].
BoxDecoration accentSurface(
  MamiroColors colors, {
  BoxShape shape = BoxShape.rectangle,
}) {
  return BoxDecoration(
    shape: shape,
    borderRadius: shape == BoxShape.circle ? null : BorderRadius.circular(999),
    color: colors.accent,
  );
}
