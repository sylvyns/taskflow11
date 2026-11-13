/// Задача, полученная с сервера (ещё не сохранена в проект).
class TaskTemplateEntity {
  const TaskTemplateEntity({required this.title, required this.isCompleted});

  final String title;
  final bool isCompleted;
}
