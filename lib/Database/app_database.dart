import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

// 2. Configure and build the local database connection
@DriftDatabase(tables: [SalahTimeTables])
class AppDatabase extends _$AppDatabase {
  static final AppDatabase _instance = AppDatabase._internal();

  // Configures Drift to automatically locate a safe documents directory on iOS/Android
  AppDatabase._internal()
    : super(
        driftDatabase(
          name: 'salah_timetable_db',
          web: DriftWebOptions(
            sqlite3Wasm: Uri.parse('sqlite3.wasm'),
            driftWorker: Uri.parse('drift_worker.js'),
          ),
        ),
      );

  factory AppDatabase() => _instance;

  @override
  int get schemaVersion => 1;

  // ==========================================
  // DATABASE METHODS
  // ==========================================

  // Saves parsed entries efficiently using a single transaction batch
  Future<void> saveTimetableEntries(List<dynamic> entries) async {
    await transaction(() async {
      for (var entry in entries) {
        // Use lowercase "s" for 'salahTimeTables' here
        await into(salahTimeTables).insert(
          SalahTimeTablesCompanion.insert(
            salahName: entry.salahName,
            date: entry.date,
            timeString: entry.timeString,
          ),
        );
      }
    });
  }

  // Inside AppDatabase class:
  Future<void> clearAllData() async {
    await delete(salahTimeTables).go();
  }

  Stream<List<SalahTimeTable>> watchTodayPrayers(DateTime today) {
    // Use lowercase "s" for 'salahTimeTables' here
    return (select(salahTimeTables)
          ..where((t) => t.date.year.equals(today.year))
          ..where((t) => t.date.month.equals(today.month))
          ..where((t) => t.date.day.equals(today.day)))
        .watch();
  }
}

class SalahTimeTables extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get salahName => text()();

  DateTimeColumn get date => dateTime()();

  TextColumn get timeString => text()();
}
