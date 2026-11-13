import '../../../domain/entities/task_entity.dart';

sealed class TasksState {
  const TasksState();
}

class TasksInitial extends TasksState {
  const TasksInitial();
}

class TasksLoading extends TasksState {
  const TasksLoading();
}

class TasksLoaded extends TasksState {
  const TasksLoaded(this.tasks);

  final List<TaskEntity> tasks;
}

class TasksEmpty extends TasksState {
  const TasksEmpty();
}

class TasksError extends TasksState {
  const TasksError(this.message);

  final String message;
}
