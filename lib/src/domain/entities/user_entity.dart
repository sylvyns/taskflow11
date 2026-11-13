/// Пользователь (Entity — бизнес-объект без зависимостей от БД и API).
class UserEntity {
  const UserEntity({required this.id, required this.name, required this.email, required this.registeredAt});

  final int id;
  final String name;
  final String email;
  final DateTime registeredAt;
}
