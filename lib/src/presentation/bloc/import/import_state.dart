import '../../../domain/entities/task_template_entity.dart';

sealed class ImportState {
  const ImportState();
}

class ImportInitial extends ImportState {
  const ImportInitial();
}

class ImportLoading extends ImportState {
  const ImportLoading();
}

class ImportLoaded extends ImportState {
  const ImportLoaded(this.tasks);

  final List<TaskTemplateEntity> tasks;
}

class ImportEmpty extends ImportState {
  const ImportEmpty();
}

class ImportError extends ImportState {
  const ImportError(this.message);

  final String message;
}
