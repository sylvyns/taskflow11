import 'package:dartz/dartz.dart' show Either, Unit;

import '../../../core/error/failures.dart';
import '../entities/enums.dart';
import '../entities/task_entity.dart';
import '../entities/task_filter.dart';
import '../entities/task_template_entity.dart';

abstract class TaskRepository {
  Future<Either<Failure, List<TaskEntity>>> getTasks(TaskFilter filter);

  Future<Either<Failure, Unit>> addTask({
    required int projectId,
    required String title,
    required String description,
    required TaskPriority priority,
    required DateTime deadline,
    int? assigneeId,
  });

  Future<Either<Failure, Unit>> changeStatus(int taskId, TaskStatus status);

  Future<Either<Failure, Unit>> deleteTask(int taskId);

  /// Сколько незавершённых задач у исполнителя на эту дату.
  Future<Either<Failure, int>> countOpenTasksOnDate(int assigneeId, DateTime date);

  /// Новая функция: добавить/убрать из избранного. Возвращает новое значение.
  Future<Either<Failure, bool>> toggleFavorite(int taskId);

  /// Загрузка задач с сервера (Remote DataSource).
  Future<Either<Failure, List<TaskTemplateEntity>>> fetchServerTasks({int limit = 10});

  /// Сохранение загруженных задач в проект. Возвращает количество.
  Future<Either<Failure, int>> importTasks(int projectId, List<TaskTemplateEntity> templates);
}
