import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow/core/error/error_handler.dart';
import 'package:taskflow/core/error/exceptions.dart';
import 'package:taskflow/core/error/failures.dart';

void main() {
  group('ErrorHandler: исключение → Failure', () {
    test('нет интернета → NetworkFailure', () {
      expect(ErrorHandler.toFailure(const NetworkException()), isA<NetworkFailure>());
    });

    test('500 → ServerFailure', () {
      expect(ErrorHandler.toFailure(const ServerException(500)), isA<ServerFailure>());
    });

    test('401 → UnauthorizedFailure', () {
      expect(ErrorHandler.toFailure(const UnauthorizedException()), isA<UnauthorizedFailure>());
    });

    test('400 → ValidationFailure', () {
      expect(ErrorHandler.toFailure(const BadRequestException()), isA<ValidationFailure>());
    });

    test('неизвестная ошибка → UnknownFailure без технического текста', () {
      final failure = ErrorHandler.toFailure(StateError('Bad state: secret stack trace'));
      expect(failure, isA<UnknownFailure>());
      expect(failure.message.contains('Bad state'), isFalse);
    });
  });

  test('safeCall заворачивает исключение в Left', () async {
    final result = await safeCall<int>(() async => throw const NetworkException());
    expect(result.isLeft(), isTrue);
    result.fold((f) => expect(f, isA<NetworkFailure>()), (_) => fail('ожидалась ошибка'));
  });
}
