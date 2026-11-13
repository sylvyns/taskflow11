import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/enums.dart';
import '../../../domain/entities/task_entity.dart';
import '../../../domain/entities/task_filter.dart';
import '../../../domain/usecases/tasks/change_task_status_usecase.dart';
import '../../../domain/usecases/tasks/delete_task_usecase.dart';
import '../../../domain/usecases/tasks/get_tasks_usecase.dart';
import '../../../domain/usecases/tasks/toggle_favorite_usecase.dart';
import 'tasks_state.dart';

class TasksCubit extends Cubit<TasksState> {
  TasksCubit({
    required GetTasksUseCase getTasks,
    required ChangeTaskStatusUseCase changeStatus,
    required DeleteTaskUseCase deleteTask,
    required ToggleFavoriteUseCase toggleFavorite,
  })  : _getTasks = getTasks,
        _changeStatus = changeStatus,
        _deleteTask = deleteTask,
        _toggleFavorite = toggleFavorite,
        super(const TasksInitial());

  final GetTasksUseCase _getTasks;
  final ChangeTaskStatusUseCase _changeStatus;
  final DeleteTaskUseCase _deleteTask;
  final ToggleFavoriteUseCase _toggleFavorite;

  TaskFilter _filter = const TaskFilter();
  TaskFilter get filter => _filter;

  Timer? _debounce;

  /// Номер последнего запроса: ответы на устаревшие запросы игнорируются.
  int _requestId = 0;

  /// Первая загрузка. [projectId] — показать задачи только одного проекта.
  Future<void> init({int? projectId}) {
    _filter = TaskFilter(projectId: projectId);
    return load();
  }

  Future<void> load({bool showLoader = true}) async {
    final requestId = ++_requestId;
    if (showLoader) emit(const TasksLoading());

    final result = await _getTasks(_filter);
    if (isClosed || requestId != _requestId) return;

    result.fold<void>(
      (failure) => emit(TasksError(failure.message)),
      (tasks) => emit(tasks.isEmpty ? const TasksEmpty() : TasksLoaded(tasks)),
    );
  }

  // ---------------- Фильтры ----------------

  /// Поиск с debounce: запрос уходит через 400 мс после последнего ввода.
  void setSearch(String text) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () => _applyFilter(_filter.copyWith(search: text.trim())));
  }

  void setStatus(TaskStatus? status) => _applyFilter(_filter.copyWith(status: status));

  void toggleFavoritesOnly() => _applyFilter(_filter.copyWith(favoritesOnly: !_filter.favoritesOnly));

  void _applyFilter(TaskFilter newFilter) {
    if (newFilter == _filter) return; // тот же фильтр — повторный запрос не нужен
    _filter = newFilter;
    load();
  }

  // ---------------- Действия ----------------

  Future<String?> changeStatus(TaskEntity task, TaskStatus status) async {
    if (task.status == status) return null;
    final result = await _changeStatus(task.id, status);
    return result.fold<String?>((failure) => failure.message, (_) {
      load(showLoader: false);
      return null;
    });
  }

  Future<String?> deleteTask(TaskEntity task) async {
    final result = await _deleteTask(task.id);
    return result.fold<String?>((failure) => failure.message, (_) {
      load(showLoader: false);
      return null;
    });
  }

  /// Избранное меняем прямо в текущем списке — без нового запроса к БД.
  Future<String?> toggleFavorite(TaskEntity task) async {
    final result = await _toggleFavorite(task.id);
    if (isClosed) return null;
    return result.fold<String?>((failure) => failure.message, (isFavorite) {
      final current = state;
      if (current is TasksLoaded) {
        final updated = current.tasks
            .map((t) => t.id == task.id ? t.copyWith(isFavorite: isFavorite) : t)
            .where((t) => !_filter.favoritesOnly || t.isFavorite)
            .toList();
        emit(updated.isEmpty ? const TasksEmpty() : TasksLoaded(updated));
      }
      return null;
    });
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
