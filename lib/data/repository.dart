import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:mamiro/core/app_log.dart';
import 'package:mamiro/core/app_settings.dart';
import 'package:mamiro/core/dose_event.dart';
import 'package:mamiro/core/dose_slot.dart';
import 'package:mamiro/core/medication.dart';
import 'package:mamiro/core/result.dart';
import 'package:mamiro/core/snapshot.dart';
import 'package:mamiro/core/storage_failure.dart';
import 'package:mamiro/data/app_database.dart';
import 'package:mamiro/data/demo_cabinet.dart';
import 'package:mamiro/data/legacy_snapshot_codec.dart';
import 'package:mamiro/data/row_mapping.dart';

final class MamiroRepository {
  MamiroRepository(this._database, {SharedPreferences? legacyPreferences}) {
    _legacyPreferences = legacyPreferences;
  }

  static const legacySnapshotKey = 'mamiro.snapshot.v1';
  static const _initializedKey = 'database.initialized';
  static const _permissionPrimerKey = 'onboarding.permission_primer_shown';

  final AppDatabase _database;
  SharedPreferences? _legacyPreferences;

  Stream<Result<List<Medication>, StorageFailure>> watchMedications() {
    return _watch(
      readsFrom: {
        _database.medications,
        _database.medicationTimes,
        _database.medicationDays,
      },
      load: _loadMedications,
      triggerSql: 'SELECT 1 AS medications_watch',
      sqliteOp: 'medications.watch.sqlite',
      formatOp: 'medications.watch.format',
    );
  }

  Stream<Result<List<DoseEvent>, StorageFailure>> watchDoseEventsSince(
    DateTime from,
  ) async* {
    final fromUtcMs = utcMs(DateTime(from.year, from.month, from.day));
    try {
      final query = _database.select(_database.doseEvents)
        ..where(
          (row) =>
              row.scheduledAtUtcMs.isBiggerOrEqualValue(fromUtcMs) |
              row.occurredAtUtcMs.isBiggerOrEqualValue(fromUtcMs),
        )
        ..orderBy([(row) => OrderingTerm.desc(row.occurredAtUtcMs)]);
      await for (final rows in query.watch()) {
        yield Ok([for (final row in rows) doseEventFromRow(row)]);
      }
    } on SqliteException catch (error, stack) {
      logUnexpected('mamiro.storage', 'events.watch.sqlite', error, stack);
      yield const Err(StorageUnavailable());
    } on FormatException catch (error, stack) {
      logUnexpected('mamiro.storage', 'events.watch.format', error, stack);
      yield const Err(StorageCorrupt());
    }
  }

  Stream<Result<AppSettings, StorageFailure>> watchSettings() {
    return _watch(
      readsFrom: {_database.settings},
      load: _loadSettings,
      triggerSql: 'SELECT 1 AS settings_watch',
      sqliteOp: 'settings.watch.sqlite',
      formatOp: 'settings.watch.format',
    );
  }

  @useResult
  Future<Result<Snapshot, StorageFailure>> readSnapshot() async {
    try {
      return Ok(
        Snapshot(
          initialized: true,
          medications: await _loadMedications(),
          events: await _loadEvents(),
          settings: await _loadSettings(),
        ),
      );
    } on SqliteException catch (error, stack) {
      logUnexpected('mamiro.storage', 'snapshot.read.sqlite', error, stack);
      return const Err(StorageUnavailable());
    } on FormatException catch (error, stack) {
      logUnexpected('mamiro.storage', 'snapshot.read.format', error, stack);
      return const Err(StorageCorrupt());
    }
  }

