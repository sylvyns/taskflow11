import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow/core/error/failures.dart';
import 'package:taskflow/src/domain/usecases/tasks/add_task_usecase.dart';
import 'package:taskflow/src/domain/usecases/tasks/import_tasks_usecase.dart';
import 'package:taskflow/src/domain/usecases/users/add_user_usecase.dart';
import 'package:taskflow/src/domain/usecases/users/delete_user_usecase.dart';

import '../fakes.dart';

void main() {
  final tomorrow = DateTime.now().add(const Duration(days: 1));

  group('AddTaskUseCase', () {
    test('пустое название → ValidationFailure, в репозиторий ничего не уходит', () async {
      final repo = FakeTaskRepository();
      final result = await AddTaskUseCase(repo)(projectId: 1, title: '   ', deadline: tomorrow);
      expect(result.fold((f) => f, (_) => null), isA<ValidationFailure>());
      expect(repo.added, 0);
    });

    test('без проекта → ValidationFailure', () async {
      final result = await AddTaskUseCase(FakeTaskRepository())(projectId: null, title: 'A', deadline: tomorrow);
      expect(result.isLeft(), isTrue);
    });

    test('у исполнителя уже 3 задачи на дату → ValidationFailure', () async {
      final repo = FakeTaskRepository()..openTasksOnDate = 3;
      final result = await AddTaskUseCase(repo)(projectId: 1, title: 'A', deadline: tomorrow, assigneeId: 7);
      expect(result.isLeft(), isTrue);
      expect(repo.added, 0);
    });

    test('корректные данные → задача создаётся', () async {
      final repo = FakeTaskRepository();
      final result = await AddTaskUseCase(repo)(projectId: 1, title: 'Сделать отчёт', deadline: tomorrow);
      expect(result.isRight(), isTrue);
      expect(repo.added, 1);
    });
  });

  group('Users', () {
    test('неверный email → ValidationFailure', () async {
      final result = await AddUserUseCase(FakeUserRepository())(name: 'Аня', email: 'not-an-email');
      expect(result.fold((f) => f, (_) => null), isA<ValidationFailure>());
    });

    test('нельзя удалить пользователя с незавершёнными задачами', () async {
      final repo = FakeUserRepository()..openTasks = 2;
      final result = await DeleteUserUseCase(repo)(1);
      expect(result.isLeft(), isTrue);
      expect(repo.deleted, isFalse);
    });
  });

  test('ImportTasksUseCase: пустой список → ошибка', () async {
    final result = await ImportTasksUseCase(FakeTaskRepository())(1, const []);
    expect(result.isLeft(), isTrue);
  });
}
