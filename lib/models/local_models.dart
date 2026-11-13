import '../core/database/app_database.dart';

/// Модели Local DataSource: результаты JOIN-запросов к SQLite.
/// Сами строки таблиц (User, Project, Task) генерирует Drift.

/// Задача + её проект + исполнитель.
class TaskWithRelations {
  const TaskWithRelations({required this.task, required this.project, this.assignee});

  final Task task;
  final Project project;
  final User? assignee;
}

/// Проект + счётчики задач.
class ProjectWithStats {
  const ProjectWithStats({required this.project, required this.total, required this.done, required this.cancelled});

  final Project project;
  final int total;
  final int done;
  final int cancelled;
}