  /// Seeds the demo cabinet on first launch. Its doses start on [now]'s day,
  /// so a fresh install has no history of missed doses.
  @useResult
  Future<Result<void, StorageFailure>> initialize({
    DateTime? now,
    List<Medication>? demo,
  }) async {
    final initialized = await _isInitialized();
    switch (initialized) {
      case Err(:final failure):
        return Err(failure);
      case Ok(value: true):
        return const Ok(null);
      case Ok(value: false):
        break;
    }
    final legacy = await _readLegacySnapshot();
    switch (legacy) {
      case Err(:final failure):
        return Err(failure);
      case Ok(:final value):
        final result = await _write('initialize', () async {
          final snapshot =
              value ??
              Snapshot(
                initialized: true,
                medications: demo ?? demoCabinet(),
                events: const [],
                settings: AppSettings.defaults,
              );
          await _database.transaction(() async {
            await _replaceSnapshot(
              snapshot,
              clearExisting: false,
              seededAt: value == null ? now : null,
            );
            await _database
                .into(_database.metadata)
                .insert(
                  MetadataCompanion.insert(key: _initializedKey, value: '1'),
                );
          });
        });
        if (result case Err()) return result;
        if (value != null) {
          final cleanup = await _removeLegacySnapshot();
          if (cleanup case Err()) return cleanup;
        }
        return const Ok(null);
    }
  }

  @useResult
  Future<Result<void, StorageFailure>> upsertMedication(
    Medication medication,
    DateTime now,
  ) {
    return _write('medication.upsert', () {
      return _database.transaction(() async {
        await _writeMedication(medication, now);
      });
    });
  }

  @useResult
  Future<Result<void, StorageFailure>> softDeleteMedication(
    String id,
    DateTime now,
  ) {
    return _write('medication.delete', () {
      return _database.transaction(() async {
        await (_database.update(
          _database.medications,
        )..where((row) => row.id.equals(id))).write(
          MedicationsCompanion(
            isDeleted: const Value(true),
            deletedAtUtcMs: Value(utcMs(now)),
            updatedAtUtcMs: Value(utcMs(now)),
          ),
        );
      });
    });
  }

  @useResult
  Future<Result<void, StorageFailure>> recordSlot({
    required DoseSlot slot,
    required DoseAction action,
    required DateTime now,
    required String eventId,
    int snoozeMinutes = 0,
  }) {
    return recordDose(
      slot.toEvent(
        id: eventId,
        at: now,
        action: action,
        snoozeMinutes: snoozeMinutes,
      ),
      decrementQuantity: action == DoseAction.taken,
    );
  }

  @useResult
  Future<Result<void, StorageFailure>> recordDose(
    DoseEvent event, {
    required bool decrementQuantity,
  }) {
    return _write('dose.record', () {
      return _database.transaction(() async {
        final resolved =
            await (_database.select(_database.doseEvents)..where(
                  (row) =>
                      row.medicationId.equals(event.medicationId) &
                      row.scheduledAtUtcMs.equals(utcMs(event.scheduledAt)) &
                      row.action.isIn(const ['taken', 'skipped']),
                ))
                .getSingleOrNull();
        if (resolved != null) return;
        await _insertEvent(event);
        if (!decrementQuantity) return;
        final medication = await (_database.select(
          _database.medications,
        )..where((row) => row.id.equals(event.medicationId))).getSingleOrNull();
        final quantity = medication?.quantity;
        if (medication == null || quantity == null) return;
        await (_database.update(
          _database.medications,
        )..where((row) => row.id.equals(event.medicationId))).write(
          MedicationsCompanion(
            quantity: Value(quantity > 0 ? quantity - 1 : 0),
            updatedAtUtcMs: Value(utcMs(event.at)),
          ),
        );
      });
    });
  }

  /// Reverts a Take or Skip so the slot is open again. Undoing a Take puts
  /// the pill back in the count.
  @useResult
  Future<Result<void, StorageFailure>> undoSlot({
    required String medicationId,
    required DateTime scheduledAt,
    required DateTime now,
  }) {
    return _write('dose.undo', () {
      return _database.transaction(() async {
        final resolved = (_database.select(_database.doseEvents)
          ..where(
            (row) =>
                row.medicationId.equals(medicationId) &
                row.scheduledAtUtcMs.equals(utcMs(scheduledAt)) &
                row.action.isIn(const ['taken', 'skipped']),
          ));
        final rows = await resolved.get();
        if (rows.isEmpty) return;
        await (_database.delete(
          _database.doseEvents,
        )..where((row) => row.id.isIn([for (final row in rows) row.id]))).go();
        if (!rows.any((row) => row.action == DoseAction.taken.name)) return;
        await _adjustQuantity(medicationId, 1, now);
      });
    });
  }

