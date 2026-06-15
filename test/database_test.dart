import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  // 1. Initialize FFI SQLite system:
  sqfliteFfiInit();

  // 2. Override the global database factory:
  databaseFactory = databaseFactoryFfi;

  test('Local DB testing demo', () async {
    // 3. Open temporary database in computer RAM:
    final db = await databaseFactory.openDatabase(inMemoryDatabasePath);

    // 4. Run database setup:
    await db.execute(
      'CREATE TABLE partners (id INTEGER PRIMARY KEY, name TEXT)',
    );

    // 5. Test inserting record:
    await db.insert('partners', {'name': 'Naruto'});

    // 6. Verify record exists:
    final results = await db.query('partners');
    expect(results.first['name'], 'Naruto');

    // 7. Always close connection:
    await db.close();
  });
}
