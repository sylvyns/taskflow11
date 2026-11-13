import 'package:dartz/dartz.dart' show Either, Left, Unit;

import '../../../../core/error/failures.dart';
import '../../repositories/user_repository.dart';

/// Добавление пользователя. Проверка данных — бизнес-логика, поэтому она здесь.
class AddUserUseCase {
  AddUserUseCase(this.repository);

  final UserRepository repository;

  static final RegExp _emailPattern = RegExp(r'^[\w.+\-]+@[\w\-]+(\.[\w\-]+)+$');

  Future<Either<Failure, Unit>> call({required String name, required String email}) async {
    final cleanName = name.trim();
    final cleanEmail = email.trim().toLowerCase();

    if (cleanName.isEmpty) return const Left(ValidationFailure('Введите имя'));
    if (cleanName.length > 100) return const Left(ValidationFailure('Имя длиннее 100 символов'));
    if (!_emailPattern.hasMatch(cleanEmail)) return const Left(ValidationFailure('Некорректный email'));

    return repository.addUser(name: cleanName, email: cleanEmail);
  }
}
