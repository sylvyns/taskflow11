import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/usecases/projects/add_project_usecase.dart';
import '../../../domain/usecases/projects/delete_project_usecase.dart';
import '../../../domain/usecases/projects/get_projects_usecase.dart';
import 'projects_state.dart';

class ProjectsCubit extends Cubit<ProjectsState> {
  ProjectsCubit({
    required GetProjectsUseCase getProjects,
    required AddProjectUseCase addProject,
    required DeleteProjectUseCase deleteProject,
  })  : _getProjects = getProjects,
        _addProject = addProject,
        _deleteProject = deleteProject,
        super(const ProjectsInitial());

  final GetProjectsUseCase _getProjects;
  final AddProjectUseCase _addProject;
  final DeleteProjectUseCase _deleteProject;

  bool _isLoading = false;

  Future<void> load({bool showLoader = true}) async {
    if (_isLoading) return; // защита от повторного запроса
    _isLoading = true;
    if (showLoader) emit(const ProjectsLoading());

    final result = await _getProjects();
    _isLoading = false;
    if (isClosed) return;

    result.fold<void>(
      (failure) => emit(ProjectsError(failure.message)),
      (projects) => emit(projects.isEmpty ? const ProjectsEmpty() : ProjectsLoaded(projects)),
    );
  }

  Future<String?> addProject({required String name, required String description}) async {
    final result = await _addProject(name: name, description: description);
    return result.fold<String?>((failure) => failure.message, (_) {
      load(showLoader: false);
      return null;
    });
  }

  Future<String?> deleteProject(int id) async {
    final result = await _deleteProject(id);
    return result.fold<String?>((failure) => failure.message, (_) {
      load(showLoader: false);
      return null;
    });
  }
}
