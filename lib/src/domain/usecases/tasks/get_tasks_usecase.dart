import 'package:dartz/dartz.dart' show Either;

import '../../../../core/error/failures.dart';
import '../../entities/task_entity.dart';
import '../../entities/task_filter.dart';
import '../../repositories/task_repository.dart';

class GetTasksUseCase {
  GetTasksUseCase(this.repository);

  final TaskRepository repository;

  Future<Either<Failure, List<TaskEntity>>> call(TaskFilter filter) => repository.getTasks(filter);
}
