import '../../../domain/entities/project_entity.dart';

sealed class ProjectsState {
  const ProjectsState();
}

class ProjectsInitial extends ProjectsState {
  const ProjectsInitial();
}

class ProjectsLoading extends ProjectsState {
  const ProjectsLoading();
}

class ProjectsLoaded extends ProjectsState {
  const ProjectsLoaded(this.projects);

  final List<ProjectEntity> projects;
}

class ProjectsEmpty extends ProjectsState {
  const ProjectsEmpty();
}

class ProjectsError extends ProjectsState {
  const ProjectsError(this.message);

  final String message;
}
