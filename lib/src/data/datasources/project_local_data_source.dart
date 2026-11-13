import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/error/exceptions.dart';
import '../../../models/local_models.dart';
import '../../domain/entities/enums.dart';

/// Local DataSource проектов.
abstract class ProjectLocalDataSource {
  Future<List<ProjectWithStats>> getProjects();

  Future<void> addProject({required String name, required String description});

  Future<void> deleteProject(int id);
}

class ProjectLocalDataSourceImpl implements ProjectLocalDataSource {
  ProjectLocalDataSourceImpl(this._db);

  final AppDatabase _db;

  @override
  Future<List<ProjectWithStats>> getProjects() async {
    final p = _db.projects;
    final t = _db.tasks;
    final total = t.id.count();
    final done = t.id.count(filter: t.status.equals(TaskStatus.done.name));
    final cancelled = t.id.count(filter: t.status.equals(TaskStatus.cancelled.name));

    // Проекты + количество задач (LEFT JOIN + GROUP BY).
    final query = _db.select(p).join([
      leftOuterJoin(t, t.projectId.equalsExp(p.id) & t.deletedAt.isNull(), useColumns: false),
    ])
      ..addColumns([total, done, cancelled])
      ..groupBy([p.id])
      ..orderBy([OrderingTerm.desc(p.createdAt), OrderingTerm.desc(p.id)]);

    final rows = await query.get();
    return rows
        .map(
          (row) => ProjectWithStats(
            project: row.readTable(p),
            total: row.read(total) ?? 0,
            done: row.read(done) ?? 0,
            cancelled: row.read(cancelled) ?? 0,
          ),
        )
        .toList();
  }

  @override
  Future<void> addProject({required String name, required String description}) async {
    await _db.into(_db.projects).insert(
          ProjectsCompanion.insert(
            name: name,
            description: Value(description),
            createdAt: Value(DateTime.now()),
          ),
        );
  }

  /// Задачи проекта удаляются каскадно (ON DELETE CASCADE).
  @override
  Future<void> deleteProject(int id) async {
    final deleted = await (_db.delete(_db.projects)..where((p) => p.id.equals(id))).go();
    if (deleted == 0) throw const NotFoundException('Проект не найден');
  }
}
