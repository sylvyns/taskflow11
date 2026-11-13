/// Исключения DATA-слоя.
///
/// Их бросают только DataSource'ы. Наружу (в Domain и UI) они не выходят:
/// репозиторий перехватывает их и превращает в [Failure] (см. error_handler.dart).
sealed class AppException implements Exception {
  const AppException([this.message]);

  final String? message;
}

/// Нет интернета / таймаут.
class NetworkException extends AppException {
  const NetworkException();
}

/// Сервер ответил 5xx.
class ServerException extends AppException {
  const ServerException([this.statusCode]);

  final int? statusCode;
}

/// Сервер ответил 401 / 403.
class UnauthorizedException extends AppException {
  const UnauthorizedException();
}

/// Сервер ответил 400 — неверный запрос.
class BadRequestException extends AppException {
  const BadRequestException();
}

/// Локальная проверка данных не прошла (например, email уже занят).
class ValidationException extends AppException {
  const ValidationException(String message) : super(message);
}

/// Запись не найдена (в БД или на сервере — 404).
class NotFoundException extends AppException {
  const NotFoundException(String message) : super(message);
}

/// Любая другая ошибка.
class UnknownException extends AppException {
  const UnknownException();
}
