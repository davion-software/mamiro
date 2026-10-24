import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mamiro/core/result.dart';
import 'package:mamiro/core/snapshot.dart';
import 'package:mamiro/core/storage_failure.dart';
import 'package:mamiro/core/theme_choice.dart';
import 'package:mamiro/data/app_database.dart';
import 'package:mamiro/data/repository.dart';

Future<Snapshot> _read(MamiroRepository repository) async {
  return switch (await repository.readSnapshot()) {
    Ok(:final value) => value,
    Err(:final failure) => fail('Unexpected storage failure: ${failure.code}'),
  };
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('a version 1 database gains the theme with the default', () async {
    final directory = await Directory.systemTemp.createTemp('mamiro-v1');
    addTearDown(() => directory.delete(recursive: true));
    final file = File('${directory.path}/mamiro.sqlite');

    // Build today's schema, then turn it back into version 1.
    final current = AppDatabase(NativeDatabase(file));
    expect(
      await MamiroRepository(current).initialize(),
      isA<Ok<void, StorageFailure>>(),
    );
    await current.customStatement('ALTER TABLE settings DROP COLUMN theme');
    await current.customStatement('PRAGMA user_version = 1');
    await current.close();

    final upgraded = AppDatabase(NativeDatabase(file));
    addTearDown(upgraded.close);
    final repository = MamiroRepository(upgraded);

    expect((await _read(repository)).settings.theme, ThemeChoice.nightApricot);
    final snapshot = await _read(repository);
    expect(snapshot.medications, isNotEmpty);
  });

  test('the chosen theme is saved and read back', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = MamiroRepository(database);
    expect(await repository.initialize(), isA<Ok<void, StorageFailure>>());
    final settings = (await _read(repository)).settings;

    expect(
      await repository.updateSettings(
        settings.copyWith(theme: ThemeChoice.tealCoral),
      ),
      isA<Ok<void, StorageFailure>>(),
    );

    expect((await _read(repository)).settings.theme, ThemeChoice.tealCoral);
  });

  test('unknown theme names fall back to the default', () {
    expect(ThemeChoice.byName('from-the-future'), ThemeChoice.nightApricot);
    for (final choice in ThemeChoice.values) {
      expect(ThemeChoice.byName(choice.name), choice);
    }
  });
}
