import 'package:dartz/dartz.dart' show Either, Unit, unit;

import '../../../core/error/error_handler.dart';
import '../../../core/error/failures.dart';
import '../../domain/entities/enums.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/entities/task_filter.dart';
import '../../domain/entities/task_template_entity.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/favorites_local_data_source.dart';
import '../datasources/task_local_data_source.dart';
import '../datasources/task_remote_data_source.dart';
import '../mapper/task_mapper.dart';

/// Реализация репозитория задач. Объединяет три источника данных:
/// SQLite (задачи), SharedPreferences (избранное) и сервер (импорт).
class TaskRepositoryImpl implements TaskRepository {
  TaskRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.favoritesDataSource,
  });

  final TaskLocalDataSource localDataSource;
  final TaskRemoteDataSource remoteDataSource;
  final FavoritesLocalDataSource favoritesDataSource;

  @override
  Future<Either<Failure, List<TaskEntity>>> getTasks(TaskFilter filter) => safeCall(() async {
        final favoriteIds = favoritesDataSource.getFavoriteIds();
        final rows = await localDataSource.getTasks(
          filter,
          onlyIds: filter.favoritesOnly ? favoriteIds : null,
        );
        return rows.map((row) => row.toEntity(isFavorite: favoriteIds.contains(row.task.id))).toList();
      });

  @override
  Future<Either<Failure, Unit>> addTask({
    required int projectId,
    required String title,
    required String description,
    required TaskPriority priority,
    required DateTime deadline,
    int? assigneeId,
  }) =>
      safeCall(() async {
        await localDataSource.addTask(
          projectId: projectId,
          title: title,
          description: description,
          priority: priority,
          deadline: deadline,
          assigneeId: assigneeId,
        );
        return unit;
      });

  @override
  Future<Either<Failure, Unit>> changeStatus(int taskId, TaskStatus status) => safeCall(() async {
        await localDataSource.changeStatus(taskId, status);
        return unit;
      });

  @override
  Future<Either<Failure, Unit>> deleteTask(int taskId) => safeCall(() async {
        await localDataSource.deleteTask(taskId);
        await favoritesDataSource.remove(taskId);
        return unit;
      });

  @override
  Future<Either<Failure, int>> countOpenTasksOnDate(int assigneeId, DateTime date) =>
      safeCall(() => localDataSource.countOpenTasksOnDate(assigneeId, date));

  @override
  Future<Either<Failure, bool>> toggleFavorite(int taskId) => safeCall(() => favoritesDataSource.toggle(taskId));

  @override
  Future<Either<Failure, List<TaskTemplateEntity>>> fetchServerTasks({int limit = 10}) => safeCall(() async {
        final models = await remoteDataSource.fetchTasks(limit: limit);
        return models.map((m) => m.toEntity()).where((t) => t.title.isNotEmpty).toList();
      });

  @override
  Future<Either<Failure, int>> importTasks(int projectId, List<TaskTemplateEntity> templates) =>
      safeCall(() => localDataSource.insertMany(projectId, templates));
}
