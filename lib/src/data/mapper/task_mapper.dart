import '../../../models/local_models.dart';
import '../../../models/remote_task_model.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/entities/task_template_entity.dart';

/// Локальная модель (JOIN из SQLite) → Entity.
extension TaskMapper on TaskWithRelations {
  TaskEntity toEntity({bool isFavorite = false}) => TaskEntity(
        id: task.id,
        title: task.title,
        description: task.description,
        projectId: project.id,
        projectName: project.name,
        assigneeId: assignee?.id,
        assigneeName: assignee?.name,
        priority: task.priority,
        status: task.status,
        deadline: task.deadline,
        createdAt: task.createdAt,
        isFavorite: isFavorite,
      );
}

/// Модель API → Entity.
extension RemoteTaskMapper on RemoteTaskModel {
  TaskTemplateEntity toEntity() => TaskTemplateEntity(title: title.trim(), isCompleted: completed);
}
