/// Иерархия ошибок, которую видят Domain и Presentation.
///
/// У каждой ошибки есть понятное пользователю сообщение [message] —
/// технический текст исключения пользователю никогда не показывается.
sealed class Failure {
  const Failure(this.message);

  final String message;
}

/// Нет интернета.
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Нет подключения к интернету. Проверьте сеть и попробуйте снова']);
}

/// Ошибка сервера (500).
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Сервер временно недоступен. Попробуйте позже']);
}

/// Ошибка авторизации (401).
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([super.message = 'Нет доступа: требуется авторизация']);
}

/// Неверный запрос (400) или неверные данные в форме.
class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Неверный запрос. Проверьте данные']);
}

/// Запись не найдена.
class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Данные не найдены']);
}

/// Неизвестная ошибка.
class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Что-то пошло не так. Попробуйте ещё раз']);
}