  @useResult
  Future<Result<void, StorageFailure>> addPills({
    required String medicationId,
    required int count,
    required DateTime now,
  }) {
    return _write('medication.restock', () {
      return _database.transaction(
        () => _adjustQuantity(medicationId, count, now),
      );
    });
  }

  Future<void> _adjustQuantity(
    String medicationId,
    int delta,
    DateTime now,
  ) async {
    final medication = await (_database.select(
      _database.medications,
    )..where((row) => row.id.equals(medicationId))).getSingleOrNull();
    final quantity = medication?.quantity;
    if (medication == null || quantity == null) return;
    await (_database.update(
      _database.medications,
    )..where((row) => row.id.equals(medicationId))).write(
      MedicationsCompanion(
        quantity: Value(quantity + delta < 0 ? 0 : quantity + delta),
        updatedAtUtcMs: Value(utcMs(now)),
      ),
    );
  }

  @useResult
  Future<Result<void, StorageFailure>> updateSettings(AppSettings settings) {
    return _write('settings.update', () {
      return _database.transaction(() async {
        await _writeSettings(settings);
      });
    });
  }

  @useResult
  Future<Result<void, StorageFailure>> restoreDemo(DateTime now) {
    return _write('cabinet.restore_demo', () {
      return _database.transaction(() async {
        await _retireCabinet(now);
        for (final medication in demoCabinet()) {
          await _writeMedication(medication, now);
        }
      });
    });
  }

  @useResult
  Future<Result<void, StorageFailure>> clearAll(DateTime now) {
    return _write('cabinet.clear', () {
      return _database.transaction(() async {
        await _retireCabinet(now);
        await _writeSettings(AppSettings.defaults);
      });
    });
  }

  /// Re-runs every watch query. Writes made by another isolate, such as an
  /// alarm action handled while the app was closed, are invisible otherwise.
  void refreshWatchers() {
    _database.notifyUpdates({
      for (final table in _database.allTables) TableUpdate.onTable(table),
    });
  }

  @useResult
  Future<Result<void, StorageFailure>> flush() {
    return _write('database.flush', () async {
      await _database.customStatement('PRAGMA wal_checkpoint(PASSIVE)');
    });
  }

  Stream<Result<T, StorageFailure>> _watch<T>({
    required Set<ResultSetImplementation<dynamic, dynamic>> readsFrom,
    required Future<T> Function() load,
    required String triggerSql,
    required String sqliteOp,
    required String formatOp,
  }) async* {
    try {
      final trigger = _database.customSelect(triggerSql, readsFrom: readsFrom);
      await for (final _ in trigger.watch()) {
        yield Ok(await load());
      }
    } on SqliteException catch (error, stack) {
      logUnexpected('mamiro.storage', sqliteOp, error, stack);
      yield const Err(StorageUnavailable());
    } on FormatException catch (error, stack) {
      logUnexpected('mamiro.storage', formatOp, error, stack);
      yield const Err(StorageCorrupt());
    }
  }

  Future<List<Medication>> _loadMedications() async {
    final medicationRows = await (_database.select(
      _database.medications,
    )..where((row) => row.isDeleted.equals(false))).get();
    final timeRows = await _database.select(_database.medicationTimes).get();
    final dayRows = await _database.select(_database.medicationDays).get();
    final timesByMedication = <String, List<int>>{};
    for (final row in timeRows) {
      (timesByMedication[row.medicationId] ??= []).add(row.minutes);
    }
    final daysByMedication = <String, List<int>>{};
    for (final row in dayRows) {
      (daysByMedication[row.medicationId] ??= []).add(row.weekday);
    }
    return [
      for (final row in medicationRows)
        medicationFromRow(
          row,
          timesMinutes: [...?timesByMedication[row.id]]..sort(),
          daysOfWeek: [...?daysByMedication[row.id]]..sort(),
        ),
    ];
  }

