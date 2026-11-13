import 'package:dartz/dartz.dart' show Either;

import '../../../../core/error/failures.dart';
import '../../repositories/task_repository.dart';

/// НОВАЯ ФУНКЦИЯ: избранные задачи (сохраняются локально).
class ToggleFavoriteUseCase {
  ToggleFavoriteUseCase(this.repository);

  final TaskRepository repository;

  /// Возвращает true, если задача теперь в избранном.
  Future<Either<Failure, bool>> call(int taskId) => repository.toggleFavorite(taskId);
}
