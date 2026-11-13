import 'package:dartz/dartz.dart' show Either, Left, Unit;

import '../../../../core/error/failures.dart';
import '../../entities/enums.dart';
import '../../repositories/task_repository.dart';

/// Создание задачи. Здесь собраны бизнес-правила:
///  * у задачи должен быть проект и непустое название;
///  * дедлайн не может быть в прошлом;
///  * у исполнителя не больше [maxOpenTasksPerDay] незавершённых задач на одну дату.
class AddTaskUseCase {
  AddTaskUseCase(this.repository);

  final TaskRepository repository;

  static const int maxOpenTasksPerDay = 3;

  Future<Either<Failure, Unit>> call({
    required int? projectId,
    required String title,
    String description = '',
    TaskPriority priority = TaskPriority.medium,
    required DateTime deadline,
    int? assigneeId,
  }) async {
    final cleanTitle = title.trim();
    if (projectId == null) return const Left(ValidationFailure('Выберите проект'));
    if (cleanTitle.isEmpty) return const Left(ValidationFailure('Введите название задачи'));
    if (cleanTitle.length > 200) return const Left(ValidationFailure('Название длиннее 200 символов'));

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (deadline.isBefore(today)) return const Left(ValidationFailure('Дедлайн не может быть в прошлом'));

    if (assigneeId != null) {
      final countResult = await repository.countOpenTasksOnDate(assigneeId, deadline);
      final failure = countResult.fold<Failure?>(
        (failure) => failure,
        (count) => count >= maxOpenTasksPerDay
            ? const ValidationFailure('У исполнителя уже $maxOpenTasksPerDay задачи на эту дату')
            : null,
      );
      if (failure != null) return Left(failure);
    }

    return repository.addTask(
      projectId: projectId,
      title: cleanTitle,
      description: description.trim(),
      priority: priority,
      deadline: deadline,
      assigneeId: assigneeId,
    );
  }
}
