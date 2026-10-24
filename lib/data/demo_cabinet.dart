import 'package:mamiro/core/medication.dart';
import 'package:mamiro/l10n/l10n.dart';

/// The sample cabinet, in the device language unless [l10n] is given.
List<Medication> demoCabinet([AppLocalizations? l10n]) {
  final copy = l10n ?? platformLocalizations();
  return [
    Medication(
      id: 'demo-vitamin-d3',
      name: copy.demoVitaminD3,
      dosage: '2000 IU',
      notes: copy.demoWithBreakfast,
      shape: PillShape.capsule,
      color: PillColor.sand,
      timesMinutes: const [8 * 60],
      daysOfWeek: const [],
      quantity: 8,
      refillThreshold: 10,
    ),
    Medication(
      id: 'demo-omega-3',
      name: 'Omega-3',
      dosage: '1000 mg',
      notes: copy.demoWithBreakfast,
      shape: PillShape.softgel,
      color: PillColor.moss,
      timesMinutes: const [8 * 60],
      daysOfWeek: const [],
      quantity: 40,
      refillThreshold: 10,
    ),
    Medication(
      id: 'demo-lisinopril',
      name: 'Lisinopril',
      dosage: '10 mg',
      notes: copy.demoSameTimes,
      shape: PillShape.tablet,
      color: PillColor.terracotta,
      timesMinutes: const [8 * 60, 20 * 60],
      daysOfWeek: const [],
      quantity: 20,
      refillThreshold: 6,
    ),
    Medication(
      id: 'demo-magnesium',
      name: copy.demoMagnesium,
      dosage: '400 mg',
      notes: copy.demoBeforeBed,
      shape: PillShape.capsule,
      color: PillColor.slate,
      timesMinutes: const [21 * 60],
      daysOfWeek: const [],
      quantity: 30,
      refillThreshold: 8,
    ),
  ];
}
