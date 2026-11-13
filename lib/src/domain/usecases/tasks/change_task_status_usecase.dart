import 'package:dartz/dartz.dart' show Either, Unit;

import '../../../../core/error/failures.dart';
import '../../entities/enums.dart';
import '../../repositories/task_repository.dart';

class ChangeTaskStatusUseCase {
  ChangeTaskStatusUseCase(this.repository);

  final TaskRepository repository;

  Future<Either<Failure, Unit>> call(int taskId, TaskStatus status) => repository.changeStatus(taskId, status);
}
