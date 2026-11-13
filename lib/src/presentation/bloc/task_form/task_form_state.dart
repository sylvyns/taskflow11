import '../../../domain/entities/project_entity.dart';
import '../../../domain/entities/user_entity.dart';

sealed class TaskFormState {
  const TaskFormState();
}

class TaskFormLoading extends TaskFormState {
  const TaskFormLoading();
}

/// Справочники для формы загружены.
class TaskFormReady extends TaskFormState {
  const TaskFormReady({required this.projects, required this.users});

  final List<ProjectEntity> projects;
  final List<UserEntity> users;
}

class TaskFormError extends TaskFormState {
  const TaskFormError(this.message);

  final String message;
}
