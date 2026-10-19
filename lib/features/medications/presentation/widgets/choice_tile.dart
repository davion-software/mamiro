import 'package:flutter/material.dart';
import 'package:mamiro/theme/palette.dart';

final class ChoiceTile extends StatelessWidget {
  const ChoiceTile({
    required this.selected,
    required this.onTap,
    required this.child,
    super.key,
  });

  final bool selected;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? MamiroPalette.sageMist : MamiroPalette.paperDeep,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: selected ? MamiroPalette.sage : MamiroPalette.line,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: child,
        ),
      ),
    );
  }
}
