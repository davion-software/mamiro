import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mamiro/core/app_settings.dart';
import 'package:mamiro/core/medication.dart';
import 'package:mamiro/core/result.dart';
import 'package:mamiro/core/storage_failure.dart';
import 'package:mamiro/data/app_database.dart';
import 'package:mamiro/data/repository.dart';

final appDatabaseProvider = Provider<AppDatabase>(
  (ref) =>
      throw UnimplementedError('Override appDatabaseProvider in bootstrap'),
);

final mamiroRepositoryProvider = Provider<MamiroRepository>(
  (ref) => MamiroRepository(ref.watch(appDatabaseProvider)),
);

final medicationsProvider =
    StreamProvider<Result<List<Medication>, StorageFailure>>(
      (ref) => ref.watch(mamiroRepositoryProvider).watchMedications(),
    );

final settingsProvider = StreamProvider<Result<AppSettings, StorageFailure>>(
  (ref) => ref.watch(mamiroRepositoryProvider).watchSettings(),
);
