import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/error/exceptions.dart';
import '../../../models/local_models.dart';
import '../../domain/entities/enums.dart';
import '../../domain/entities/task_filter.dart';
import '../../domain/entities/task_template_entity.dart';

/// Local DataSource задач — все SQL-запросы к таблице tasks.
abstract class TaskLocalDataSource {
  /// [onlyIds] — ограничить выборку этими id (для фильтра «Избранное»).
  Future<List<TaskWithRelations>> getTasks(TaskFilter filter, {Set<int>? onlyIds});

  Future<void> addTask({
    required int projectId,
    required String title,
    required String description,
    required TaskPriority priority,
    required DateTime deadline,
    int? assigneeId,
  });

  Future<void> changeStatus(int taskId, TaskStatus status);

  Future<void> deleteTask(int taskId);

  Future<int> countOpenTasksOnDate(int assigneeId, DateTime date);

  Future<int> insertMany(int projectId, List<TaskTemplateEntity> templates);
}

class TaskLocalDataSourceImpl implements TaskLocalDataSource {
  TaskLocalDataSourceImpl(this._db);

  final AppDatabase _db;

  @override
  Future<List<TaskWithRelations>> getTasks(TaskFilter filter, {Set<int>? onlyIds}) async {
    if (onlyIds != null && onlyIds.isEmpty) return const [];

    final t = _db.tasks;
    final p = _db.projects;
    final u = _db.users;

    // Задачи в корзине (deleted_at из задания №10) не показываем.
    Expression<bool> where = t.deletedAt.isNull();
    if (filter.projectId != null) where = where & t.projectId.equals(filter.projectId!);
    if (filter.status != null) where = where & t.status.equals(filter.status!.name);
    final text = filter.search.trim();
    if (text.isNotEmpty) {
      where = where & (t.title.like('%$text%') | t.description.like('%$text%'));
    }
    if (onlyIds != null) where = where & t.id.isIn(onlyIds);

    final query = _db.select(t).join([
      innerJoin(p, p.id.equalsExp(t.projectId)),
      leftOuterJoin(u, u.id.equalsExp(t.assigneeId)),
    ])
      ..where(where)
      ..orderBy([OrderingTerm.desc(t.createdAt), OrderingTerm.desc(t.id)]);

    final rows = await query.get();
    return rows
        .map(
          (row) => TaskWithRelations(
            task: row.readTable(t),
            project: row.readTable(p),
            assignee: row.readTableOrNull(u),
          ),
        )
        .toList();
  }

  @override
  Future<void> addTask({
    required int projectId,
    required String title,
    required String description,
    required TaskPriority priority,
    required DateTime deadline,
    int? assigneeId,
  }) async {
    await _requireProject(projectId);
    final now = DateTime.now();
    await _db.into(_db.tasks).insert(
          TasksCompanion.insert(
            title: title,
            description: Value(description),
            projectId: projectId,
            assigneeId: Value(assigneeId),
            priority: Value(priority),
            deadline: deadline,
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
        );
  }

  @override
  Future<void> changeStatus(int taskId, TaskStatus status) async {
    final updated = await (_db.update(_db.tasks)..where((t) => t.id.equals(taskId)))
        .write(TasksCompanion(status: Value(status), updatedAt: Value(DateTime.now())));
    if (updated == 0) throw const NotFoundException('Задача не найдена');
  }

  @override
  Future<void> deleteTask(int taskId) async {
    final deleted = await (_db.delete(_db.tasks)..where((t) => t.id.equals(taskId))).go();
    if (deleted == 0) throw const NotFoundException('Задача не найдена');
  }

  @override
  Future<int> countOpenTasksOnDate(int assigneeId, DateTime date) async {
    final t = _db.tasks;
    final start = DateTime(date.year, date.month, date.day);
    final end = DateTime(date.year, date.month, date.day + 1);
    final count = t.id.count();
    final query = _db.selectOnly(t)
      ..addColumns([count])
      ..where(
        t.assigneeId.equals(assigneeId) &
            t.deletedAt.isNull() &
            t.status.isIn([TaskStatus.todo.name, TaskStatus.inProgress.name]) &
            t.deadline.isBiggerOrEqualValue(start) &
            t.deadline.isSmallerThanValue(end),
      );
    return await query.map((row) => row.read(count)).getSingle() ?? 0;
  }

  /// Импорт: все задачи вставляются одной транзакцией (batch).
  @override
  Future<int> insertMany(int projectId, List<TaskTemplateEntity> templates) async {
    await _requireProject(projectId);
    final now = DateTime.now();
    final deadline = DateTime(now.year, now.month, now.day + 7);
    await _db.batch((batch) {
      batch.insertAll(_db.tasks, [
        for (final template in templates)
          TasksCompanion.insert(
            title: template.title.length > 200 ? template.title.substring(0, 200) : template.title,
            projectId: projectId,
            status: Value(template.isCompleted ? TaskStatus.done : TaskStatus.todo),
            deadline: deadline,
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
      ]);
    });
    return templates.length;
  }

  Future<void> _requireProject(int projectId) async {
    final project = await (_db.select(_db.projects)..where((p) => p.id.equals(projectId))).getSingleOrNull();
    if (project == null) throw const NotFoundException('Проект не найден');
  }
}
