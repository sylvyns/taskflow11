import 'dart:developer' as developer;

import 'package:dartz/dartz.dart' show Either, Left, Right;

import 'exceptions.dart';
import 'failures.dart';

/// ЦЕНТРАЛИЗОВАННАЯ обработка ошибок.
///
/// Все репозитории вызывают DataSource через [safeCall], поэтому правило
/// «исключение → Failure» описано в одном месте.
class ErrorHandler {
  ErrorHandler._();

  static Failure toFailure(Object error) {
    return switch (error) {
      NetworkException() => const NetworkFailure(),
      ServerException() => const ServerFailure(),
      UnauthorizedException() => const UnauthorizedFailure(),
      BadRequestException() => const ValidationFailure(),
      ValidationException(:final message) => ValidationFailure(message ?? 'Проверьте введённые данные'),
      NotFoundException(:final message) => NotFoundFailure(message ?? 'Данные не найдены'),
      _ => const UnknownFailure(),
    };
  }
}

/// Выполняет [action] и заворачивает результат в Either:
/// Right(данные) — успех, Left(Failure) — ошибка.
Future<Either<Failure, T>> safeCall<T>(Future<T> Function() action) async {
  try {
    return Right(await action());
  } catch (error, stackTrace) {
    // Технические детали — только в лог для разработчика.
    developer.log('Ошибка в data-слое', name: 'TaskFlow', error: error, stackTrace: stackTrace);
    return Left(ErrorHandler.toFailure(error));
  }
}
