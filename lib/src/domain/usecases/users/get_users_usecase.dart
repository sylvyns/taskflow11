import 'package:dartz/dartz.dart' show Either;

import '../../../../core/error/failures.dart';
import '../../entities/user_entity.dart';
import '../../repositories/user_repository.dart';

class GetUsersUseCase {
  GetUsersUseCase(this.repository);

  final UserRepository repository;

  Future<Either<Failure, List<UserEntity>>> call() => repository.getUsers();
}
