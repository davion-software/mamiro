import 'package:flutter/material.dart';
import 'package:mamiro/theme/mamiro_colors.dart';
import 'package:mamiro/features/today/presentation/today_notifier.dart';
import 'package:mamiro/features/today/presentation/widgets/dose_tile.dart';
import 'package:mamiro/l10n/l10n.dart';
import 'package:mamiro/theme/widgets/paper_card.dart';

/// A labelled section of doses, one block per scheduled time.
final class DoseSection extends StatelessWidget {
  const DoseSection({
    required this.label,
    required this.groups,
    required this.onTake,
    required this.onTakeAll,
    required this.onSkip,
    this.prominent = true,
    this.timeInLabel = false,
    super.key,
  });

  final String label;
  final List<SlotGroup> groups;
  final ValueChanged<String> onTake;
  final ValueChanged<List<String>> onTakeAll;
  final ValueChanged<String> onSkip;
  final bool prominent;

  /// For a single group: put its time in the section label instead of a
  /// separate header line.
  final bool timeInLabel;

  @override
  Widget build(BuildContext context) {
    final inline = timeInLabel && groups.length == 1;
    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: SectionLabel(
              inline
                  ? '$label · ${context.formats.clock(groups.single.time)}'
                  : label,
            ),
          ),
        ),
        SliverList.builder(
          itemCount: groups.length,
          itemBuilder: (context, index) {
            final group = groups[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!inline || group.slots.length > 1)
                    _GroupHeader(
                      group: group,
                      showTime: !inline,
                      onTakeAll: prominent ? onTakeAll : null,
                    ),
                  for (final slot in group.slots)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: DoseTile(
                        key: ValueKey(slot.id),
                        slot: slot,
                        prominent: prominent,
                        onTake: onTake,
                        onSkip: onSkip,
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

final class _GroupHeader extends StatelessWidget {
  const _GroupHeader({
    required this.group,
    required this.showTime,
    required this.onTakeAll,
  });

  final SlotGroup group;
  final bool showTime;
  final ValueChanged<List<String>>? onTakeAll;

  @override
  Widget build(BuildContext context) {
    final takeAll = onTakeAll;
    final count = group.slots.length;
    return SizedBox(
      height: 36,
      child: Row(
        children: [
          Expanded(
            child: Text(
              showTime ? context.formats.clock(group.time) : '',
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(color: context.colors.primary),
            ),
          ),
          if (takeAll != null && count > 1)
            TextButton.icon(
              onPressed: () =>
                  takeAll([for (final slot in group.slots) slot.id]),
              icon: const Icon(Icons.done_all, size: 18),
              label: Text(context.l10n.takeAll(count)),
            ),
        ],
      ),
    );
  }
}
