import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/error/exceptions.dart';
import '../../domain/entities/enums.dart';

/// Local DataSource пользователей — запросы к SQLite (Drift).
abstract class UserLocalDataSource {
  Future<List<User>> getUsers();

  Future<void> addUser({required String name, required String email});

  Future<void> deleteUser(int id);

  Future<int> countOpenTasks(int userId);
}

class UserLocalDataSourceImpl implements UserLocalDataSource {
  UserLocalDataSourceImpl(this._db);

  final AppDatabase _db;

  @override
  Future<List<User>> getUsers() {
    final query = _db.select(_db.users)..orderBy([(u) => OrderingTerm.asc(u.name)]);
    return query.get();
  }

  @override
  Future<void> addUser({required String name, required String email}) async {
    final existing = await (_db.select(_db.users)..where((u) => u.email.equals(email))).getSingleOrNull();
    if (existing != null) {
      throw const ValidationException('Пользователь с таким email уже существует');
    }
    await _db.into(_db.users).insert(
          UsersCompanion.insert(name: name, email: email, registeredAt: Value(DateTime.now())),
        );
  }

  @override
  Future<void> deleteUser(int id) async {
    final deleted = await (_db.delete(_db.users)..where((u) => u.id.equals(id))).go();
    if (deleted == 0) throw const NotFoundException('Пользователь не найден');
  }

  @override
  Future<int> countOpenTasks(int userId) async {
    final t = _db.tasks;
    final count = t.id.count();
    final query = _db.selectOnly(t)
      ..addColumns([count])
      ..where(
        t.assigneeId.equals(userId) &
            t.deletedAt.isNull() &
            t.status.isIn([TaskStatus.todo.name, TaskStatus.inProgress.name]),
      );
    return await query.map((row) => row.read(count)).getSingle() ?? 0;
  }
}
