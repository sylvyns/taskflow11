import 'package:dartz/dartz.dart' show Either, Unit;

import '../../../core/error/failures.dart';
import '../entities/user_entity.dart';

/// Абстракция репозитория. Domain знает только этот контракт,
/// а реализация (Drift) находится в Data-слое.
abstract class UserRepository {
  Future<Either<Failure, List<UserEntity>>> getUsers();

  Future<Either<Failure, Unit>> addUser({required String name, required String email});

  Future<Either<Failure, Unit>> deleteUser(int id);

  /// Количество незавершённых задач пользователя.
  Future<Either<Failure, int>> countOpenTasks(int userId);
}
