import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mamiro/theme/mamiro_colors.dart';
import 'package:mamiro/core/app_log.dart';
import 'package:mamiro/features/today/presentation/early_take.dart';
import 'package:mamiro/features/today/presentation/today_notifier.dart';
import 'package:mamiro/features/today/presentation/widgets/alarm_access_banner.dart';
import 'package:mamiro/features/today/presentation/widgets/banner_strip.dart';
import 'package:mamiro/features/today/presentation/widgets/done_list.dart';
import 'package:mamiro/features/today/presentation/widgets/dose_section.dart';
import 'package:mamiro/features/today/presentation/widgets/late_take_dialog.dart';
import 'package:mamiro/features/today/presentation/widgets/refill_card.dart';
import 'package:mamiro/features/today/presentation/widgets/taken_ring.dart';
import 'package:mamiro/l10n/l10n.dart';
import 'package:mamiro/routing/routes.dart';
import 'package:mamiro/theme/widgets/async_page.dart';
import 'package:mamiro/theme/widgets/coral_chip.dart';
import 'package:mamiro/theme/widgets/empty_state.dart';
import 'package:mamiro/theme/widgets/paper_card.dart';
import 'package:mamiro/theme/widgets/storage_banner.dart';

final class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(todayNotifierProvider, (previous, next) {
      final failure = next.value?.actionFailure;
      if (failure == null || failure == previous?.value?.actionFailure) return;
      showStorageFailureSnackBar(context, failure);
    });
    return AsyncPage(
      value: ref.watch(todayNotifierProvider),
      errorMessage: context.l10n.todayUnavailable,
      builder: (state) => _TodayContent(
        state: state,
        notifier: ref.read(todayNotifierProvider.notifier),
      ),
    );
  }
}

final class _TodayContent extends StatelessWidget {
  const _TodayContent({required this.state, required this.notifier});

  final TodayState state;
  final TodayNotifier notifier;

  void _take(BuildContext context, List<String> slotIds) {
    final slots = [
      for (final slot in state.allSlots)
        if (slotIds.contains(slot.id)) slot,
    ];
    unawaited(
      confirmEarlyTake(context, slots: slots, now: state.now)
          .then((confirmed) async {
            if (!confirmed || !context.mounted) return;
            final answer = await askTakenAt(
              context,
              slots: slots,
              now: state.now,
            );
            if (answer == null || !context.mounted) return;
            if (slotIds.length == 1) {
              notifier.take(slotIds.single, takenAt: answer.at);
            } else {
              notifier.takeAll(slotIds, takenAt: answer.at);
            }
          })
          .catchError(unexpectedLogger('mamiro.today', 'today.take')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final next = state.next;
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsetsDirectional.fromSTEB(24, 16, 24, 120),
          sliver: SliverMainAxisGroup(
            slivers: [
              SliverList.list(
                children: [
                  _TodayHeader(state: state),
                  if (state.hasMedications) const AlarmAccessBanner(),
                  if (state.failure case final failure?) ...[
                    const SizedBox(height: 16),
                    StorageBanner(failure: failure),
                  ],
                  if (state.showBanner && state.waitingCount > 0) ...[
                    const SizedBox(height: 16),
                    BannerStrip(text: l10n.todayWaiting(state.waitingCount)),
                  ],
                  if (!state.hasMedications && state.failure == null) ...[
                    const SizedBox(height: 40),
                    EmptyState(
                      icon: Icons.medication_outlined,
                      title: l10n.emptyCabinetTitle,
                      body: l10n.emptyCabinetBody,
                      actionLabel: l10n.addMedication,
                      onAction: () => context.push(Routes.newMedication),
                    ),
                  ] else if (state.allSlots.isEmpty) ...[
                    const SizedBox(height: 40),
                    Text(
                      l10n.nothingToday,
                      style: Theme.of(context).textTheme.bodyLarge
                          ?.copyWith(color: context.colors.inkSoft),
                    ),
                  ],
                ],
              ),
              if (state.due.isNotEmpty)
                DoseSection(
                  label: l10n.sectionDueNow,
                  groups: state.due,
                  onTake: (id) => _take(context, [id]),
                  onTakeAll: (ids) => _take(context, ids),
                  onSkip: notifier.skip,
                ),
              if (next != null)
                DoseSection(
                  label: l10n.sectionNext,
                  groups: [next],
                  timeInLabel: true,
                  onTake: (id) => _take(context, [id]),
                  onTakeAll: (ids) => _take(context, ids),
                  onSkip: notifier.skip,
                ),
              if (state.later.isNotEmpty)
                DoseSection(
                  label: l10n.sectionLater,
                  groups: state.later,
                  prominent: false,
                  onTake: (id) => _take(context, [id]),
                  onTakeAll: (ids) => _take(context, ids),
                  onSkip: notifier.skip,
                ),
              SliverList.list(
                children: [
                  if (state.done.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    SectionLabel(l10n.sectionDone),
                    DoneList(slots: state.done, onUndo: notifier.undo),
                  ],
                  if (state.refillSoon.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    SectionLabel(l10n.sectionRefill),
                    for (final medication in state.refillSoon)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: RefillCard(
                          key: ValueKey(medication.id),
                          medication: medication,
                          onRestock: (count) =>
                              notifier.restock(medication.id, count),
                        ),
                      ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

final class _TodayHeader extends StatelessWidget {
  const _TodayHeader({required this.state});

  final TodayState state;

  @override
  Widget build(BuildContext context) {
    final formats = context.formats;
    final summary = _summary(context);
    final total = state.allSlots.length;
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(child: CoralChip(label: formats.longDate(state.now))),
            const SizedBox(width: 12),
            if (total > 0)
              TakenRing(taken: state.takenCount, total: total, size: 60),
          ],
        ),
        const SizedBox(height: 14),
        Text(formats.greeting(state.now), style: textTheme.headlineLarge),
        if (summary != null) ...[
          const SizedBox(height: 6),
          Text(
            summary,
            style: textTheme.titleMedium?.copyWith(
              color: context.colors.ink,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }

  String? _summary(BuildContext context) {
    final l10n = context.l10n;
    final next = state.next;
    if (next != null) {
      final time = context.formats.clock(next.time);
      return next.slots.length == 1
          ? l10n.todayNextOne(next.slots.single.medication.name, time)
          : l10n.todayNextMany(next.slots.length, time);
    }
    if (state.due.isEmpty && state.allSlots.isNotEmpty) {
      return l10n.todayAllDone;
    }
    return null;
  }
}
