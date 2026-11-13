import 'package:dartz/dartz.dart' show Either, Left, Unit;

import '../../../../core/error/failures.dart';
import '../../repositories/user_repository.dart';

/// Удаление пользователя.
/// Бизнес-правило: нельзя удалить того, у кого есть незавершённые задачи.
class DeleteUserUseCase {
  DeleteUserUseCase(this.repository);

  final UserRepository repository;

  Future<Either<Failure, Unit>> call(int userId) async {
    final countResult = await repository.countOpenTasks(userId);

    return countResult.fold<Future<Either<Failure, Unit>>>(
      (failure) async => Left(failure),
      (openTasks) async {
        if (openTasks > 0) {
          return Left(ValidationFailure('Нельзя удалить: у пользователя незавершённые задачи ($openTasks)'));
        }
        return repository.deleteUser(userId);
      },
    );
  }
}
