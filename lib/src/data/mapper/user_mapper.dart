import '../../../core/database/app_database.dart';
import '../../domain/entities/user_entity.dart';

/// Model (строка БД) → Entity.
extension UserMapper on User {
  UserEntity toEntity() => UserEntity(id: id, name: name, email: email, registeredAt: registeredAt);
}