  Future<List<DoseEvent>> _loadEvents() async {
    final eventRows = await (_database.select(
      _database.doseEvents,
    )..orderBy([(row) => OrderingTerm.desc(row.occurredAtUtcMs)])).get();
    return [for (final row in eventRows) doseEventFromRow(row)];
  }

  Future<AppSettings> _loadSettings() async {
    return settingsFromRow(
      await _database.select(_database.settings).getSingle(),
    );
  }

  Future<void> _retireCabinet(DateTime now) async {
    await _database.delete(_database.doseEvents).go();
    await _database
        .update(_database.medications)
        .write(
          MedicationsCompanion(
            isDeleted: const Value(true),
            deletedAtUtcMs: Value(utcMs(now)),
            updatedAtUtcMs: Value(utcMs(now)),
          ),
        );
  }

  Future<void> _replaceSnapshot(
    Snapshot snapshot, {
    required bool clearExisting,
    DateTime? seededAt,
  }) async {
    if (clearExisting) {
      await _database.delete(_database.doseEvents).go();
      await _database.delete(_database.medicationDays).go();
      await _database.delete(_database.medicationTimes).go();
      await _database.delete(_database.medications).go();
      await _database.delete(_database.settings).go();
    }
    final importedAt =
        seededAt ??
        (snapshot.events.isEmpty
            ? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true)
            : snapshot.events.last.at);
    for (final medication in snapshot.medications) {
      await _writeMedication(medication, importedAt);
    }
    for (final event in snapshot.events) {
      await _insertEvent(event);
    }
    await _writeSettings(snapshot.settings);
  }

  Future<void> _writeMedication(Medication medication, DateTime now) async {
    final existing = await (_database.select(
      _database.medications,
    )..where((row) => row.id.equals(medication.id))).getSingleOrNull();
    final stamp = utcMs(now);
    await _database
        .into(_database.medications)
        .insertOnConflictUpdate(
          MedicationsCompanion.insert(
            id: medication.id,
            name: medication.name,
            dosage: medication.dosage,
            notes: Value(medication.notes),
            shape: medication.shape.name,
            color: medication.color.name,
            quantity: Value(medication.quantity),
            refillThreshold: Value(medication.refillThreshold),
            isDeleted: const Value(false),
            // A restored medication starts over; its old history is gone.
            createdAtUtcMs: existing == null || existing.isDeleted
                ? stamp
                : existing.createdAtUtcMs,
            updatedAtUtcMs: stamp,
            deletedAtUtcMs: const Value(null),
          ),
        );
    await (_database.delete(
      _database.medicationTimes,
    )..where((row) => row.medicationId.equals(medication.id))).go();
    await (_database.delete(
      _database.medicationDays,
    )..where((row) => row.medicationId.equals(medication.id))).go();
    for (final minutes in medication.timesMinutes) {
      await _database
          .into(_database.medicationTimes)
          .insert(
            MedicationTimesCompanion.insert(
              medicationId: medication.id,
              minutes: minutes,
            ),
          );
    }
    for (final weekday in medication.daysOfWeek) {
      await _database
          .into(_database.medicationDays)
          .insert(
            MedicationDaysCompanion.insert(
              medicationId: medication.id,
              weekday: weekday,
            ),
          );
    }
  }

  Future<void> _insertEvent(DoseEvent event) {
    return _database
        .into(_database.doseEvents)
        .insert(
          DoseEventsCompanion.insert(
            id: event.id,
            medicationId: event.medicationId,
            medicationName: event.medicationName,
            scheduledAtUtcMs: utcMs(event.scheduledAt),
            occurredAtUtcMs: utcMs(event.at),
            action: event.action.name,
            snoozeUntilUtcMs: Value(
              event.snoozeUntil?.toUtc().millisecondsSinceEpoch,
            ),
          ),
        );
  }

  Future<void> _writeSettings(AppSettings settings) {
    return _database
        .into(_database.settings)
        .insertOnConflictUpdate(
          SettingsCompanion.insert(
            id: const Value(1),
            sound: settings.sound,
            vibration: settings.vibration,
            banners: settings.banners,
            snoozeMinutes: settings.snoozeMinutes,
            theme: Value(settings.theme.name),
          ),
        );
  }

  Future<Result<Snapshot?, StorageFailure>> _readLegacySnapshot() async {
    try {
      final preferences = _legacyPreferences ??=
          await SharedPreferences.getInstance();
      final raw = preferences.getString(legacySnapshotKey);
      if (raw == null) return const Ok(null);
      final Object? decoded = jsonDecode(raw);
      if (decoded is! Map<String, Object?>) {
        return const Err(StorageCorrupt());
      }
      return Ok(decodeLegacySnapshot(decoded));
    } on FormatException catch (error, stack) {
      logUnexpected('mamiro.storage', 'legacy.decode', error, stack);
      return const Err(StorageCorrupt());
    } on PlatformException catch (error, stack) {
      logUnexpected('mamiro.storage', 'legacy.read.plugin', error, stack);
      return const Err(StorageUnavailable());
    } on MissingPluginException catch (error, stack) {
      logUnexpected(
        'mamiro.storage',
        'legacy.read.missing_plugin',
        error,
        stack,
      );
      return const Err(StorageUnavailable());
    }
  }

  /// Whether the alarm permission explanation has already been shown.
  @useResult
  Future<Result<bool, StorageFailure>> permissionPrimerShown() async {
    try {
      final row =
          await (_database.select(_database.metadata)
                ..where((item) => item.key.equals(_permissionPrimerKey)))
              .getSingleOrNull();
      return Ok(row != null);
    } on SqliteException catch (error, stack) {
      logUnexpected('mamiro.storage', 'primer.read', error, stack);
      return const Err(StorageUnavailable());
    }
  }

  /// Records that the explanation was shown, whatever the answer, so it
  /// never appears again. Settings can still grant access later.
  @useResult
  Future<Result<void, StorageFailure>> markPermissionPrimerShown() {
    return _write('primer.mark', () async {
      await _database
          .into(_database.metadata)
          .insertOnConflictUpdate(
            MetadataCompanion.insert(key: _permissionPrimerKey, value: '1'),
          );
    });
  }

  Future<Result<bool, StorageFailure>> _isInitialized() async {
    try {
      final row = await (_database.select(
        _database.metadata,
      )..where((item) => item.key.equals(_initializedKey))).getSingleOrNull();
      return Ok(row != null);
    } on SqliteException catch (error, stack) {
      logUnexpected('mamiro.storage', 'initialize.read', error, stack);
      return const Err(StorageUnavailable());
    }
  }

  Future<Result<void, StorageFailure>> _removeLegacySnapshot() async {
    try {
      final preferences = _legacyPreferences ??=
          await SharedPreferences.getInstance();
      await preferences.remove(legacySnapshotKey);
      return const Ok(null);
    } on PlatformException catch (error, stack) {
      logUnexpected('mamiro.storage', 'legacy.remove.plugin', error, stack);
      return const Err(StorageUnavailable());
    } on MissingPluginException catch (error, stack) {
      logUnexpected(
        'mamiro.storage',
        'legacy.remove.missing_plugin',
        error,
        stack,
      );
      return const Err(StorageUnavailable());
    }
  }

  Future<Result<void, StorageFailure>> _write(
    String operation,
    Future<void> Function() action,
  ) async {
    try {
      await action();
      return const Ok(null);
    } on SqliteException catch (error, stack) {
      logUnexpected('mamiro.storage', operation, error, stack);
      return Err(StorageConstraintViolation(operation));
    }
  }
}
