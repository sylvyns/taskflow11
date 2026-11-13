import 'package:dartz/dartz.dart' show Either, Unit, unit;

import '../../../core/error/error_handler.dart';
import '../../../core/error/failures.dart';
import '../../domain/entities/project_entity.dart';
import '../../domain/repositories/project_repository.dart';
import '../datasources/project_local_data_source.dart';
import '../mapper/project_mapper.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  ProjectRepositoryImpl(this.localDataSource);

  final ProjectLocalDataSource localDataSource;

  @override
  Future<Either<Failure, List<ProjectEntity>>> getProjects() => safeCall(() async {
        final projects = await localDataSource.getProjects();
        return projects.map((p) => p.toEntity()).toList();
      });

  @override
  Future<Either<Failure, Unit>> addProject({required String name, required String description}) =>
      safeCall(() async {
        await localDataSource.addProject(name: name, description: description);
        return unit;
      });

  @override
  Future<Either<Failure, Unit>> deleteProject(int id) => safeCall(() async {
        await localDataSource.deleteProject(id);
        return unit;
      });
}
