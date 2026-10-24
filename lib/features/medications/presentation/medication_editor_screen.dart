import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mamiro/core/app_log.dart';
import 'package:mamiro/core/medication.dart';
import 'package:mamiro/features/medications/presentation/medications_notifier.dart';
import 'package:mamiro/features/medications/presentation/widgets/color_picker.dart';
import 'package:mamiro/features/medications/presentation/widgets/shape_picker.dart';
import 'package:mamiro/features/medications/presentation/widgets/weekday_picker.dart';
import 'package:mamiro/l10n/l10n.dart';
import 'package:mamiro/routing/routes.dart';
import 'package:mamiro/theme/palette.dart';
import 'package:mamiro/theme/widgets/circle_button.dart';

final class MedicationEditorScreen extends ConsumerStatefulWidget {
  const MedicationEditorScreen({super.key, this.medicationId});

  final String? medicationId;

  @override
  ConsumerState<MedicationEditorScreen> createState() =>
      _MedicationEditorScreenState();
}

final class _MedicationEditorScreenState
    extends ConsumerState<MedicationEditorScreen> {
  final _name = TextEditingController();
  final _dosage = TextEditingController();
  final _notes = TextEditingController();
  final _quantity = TextEditingController();
  final _threshold = TextEditingController();

  // Subscribed once in initState and closed in dispose.
  late final ProviderSubscription<MedicationsFeedback> _feedbackSubscription;
  // Subscribed once in initState and closed in dispose.
  late final ProviderSubscription<AsyncValue<MedicationsState>>
  _medicationsSubscription;

  PillShape _shape = PillShape.capsule;
  PillColor _color = PillColor.sage;
  List<int> _times = [8 * 60];
  Set<int> _days = {};
  bool _specificDays = false;
  bool _trackPills = false;
  bool _submitted = false;
  String? _hydratedId;
  bool _timeError = false;
  bool _daysError = false;

  bool get _isEditing => widget.medicationId != null;

  @override
  void initState() {
    super.initState();
    // The refill warning follows both numbers as they are typed.
    _quantity.addListener(_refresh);
    _threshold.addListener(_refresh);
    _tryHydrate(ref.read(medicationsNotifierProvider).value);
    _medicationsSubscription = ref.listenManual(medicationsNotifierProvider, (
      previous,
      next,
    ) {
      final wasHydrated = _hydratedId;
      _tryHydrate(next.value);
      if (_hydratedId != wasHydrated && mounted) setState(() {});
    });
    _feedbackSubscription = ref.listenManual(medicationsFeedbackProvider, (
      previous,
      next,
    ) {
      if (!mounted) return;
      if (next.shouldPop && previous?.shouldPop != true) {
        ref.read(medicationsFeedbackProvider.notifier).clear();
        GoRouter.of(context).pop();
        return;
      }
      final failure = next.failure;
      if (failure != null && failure != previous?.failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.formats.storageFailure(failure))),
        );
        ref.read(medicationsFeedbackProvider.notifier).clear();
      }
    });
  }

  @override
  void dispose() {
    _quantity.removeListener(_refresh);
    _threshold.removeListener(_refresh);
    _feedbackSubscription.close();
    _medicationsSubscription.close();
    _name.dispose();
    _dosage.dispose();
    _notes.dispose();
    _quantity.dispose();
    _threshold.dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_isEditing && _hydratedId == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final l10n = context.l10n;
    final formats = context.formats;
    final textTheme = Theme.of(context).textTheme;
    final errorStyle = textTheme.bodyMedium?.copyWith(
      color: Theme.of(context).colorScheme.error,
    );
    final quantity = int.tryParse(_quantity.text);
    final threshold = int.tryParse(_threshold.text);
    final atRefillLevel =
        _trackPills &&
        quantity != null &&
        threshold != null &&
        quantity <= threshold;
    return Form(
      autovalidateMode: _submitted
          ? AutovalidateMode.onUserInteraction
          : AutovalidateMode.disabled,
      child: Builder(
        builder: (formContext) => Scaffold(
          appBar: AppBar(
            leadingWidth: 72,
            toolbarHeight: 72,
            leading: Padding(
              padding: const EdgeInsetsDirectional.only(start: 20),
              child: Center(
                child: CircleButton(
                  icon: Icons.arrow_back,
                  tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                  onPressed: _close,
                ),
              ),
            ),
            title: Text(
              _isEditing ? l10n.editorEditTitle : l10n.editorAddTitle,
            ),
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
              child: FilledButton(
                onPressed: () => _save(formContext),
                child: Text(l10n.save),
              ),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
            children: [
              TextFormField(
                controller: _name,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(labelText: l10n.fieldName),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.nameRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _dosage,
                decoration: InputDecoration(
                  labelText: l10n.fieldDosage,
                  hintText: l10n.dosageHint,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.dosageRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.sectionTimes,
                      style: textTheme.titleMedium,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _pickTime,
                    icon: const Icon(Icons.add, size: 18),
                    label: Text(l10n.addTime),
                  ),
                ],
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final minutes in _times)
                    InputChip(
                      label: Text(
                        formats.minutes(minutes),
                        style: textTheme.titleMedium,
                      ),
                      avatar: const Icon(
                        Icons.schedule,
                        size: 18,
                        color: MamiroPalette.cobalt,
                      ),
                      backgroundColor: MamiroPalette.surface,
                      side: const BorderSide(
                        color: MamiroPalette.outlineStrong,
                      ),
                      onPressed: () => _pickTime(replacing: minutes),
                      onDeleted: _times.length == 1
                          ? null
                          : () => setState(() => _times.remove(minutes)),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                _timeError ? l10n.timesRequired : l10n.timeHelp,
                style: _timeError ? errorStyle : textTheme.bodyMedium,
              ),
              const SizedBox(height: 28),
              Text(l10n.sectionDays, style: textTheme.titleMedium),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<bool>(
                  showSelectedIcon: false,
                  segments: [
                    ButtonSegment(value: false, label: Text(l10n.everyDay)),
                    ButtonSegment(value: true, label: Text(l10n.daysSpecific)),
                  ],
                  selected: {_specificDays},
                  onSelectionChanged: (selection) => setState(() {
                    _specificDays = selection.single;
                    _daysError = false;
                  }),
                ),
              ),
              if (_specificDays) ...[
                const SizedBox(height: 12),
                WeekdayPicker(
                  days: _days,
                  onToggle: (weekday) {
                    setState(() {
                      if (!_days.remove(weekday)) _days.add(weekday);
                      _daysError = false;
                    });
                  },
                ),
                if (_daysError) ...[
                  const SizedBox(height: 6),
                  Text(l10n.daysRequired, style: errorStyle),
                ],
              ],
              const SizedBox(height: 28),
              Text(l10n.sectionInventory, style: textTheme.titleMedium),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.trackPills),
                subtitle: Text(l10n.trackPillsHelp),
                value: _trackPills,
                onChanged: (value) => setState(() => _trackPills = value),
              ),
              if (_trackPills) ...[
                const SizedBox(height: 4),
                TextFormField(
                  controller: _quantity,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(labelText: l10n.pillCount),
                  validator: _wholeNumberValidator(l10n.countRequired),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _threshold,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(labelText: l10n.thresholdField),
                  validator: _wholeNumberValidator(l10n.thresholdRequired),
                ),
                if (atRefillLevel) ...[
                  const SizedBox(height: 6),
                  Text(
                    l10n.thresholdWarning,
                    style: textTheme.bodyMedium?.copyWith(
                      color: MamiroPalette.coralDeep,
                    ),
                  ),
                ],
              ],
              const SizedBox(height: 28),
              Text(l10n.sectionAppearance, style: textTheme.titleMedium),
              const SizedBox(height: 10),
              ShapePicker(
                shape: _shape,
                color: _color,
                onChanged: (value) => setState(() => _shape = value),
              ),
              const SizedBox(height: 14),
              ColorPicker(
                color: _color,
                onChanged: (value) => setState(() => _color = value),
              ),
              const SizedBox(height: 28),
              TextFormField(
                controller: _notes,
                decoration: InputDecoration(
                  labelText: l10n.fieldNotes,
                  hintText: l10n.notesHint,
                ),
                minLines: 1,
                maxLines: 3,
              ),
              if (_isEditing) ...[
                const SizedBox(height: 24),
                TextButton(
                  onPressed: _delete,
                  style: TextButton.styleFrom(
                    foregroundColor: MamiroPalette.coralDeep,
                  ),
                  child: Text(l10n.deleteMedication),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _close() {
    final router = GoRouter.of(context);
    if (router.canPop()) {
      router.pop();
    } else {
      router.go(Routes.medications);
    }
  }

  FormFieldValidator<String> _wholeNumberValidator(String emptyMessage) {
    return (value) {
      if (!_trackPills) return null;
      if (value == null || value.isEmpty) return emptyMessage;
      if (int.tryParse(value) == null) return context.l10n.wholeNumber;
      return null;
    };
  }

  void _pickTime({int? replacing}) {
    unawaited(
      _choose(replacing).catchError(
        unexpectedLogger('mamiro.medications', 'medication_editor.intent'),
      ),
    );
  }

  Future<void> _choose(int? replacing) async {
    final initial = replacing ?? 8 * 60;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: initial ~/ 60, minute: initial % 60),
    );
    if (picked == null || !mounted) return;
    final minutes = picked.hour * 60 + picked.minute;
    setState(() {
      final times = {..._times};
      if (replacing != null) times.remove(replacing);
      times.add(minutes);
      _times = times.toList()..sort();
      _timeError = false;
    });
  }

  void _save(BuildContext formContext) {
    final valid = Form.of(formContext).validate();
    setState(() {
      _submitted = true;
      _timeError = _times.isEmpty;
      _daysError = _specificDays && _days.isEmpty;
    });
    if (!valid || _timeError || _daysError) return;
    final quantity = _trackPills ? int.tryParse(_quantity.text) : null;
    final threshold = _trackPills ? int.tryParse(_threshold.text) : null;
    if (_trackPills && (quantity == null || threshold == null)) return;
    final notifier = ref.read(medicationsNotifierProvider.notifier);
    final medicationId = widget.medicationId;
    final existing = medicationId == null
        ? null
        : ref
              .read(medicationsNotifierProvider)
              .value
              ?.medicationById(medicationId);
    notifier.save(
      Medication(
        id: existing?.id ?? notifier.createId(),
        name: _name.text.trim(),
        dosage: _dosage.text.trim(),
        notes: _notes.text.trim(),
        shape: _shape,
        color: _color,
        timesMinutes: [..._times]..sort(),
        daysOfWeek: _specificDays ? (_days.toList()..sort()) : const [],
        startsOn: existing?.startsOn,
        quantity: quantity,
        refillThreshold: threshold,
      ),
    );
  }

  void _delete() {
    unawaited(
      _confirmDelete().catchError(
        unexpectedLogger('mamiro.medications', 'medication_editor.intent'),
      ),
    );
  }

  Future<void> _confirmDelete() async {
    final medicationId = widget.medicationId;
    if (medicationId == null) return;
    final existing = ref
        .read(medicationsNotifierProvider)
        .value
        ?.medicationById(medicationId);
    if (existing == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(context.l10n.deleteTitle),
          content: Text(context.l10n.deleteBody(existing.name)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(context.l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(
                foregroundColor: MamiroPalette.coralDeep,
              ),
              child: Text(context.l10n.delete),
            ),
          ],
        );
      },
    );
    if (ok != true || !mounted) return;
    ref.read(medicationsNotifierProvider.notifier).delete(existing.id);
  }

  void _tryHydrate(MedicationsState? state) {
    final medicationId = widget.medicationId;
    if (medicationId == null || state == null || _hydratedId == medicationId) {
      return;
    }
    final existing = state.medicationById(medicationId);
    if (existing == null) return;
    _hydrate(existing);
  }

  void _hydrate(Medication existing) {
    _hydratedId = existing.id;
    _name.text = existing.name;
    _dosage.text = existing.dosage;
    _notes.text = existing.notes;
    _shape = existing.shape;
    _color = existing.color;
    _times = [...existing.timesMinutes]..sort();
    _days = {...existing.daysOfWeek};
    _specificDays = existing.daysOfWeek.isNotEmpty;
    _trackPills = existing.tracksPills;
    _quantity.text = existing.quantity?.toString() ?? '';
    _threshold.text = existing.refillThreshold?.toString() ?? '';
  }
}
