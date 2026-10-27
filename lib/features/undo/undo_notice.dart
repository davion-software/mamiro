import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';
import 'package:mamiro/core/app_log.dart';
import 'package:mamiro/core/dose_event.dart';
import 'package:mamiro/core/dose_slot.dart';
import 'package:mamiro/core/result.dart';
import 'package:mamiro/data/providers.dart';
import 'package:mamiro/services/app_providers.dart';

/// Doses just taken or skipped, offered for a moment to be undone.
@immutable
final class RecordedDoses {
  const RecordedDoses({
    required this.slots,
    required this.action,
    this.adjustedTakenAt,
  });

  final List<DoseSlot> slots;
  final DoseAction action;
  final DateTime? adjustedTakenAt;
}

/// The latest successful Take or Skip from Today or the in-app alarm.
/// The app shows it as a snack bar with an Undo action.
final class UndoNoticeNotifier extends Notifier<RecordedDoses?> {
  @override
  RecordedDoses? build() => null;

  void recorded(
    List<DoseSlot> slots,
    DoseAction action, {
    DateTime? adjustedTakenAt,
  }) {
    if (slots.isEmpty) return;
    state = RecordedDoses(
      slots: List.unmodifiable(slots),
      action: action,
      adjustedTakenAt: adjustedTakenAt,
    );
  }

  /// Reverts exactly [doses]. A dose no longer taken or skipped is left
  /// alone, and undoing a Take puts the pill back.
  void undo(RecordedDoses doses) {
    unawaited(
      _undo(doses).catchError(unexpectedLogger('mamiro.undo', 'undo.intent')),
    );
  }

  Future<void> _undo(RecordedDoses doses) async {
    final repository = ref.read(mamiroRepositoryProvider);
    for (final slot in doses.slots) {
      final result = await repository.undoSlot(
        medicationId: slot.medication.id,
        scheduledAt: slot.scheduledAt,
        now: ref.read(clockProvider).now(),
      );
      if (result case Err(:final failure)) logFailure('mamiro.undo', failure);
    }
  }
}

final undoNoticeProvider = NotifierProvider<UndoNoticeNotifier, RecordedDoses?>(
  UndoNoticeNotifier.new,
);
