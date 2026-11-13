import 'package:dartz/dartz.dart' show Either, Left, Right, Unit, unit;
import 'package:taskflow/core/error/failures.dart';
import 'package:taskflow/src/domain/entities/enums.dart';
import 'package:taskflow/src/domain/entities/task_entity.dart';
import 'package:taskflow/src/domain/entities/task_filter.dart';
import 'package:taskflow/src/domain/entities/task_template_entity.dart';
import 'package:taskflow/src/domain/entities/user_entity.dart';
import 'package:taskflow/src/domain/repositories/task_repository.dart';
import 'package:taskflow/src/domain/repositories/user_repository.dart';

/// Простые «фейковые» репозитории — тестируем Domain и Cubit без базы данных.

class FakeUserRepository implements UserRepository {
  List<UserEntity> users = [];
  Failure? failure;
  int openTasks = 0;
  bool deleted = false;

  @override
  Future<Either<Failure, List<UserEntity>>> getUsers() async => failure != null ? Left(failure!) : Right(users);

  @override
  Future<Either<Failure, Unit>> addUser({required String name, required String email}) async {
    users = [...users, UserEntity(id: users.length + 1, name: name, email: email, registeredAt: DateTime.now())];
    return const Right(unit);
  }

  @override
  Future<Either<Failure, Unit>> deleteUser(int id) async {
    deleted = true;
    return const Right(unit);
  }

  @override
  Future<Either<Failure, int>> countOpenTasks(int userId) async => Right(openTasks);
}

class FakeTaskRepository implements TaskRepository {
  int openTasksOnDate = 0;
  int added = 0;

  @override
  Future<Either<Failure, int>> countOpenTasksOnDate(int assigneeId, DateTime date) async => Right(openTasksOnDate);

  @override
  Future<Either<Failure, Unit>> addTask({
    required int projectId,
    required String title,
    required String description,
    required TaskPriority priority,
    required DateTime deadline,
    int? assigneeId,
  }) async {
    added++;
    return const Right(unit);
  }

  @override
  Future<Either<Failure, List<TaskEntity>>> getTasks(TaskFilter filter) async => const Right([]);

  @override
  Future<Either<Failure, Unit>> changeStatus(int taskId, TaskStatus status) async => const Right(unit);

  @override
  Future<Either<Failure, Unit>> deleteTask(int taskId) async => const Right(unit);

  @override
  Future<Either<Failure, bool>> toggleFavorite(int taskId) async => const Right(true);

  @override
  Future<Either<Failure, List<TaskTemplateEntity>>> fetchServerTasks({int limit = 10}) async => const Right([]);

  @override
  Future<Either<Failure, int>> importTasks(int projectId, List<TaskTemplateEntity> templates) async =>
      Right(templates.length);
}
