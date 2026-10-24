import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mamiro/core/app_log.dart';
import 'package:mamiro/core/day_summary.dart';
import 'package:mamiro/core/dose_event.dart';
import 'package:mamiro/core/dose_slot.dart';
import 'package:mamiro/features/history/presentation/history_notifier.dart';
import 'package:mamiro/l10n/l10n.dart';
import 'package:mamiro/theme/palette.dart';
import 'package:mamiro/theme/widgets/async_page.dart';
import 'package:mamiro/theme/widgets/paper_card.dart';
import 'package:mamiro/theme/widgets/pill_glyph.dart';
import 'package:mamiro/theme/widgets/storage_banner.dart';

final class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AsyncPage(
      value: ref.watch(historyNotifierProvider),
      errorMessage: context.l10n.historyUnavailable,
      builder: (value) => _HistoryContent(state: value),
    );
  }
}

final class _HistoryContent extends StatelessWidget {
  const _HistoryContent({required this.state});

  final HistoryState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final formats = context.formats;
    final textTheme = Theme.of(context).textTheme;
    final adherence = state.adherence;
    final rate = adherence.rate;
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsetsDirectional.fromSTEB(24, 16, 24, 120),
          sliver: SliverList.list(
            children: [
              Text(l10n.historyTitle, style: textTheme.headlineLarge),
              const SizedBox(height: 18),
              if (state.failure case final failure?) ...[
                StorageBanner(failure: failure),
                const SizedBox(height: 16),
              ],
              PaperCard(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rate == null ? '—' : '${(rate * 100).round()}%',
                      style: textTheme.displayMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      rate == null
                          ? l10n.historyNoData
                          : l10n.historyTaken(
                              adherence.taken,
                              adherence.resolved,
                            ),
                      style: textTheme.bodyLarge?.copyWith(
                        color: MamiroPalette.inkSoft,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.streak == 0
                          ? l10n.streakNone
                          : l10n.streakDays(state.streak),
                      style: textTheme.titleMedium?.copyWith(
                        color: MamiroPalette.cobalt,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SectionLabel(l10n.sectionDayByDay),
              PaperCard(
                padding: const EdgeInsets.fromLTRB(8, 14, 8, 12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        for (final day in state.days)
                          Expanded(
                            child: _DayCell(
                              summary: day,
                              onTap: () => _showDay(context, day),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const _Legend(),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(l10n.dayHint, style: textTheme.bodyMedium),
              const SizedBox(height: 20),
              SectionLabel(l10n.sectionLog),
              if (state.log.isEmpty)
                Text(
                  l10n.logEmpty,
                  style: textTheme.bodyLarge?.copyWith(
                    color: MamiroPalette.inkSoft,
                  ),
                ),
              for (final logDay in state.log) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 6, bottom: 8),
                  child: Text(
                    formats.relativeDay(logDay.day, state.now),
                    style: textTheme.titleMedium,
                  ),
                ),
                PaperCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: Column(
                    children: [
                      for (final (index, event) in logDay.events.indexed) ...[
                        if (index > 0)
                          const Divider(height: 1, color: MamiroPalette.line),
                        _LogRow(key: ValueKey(event.id), event: event),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ],
          ),
        ),
      ],
    );
  }

  void _showDay(BuildContext context, DaySummary day) {
    unawaited(
      showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        backgroundColor: MamiroPalette.surface,
        builder: (context) => _DaySheet(summary: day, now: state.now),
      ).catchError(unexpectedLogger('mamiro.history', 'history.day')),
    );
  }
}

Color _markFill(DayMark mark) => switch (mark) {
  DayMark.complete => MamiroPalette.cobalt,
  DayMark.mixed => MamiroPalette.coralDeep,
  DayMark.pending || DayMark.empty => Colors.transparent,
};

Color _markBorder(DayMark mark) => switch (mark) {
  DayMark.complete => MamiroPalette.cobalt,
  DayMark.mixed => MamiroPalette.coralDeep,
  DayMark.pending => MamiroPalette.cobalt,
  DayMark.empty => MamiroPalette.ringTrack,
};

final class _DayCell extends StatelessWidget {
  const _DayCell({required this.summary, required this.onTap});

  final DaySummary summary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final mark = summary.mark;
    final filled = mark == DayMark.complete || mark == DayMark.mixed;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          children: [
            Text(
              context.formats.weekdayNarrow(summary.day.weekday),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 6),
            DecoratedBox(
              decoration: BoxDecoration(
                color: _markFill(mark),
                shape: BoxShape.circle,
                border: Border.all(color: _markBorder(mark), width: 1.6),
              ),
              child: SizedBox.square(
                dimension: 30,
                child: Center(
                  child: Text(
                    '${summary.day.day}',
                    style: TextStyle(
                      fontFamily: MamiroPalette.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: filled
                          ? MamiroPalette.surface
                          : mark == DayMark.empty
                          ? MamiroPalette.inkSoft
                          : MamiroPalette.ink,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 14,
      runSpacing: 6,
      children: [
        for (final (mark, label) in [
          (DayMark.complete, l10n.legendComplete),
          (DayMark.mixed, l10n.legendMixed),
          (DayMark.pending, l10n.legendPending),
          (DayMark.empty, l10n.legendEmpty),
        ])
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: _markFill(mark),
                  shape: BoxShape.circle,
                  border: Border.all(color: _markBorder(mark), width: 1.4),
                ),
                child: const SizedBox.square(dimension: 10),
              ),
              const SizedBox(width: 6),
              Text(label, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
      ],
    );
  }
}

final class _LogRow extends StatelessWidget {
  const _LogRow({required this.event, super.key});

  final DoseEvent event;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final formats = context.formats;
    final at = formats.clock(event.at);
    final action = switch (event.action) {
      DoseAction.taken => l10n.doneTakenAt(at),
      DoseAction.skipped => l10n.logSkippedAt(at),
      DoseAction.snoozed => l10n.logSnoozedAt(at),
    };
    final color = switch (event.action) {
      DoseAction.taken => MamiroPalette.cobalt,
      DoseAction.skipped => MamiroPalette.coralDeep,
      DoseAction.snoozed => MamiroPalette.inkSoft,
    };
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: const SizedBox.square(dimension: 10),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.medicationName,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  '$action · ${l10n.logScheduled(formats.clock(event.scheduledAt))}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

final class _DaySheet extends StatelessWidget {
  const _DaySheet({required this.summary, required this.now});

  final DaySummary summary;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final formats = context.formats;
    final textTheme = Theme.of(context).textTheme;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              formats.relativeDay(summary.day, now) ==
                      formats.shortDate(summary.day)
                  ? formats.longDate(summary.day)
                  : '${formats.relativeDay(summary.day, now)} · ${formats.longDate(summary.day)}',
              style: textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            if (summary.slots.isEmpty)
              Text(
                l10n.daySheetEmpty,
                style: textTheme.bodyLarge?.copyWith(
                  color: MamiroPalette.inkSoft,
                ),
              ),
            for (final slot in summary.slots)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    PillGlyph(
                      shape: slot.medication.shape,
                      color: slot.medication.color,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            slot.medication.name,
                            style: textTheme.titleMedium,
                          ),
                          Text(
                            formats.clock(slot.scheduledAt),
                            style: textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      _status(context, slot),
                      style: textTheme.titleMedium?.copyWith(
                        color: switch (slot.status) {
                          SlotStatus.taken => MamiroPalette.cobalt,
                          SlotStatus.missed ||
                          SlotStatus.skipped => MamiroPalette.coralDeep,
                          _ => MamiroPalette.inkSoft,
                        },
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _status(BuildContext context, DoseSlot slot) {
    final l10n = context.l10n;
    final resolvedAt = slot.resolvedAt;
    return switch (slot.status) {
      SlotStatus.taken when resolvedAt != null => l10n.doneTakenAt(
        context.formats.clock(resolvedAt),
      ),
      SlotStatus.taken => l10n.statusTaken,
      SlotStatus.skipped => l10n.statusSkipped,
      SlotStatus.missed => l10n.statusMissed,
      SlotStatus.later => l10n.statusLater,
      SlotStatus.due => l10n.statusDue,
      SlotStatus.snoozed => l10n.statusSnoozed,
    };
  }
}
