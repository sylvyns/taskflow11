import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/usecases/tasks/fetch_server_tasks_usecase.dart';
import '../../../domain/usecases/tasks/import_tasks_usecase.dart';
import 'import_state.dart';

/// Импорт задач с сервера (Remote DataSource → Loading / Loaded / Empty / Error).
class ImportCubit extends Cubit<ImportState> {
  ImportCubit({required FetchServerTasksUseCase fetchServerTasks, required ImportTasksUseCase importTasks})
      : _fetchServerTasks = fetchServerTasks,
        _importTasks = importTasks,
        super(const ImportInitial());

  final FetchServerTasksUseCase _fetchServerTasks;
  final ImportTasksUseCase _importTasks;

  /// [force] = true — загрузить заново (кнопка «Повторить» / «Другие задачи»).
  Future<void> load({bool force = false}) async {
    if (state is ImportLoading) return; // запрос уже идёт
    if (!force && state is ImportLoaded) return; // данные уже есть — повторный запрос не нужен

    emit(const ImportLoading());
    final result = await _fetchServerTasks(limit: 10);
    if (isClosed) return;

    result.fold<void>(
      (failure) => emit(ImportError(failure.message)),
      (tasks) => emit(tasks.isEmpty ? const ImportEmpty() : ImportLoaded(tasks)),
    );
  }

  /// Сохраняет загруженные задачи в проект. Возвращает текст ошибки или null.
  Future<String?> saveTo(int projectId) async {
    final current = state;
    if (current is! ImportLoaded) return 'Сначала загрузите задачи';
    final result = await _importTasks(projectId, current.tasks);
    return result.fold<String?>((failure) => failure.message, (_) => null);
  }
}
