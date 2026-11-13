import 'package:drift/drift.dart';

import '../../src/domain/entities/enums.dart';
import 'indexes.dart';
import 'tables.dart';

part 'app_database.g.dart';

/// База данных TaskFlow (SQLite через Drift) — источник для Local DataSource'ов.
///
/// Схема та же, что в задании №10 (v2), поэтому старые данные сохраняются.
@DriftDatabase(tables: [Users, Projects, ProjectMembers, Tasks, Comments, Attachments, TaskHistory])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await createIndexes();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.addColumn(tasks, tasks.priority);
          }
          await createIndexes();
        },
        beforeOpen: (details) async {
          // Включаем внешние ключи и каскадное удаление.
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  Future<void> createIndexes() async {
    for (final sql in appIndexes.values) {
      await customStatement(sql);
    }
  }
}
