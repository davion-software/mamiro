import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mamiro/core/result.dart';
import 'package:mamiro/core/storage_failure.dart';
import 'package:mamiro/data/app_database.dart';
import 'package:mamiro/data/repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('the permission explanation is remembered once marked', () async {
    SharedPreferences.setMockInitialValues({});
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = MamiroRepository(database);
    expect(await repository.initialize(), isA<Ok<void, StorageFailure>>());

    expect(
      await repository.permissionPrimerShown(),
      isA<Ok<bool, StorageFailure>>().having(
        (result) => result.value,
        'value',
        isFalse,
      ),
    );

    expect(
      await repository.markPermissionPrimerShown(),
      isA<Ok<void, StorageFailure>>(),
    );
    // Marking twice is harmless.
    expect(
      await repository.markPermissionPrimerShown(),
      isA<Ok<void, StorageFailure>>(),
    );

    expect(
      await repository.permissionPrimerShown(),
      isA<Ok<bool, StorageFailure>>().having(
        (result) => result.value,
        'value',
        isTrue,
      ),
    );
  });
}
