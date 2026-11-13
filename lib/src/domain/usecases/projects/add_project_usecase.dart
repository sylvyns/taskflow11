import 'package:dartz/dartz.dart' show Either, Left, Unit;

import '../../../../core/error/failures.dart';
import '../../repositories/project_repository.dart';

class AddProjectUseCase {
  AddProjectUseCase(this.repository);

  final ProjectRepository repository;

  Future<Either<Failure, Unit>> call({required String name, String description = ''}) async {
    final cleanName = name.trim();
    if (cleanName.isEmpty) return const Left(ValidationFailure('Введите название проекта'));
    if (cleanName.length > 120) return const Left(ValidationFailure('Название длиннее 120 символов'));
    return repository.addProject(name: cleanName, description: description.trim());
  }
}
