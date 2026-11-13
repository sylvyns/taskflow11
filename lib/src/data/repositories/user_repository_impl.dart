import 'package:dartz/dartz.dart' show Either, Unit, unit;

import '../../../core/error/error_handler.dart';
import '../../../core/error/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_local_data_source.dart';
import '../mapper/user_mapper.dart';

class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl(this.localDataSource);

  final UserLocalDataSource localDataSource;

  @override
  Future<Either<Failure, List<UserEntity>>> getUsers() => safeCall(() async {
        final users = await localDataSource.getUsers();
        return users.map((u) => u.toEntity()).toList();
      });

  @override
  Future<Either<Failure, Unit>> addUser({required String name, required String email}) => safeCall(() async {
        await localDataSource.addUser(name: name, email: email);
        return unit;
      });

  @override
  Future<Either<Failure, Unit>> deleteUser(int id) => safeCall(() async {
        await localDataSource.deleteUser(id);
        return unit;
      });

  @override
  Future<Either<Failure, int>> countOpenTasks(int userId) => safeCall(() => localDataSource.countOpenTasks(userId));
}
