import 'package:dartz/dartz.dart' show Either, Left;

import '../../../../core/error/failures.dart';
import '../../entities/task_template_entity.dart';
import '../../repositories/task_repository.dart';

/// Сохранение загруженных с сервера задач в выбранный проект.
class ImportTasksUseCase {
  ImportTasksUseCase(this.repository);

  final TaskRepository repository;

  Future<Either<Failure, int>> call(int projectId, List<TaskTemplateEntity> templates) async {
    if (templates.isEmpty) return const Left(ValidationFailure('Нет задач для импорта'));
    return repository.importTasks(projectId, templates);
  }
}
