import 'package:dartz/dartz.dart' show Either;

import '../../../../core/error/failures.dart';
import '../../entities/project_entity.dart';
import '../../repositories/project_repository.dart';

class GetProjectsUseCase {
  GetProjectsUseCase(this.repository);

  final ProjectRepository repository;

  Future<Either<Failure, List<ProjectEntity>>> call() => repository.getProjects();
}
