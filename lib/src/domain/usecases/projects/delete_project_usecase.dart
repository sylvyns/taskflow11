import 'package:dartz/dartz.dart' show Either, Unit;

import '../../../../core/error/failures.dart';
import '../../repositories/project_repository.dart';

class DeleteProjectUseCase {
  DeleteProjectUseCase(this.repository);

  final ProjectRepository repository;

  Future<Either<Failure, Unit>> call(int projectId) => repository.deleteProject(projectId);
}
