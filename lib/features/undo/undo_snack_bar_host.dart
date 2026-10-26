import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mamiro/core/dose_event.dart';
import 'package:mamiro/features/undo/undo_notice.dart';
import 'package:mamiro/l10n/l10n.dart';

/// Shows each successful Take or Skip as a snack bar with Undo.
///
/// It sits in MaterialApp's builder, below the app's ScaffoldMessenger, so
/// the snack bar reaches every Scaffold: the current screen and the alarm.
final class UndoSnackBarHost extends ConsumerWidget {
  const UndoSnackBarHost({super.key});

  static const duration = Duration(seconds: 5);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(undoNoticeProvider, (previous, next) {
      if (next == null || identical(next, previous)) return;
      final l10n = context.l10n;
      final slots = next.slots;
      final message = slots.length > 1
          ? l10n.undoRecorded(slots.length)
          : switch (next.action) {
              DoseAction.skipped => l10n.undoSkipped(
                slots.single.medication.name,
              ),
              DoseAction.taken || DoseAction.snoozed => l10n.undoTaken(
                slots.single.medication.name,
              ),
            };
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(message),
            duration: duration,
            persist: false,
            action: SnackBarAction(
              label: l10n.undo,
              onPressed: () => ref.read(undoNoticeProvider.notifier).undo(next),
            ),
          ),
        );
    });
    return const SizedBox.shrink();
  }
}
