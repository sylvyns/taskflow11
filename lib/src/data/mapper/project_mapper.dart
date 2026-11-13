import '../../../models/local_models.dart';
import '../../domain/entities/project_entity.dart';

extension ProjectMapper on ProjectWithStats {
  ProjectEntity toEntity() => ProjectEntity(
        id: project.id,
        name: project.name,
        description: project.description,
        status: project.status,
        createdAt: project.createdAt,
        endDate: project.endDate,
        totalTasks: total,
        doneTasks: done,
        cancelledTasks: cancelled,
      );
}
