import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../domain/entities/enums.dart';
import '../../../domain/entities/project_entity.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../domain/usecases/projects/get_projects_usecase.dart';
import '../../../domain/usecases/tasks/add_task_usecase.dart';
import '../../../domain/usecases/users/get_users_usecase.dart';
import 'task_form_state.dart';

/// Форма новой задачи: загружает проекты и людей, сохраняет задачу.
class TaskFormCubit extends Cubit<TaskFormState> {
  TaskFormCubit({
    required GetProjectsUseCase getProjects,
    required GetUsersUseCase getUsers,
    required AddTaskUseCase addTask,
  })  : _getProjects = getProjects,
        _getUsers = getUsers,
        _addTask = addTask,
        super(const TaskFormLoading());

  final GetProjectsUseCase _getProjects;
  final GetUsersUseCase _getUsers;
  final AddTaskUseCase _addTask;

  Future<void> load() async {
    emit(const TaskFormLoading());
    final projectsResult = await _getProjects();
    final usersResult = await _getUsers();
    if (isClosed) return;

    // Если хоть один запрос упал — показываем ошибку.
    final failure = projectsResult.fold<Failure?>((f) => f, (_) => null) ??
        usersResult.fold<Failure?>((f) => f, (_) => null);
    if (failure != null) {
      emit(TaskFormError(failure.message));
      return;
    }
    emit(TaskFormReady(
      projects: projectsResult.getOrElse(() => const <ProjectEntity>[]),
      users: usersResult.getOrElse(() => const <UserEntity>[]),
    ));
  }

  Future<String?> submit({
    required int? projectId,
    required String title,
    required String description,
    required TaskPriority priority,
    required DateTime deadline,
    int? assigneeId,
  }) async {
    final result = await _addTask(
      projectId: projectId,
      title: title,
      description: description,
      priority: priority,
      deadline: deadline,
      assigneeId: assigneeId,
    );
    return result.fold<String?>((failure) => failure.message, (_) => null);
  }
}
