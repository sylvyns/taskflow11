import 'enums.dart';

/// Параметры выборки задач: проект, статус, поиск, «только избранное».
class TaskFilter {
  const TaskFilter({this.projectId, this.status, this.search = '', this.favoritesOnly = false});

  final int? projectId;
  final TaskStatus? status;
  final String search;
  final bool favoritesOnly;

  static const Object _unset = Object();

  TaskFilter copyWith({Object? status = _unset, String? search, bool? favoritesOnly}) => TaskFilter(
        projectId: projectId,
        status: identical(status, _unset) ? this.status : status as TaskStatus?,
        search: search ?? this.search,
        favoritesOnly: favoritesOnly ?? this.favoritesOnly,
      );

  /// Сравнение нужно, чтобы не делать повторный запрос с тем же фильтром.
  @override
  bool operator ==(Object other) =>
      other is TaskFilter &&
      other.projectId == projectId &&
      other.status == status &&
      other.search == search &&
      other.favoritesOnly == favoritesOnly;

  @override
  int get hashCode => Object.hash(projectId, status, search, favoritesOnly);
}
