import 'package:shared_preferences/shared_preferences.dart';

/// НОВАЯ ФУНКЦИЯ — Local DataSource избранного.
/// id избранных задач хранятся в SharedPreferences и не пропадают после перезапуска.
abstract class FavoritesLocalDataSource {
  Set<int> getFavoriteIds();

  /// Возвращает true, если задача добавлена в избранное.
  Future<bool> toggle(int taskId);

  Future<void> remove(int taskId);
}

class FavoritesLocalDataSourceImpl implements FavoritesLocalDataSource {
  FavoritesLocalDataSourceImpl(this._prefs);

  final SharedPreferences _prefs;

  static const String _key = 'favorite_task_ids';

  @override
  Set<int> getFavoriteIds() {
    final stored = _prefs.getStringList(_key) ?? const <String>[];
    return stored.map(int.tryParse).whereType<int>().toSet();
  }

  @override
  Future<bool> toggle(int taskId) async {
    final ids = getFavoriteIds();
    final added = ids.add(taskId);
    if (!added) ids.remove(taskId);
    await _save(ids);
    return added;
  }

  @override
  Future<void> remove(int taskId) async {
    final ids = getFavoriteIds()..remove(taskId);
    await _save(ids);
  }

  Future<void> _save(Set<int> ids) => _prefs.setStringList(_key, ids.map((id) => '$id').toList());
}
