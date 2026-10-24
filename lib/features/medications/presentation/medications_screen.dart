import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mamiro/theme/mamiro_colors.dart';
import 'package:mamiro/core/medication.dart';
import 'package:mamiro/features/medications/presentation/medications_notifier.dart';
import 'package:mamiro/l10n/l10n.dart';
import 'package:mamiro/routing/routes.dart';
import 'package:mamiro/theme/widgets/async_page.dart';
import 'package:mamiro/theme/widgets/empty_state.dart';
import 'package:mamiro/theme/widgets/paper_card.dart';
import 'package:mamiro/theme/widgets/pill_glyph.dart';
import 'package:mamiro/theme/widgets/storage_banner.dart';

final class MedicationsScreen extends ConsumerWidget {
  const MedicationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AsyncPage(
      value: ref.watch(medicationsNotifierProvider),
      errorMessage: context.l10n.cabinetUnavailable,
      builder: (value) => _MedicationList(state: value),
    );
  }
}

final class _MedicationList extends StatelessWidget {
  const _MedicationList({required this.state});

  final MedicationsState state;

  @override
  Widget build(BuildContext context) {
    final items = state.items;
    final failure = state.failure;
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsetsDirectional.fromSTEB(24, 16, 24, 180),
          sliver: SliverMainAxisGroup(
            slivers: [
              SliverList.list(
                children: [
                  Text(
                    context.l10n.cabinetTitle,
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    context.l10n.cabinetSubtitle,
                    style: Theme.of(context).textTheme.bodyLarge
                        ?.copyWith(color: context.colors.inkSoft),
                  ),
                  const SizedBox(height: 24),
                  if (failure != null) StorageBanner(failure: failure),
                  if (items.isEmpty && failure == null) ...[
                    const SizedBox(height: 32),
                    EmptyState(
                      icon: Icons.medication_outlined,
                      title: context.l10n.emptyCabinetTitle,
                      body: context.l10n.emptyCabinetBody,
                      actionLabel: context.l10n.addMedication,
                      onAction: () => context.push(Routes.newMedication),
                    ),
                  ],
                ],
              ),
              SliverList.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _MedCard(key: ValueKey(item.id), med: item),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

final class _MedCard extends StatelessWidget {
  const _MedCard({required this.med, super.key});

  final Medication med;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final formats = context.formats;
    final quantity = med.quantity;
    final textTheme = Theme.of(context).textTheme;
    return PaperCard(
      onTap: () => context.push(Routes.editMedication(med.id)),
      child: Row(
        children: [
          PillGlyph(shape: med.shape, color: med.color),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(med.name, style: textTheme.titleLarge),
                const SizedBox(height: 2),
                Text(
                  [
                    if (med.dosage.isNotEmpty) med.dosage,
                    formats.times(med.timesMinutes),
                  ].join(' · '),
                  style: textTheme.bodyMedium,
                ),
                Text(formats.days(med.daysOfWeek), style: textTheme.bodyMedium),
                if (quantity != null)
                  Text(
                    med.needsRefill
                        ? '${l10n.pillsLeft(quantity)} · ${l10n.refillSoonTag}'
                        : l10n.pillsLeft(quantity),
                    style: textTheme.labelSmall?.copyWith(
                      color: med.needsRefill
                          ? context.colors.warning
                          : context.colors.inkSoft,
                      letterSpacing: 0.3,
                    ),
                  ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: context.colors.inkSoft),
        ],
      ),
    );
  }
}
