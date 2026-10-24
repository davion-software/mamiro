import 'package:meta/meta.dart';
import 'package:mamiro/core/dose_slot.dart';

enum DayMark { empty, pending, complete, mixed }

@immutable
final class DaySummary {
  const DaySummary({
    required this.day,
    required this.mark,
    this.slots = const [],
  });

  final DateTime day;
  final DayMark mark;
  final List<DoseSlot> slots;
}
