import 'enums.dart';

/// Проект вместе со счётчиками задач.
class ProjectEntity {
  const ProjectEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.status,
    required this.createdAt,
    this.endDate,
    this.totalTasks = 0,
    this.doneTasks = 0,
    this.cancelledTasks = 0,
  });

  final int id;
  final String name;
  final String description;
  final ProjectStatus status;
  final DateTime createdAt;
  final DateTime? endDate;
  final int totalTasks;
  final int doneTasks;
  final int cancelledTasks;

  /// Доля выполнения 0..1 (отменённые задачи не учитываются) — бизнес-правило.
  double get progress {
    final relevant = totalTasks - cancelledTasks;
    return relevant <= 0 ? 0 : doneTasks / relevant;
  }
}
