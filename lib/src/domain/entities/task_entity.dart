import 'enums.dart';

/// Задача. В UI попадает только она — не модель БД и не модель API.
class TaskEntity {
  const TaskEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.projectId,
    required this.projectName,
    this.assigneeId,
    this.assigneeName,
    required this.priority,
    required this.status,
    required this.deadline,
    required this.createdAt,
    this.isFavorite = false,
  });

  final int id;
  final String title;
  final String description;
  final int projectId;
  final String projectName;
  final int? assigneeId;
  final String? assigneeName;
  final TaskPriority priority;
  final TaskStatus status;
  final DateTime deadline;
  final DateTime createdAt;

  /// Новая функция: задача в избранном.
  final bool isFavorite;

  /// Просрочена: не завершена и дедлайн уже прошёл.
  bool get isOverdue => status.isOpen && deadline.isBefore(DateTime.now());

  TaskEntity copyWith({bool? isFavorite}) => TaskEntity(
        id: id,
        title: title,
        description: description,
        projectId: projectId,
        projectName: projectName,
        assigneeId: assigneeId,
        assigneeName: assigneeName,
        priority: priority,
        status: status,
        deadline: deadline,
        createdAt: createdAt,
        isFavorite: isFavorite ?? this.isFavorite,
      );
}
