import 'package:dartz/dartz.dart' show Either;

import '../../../../core/error/failures.dart';
import '../../entities/task_template_entity.dart';
import '../../repositories/task_repository.dart';

/// Загрузка задач с сервера для импорта.
class FetchServerTasksUseCase {
  FetchServerTasksUseCase(this.repository);

  final TaskRepository repository;

  Future<Either<Failure, List<TaskTemplateEntity>>> call({int limit = 10}) =>
      repository.fetchServerTasks(limit: limit);
}
