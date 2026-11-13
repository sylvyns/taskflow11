import 'package:dartz/dartz.dart' show Either, Unit;

import '../../../core/error/failures.dart';
import '../entities/project_entity.dart';

abstract class ProjectRepository {
  Future<Either<Failure, List<ProjectEntity>>> getProjects();

  Future<Either<Failure, Unit>> addProject({required String name, required String description});

  Future<Either<Failure, Unit>> deleteProject(int id);
}
