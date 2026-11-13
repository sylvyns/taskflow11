import 'package:dio/dio.dart';

/// Какую ошибку сымитировать (для демонстрации обработки ошибок).
enum SimulatedError {
  none('Без ошибок (реальный запрос)'),
  noInternet('Нет интернета'),
  badRequest('400 — неверный запрос'),
  unauthorized('401 — не авторизован'),
  server('500 — ошибка сервера'),
  empty('Пустой ответ');

  const SimulatedError(this.label);

  final String label;
}

/// Interceptor Dio, который по выбору подменяет ответ сервера ошибкой.
/// Нужен только чтобы показать преподавателю все состояния экрана
/// без настоящего «падения» сервера.
class ErrorSimulationInterceptor extends Interceptor {
  SimulatedError mode = SimulatedError.none;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    switch (mode) {
      case SimulatedError.none:
        handler.next(options);
      case SimulatedError.noInternet:
        handler.reject(DioException(requestOptions: options, type: DioExceptionType.connectionError));
      case SimulatedError.badRequest:
        handler.reject(_httpError(options, 400));
      case SimulatedError.unauthorized:
        handler.reject(_httpError(options, 401));
      case SimulatedError.server:
        handler.reject(_httpError(options, 500));
      case SimulatedError.empty:
        handler.resolve(Response<dynamic>(requestOptions: options, statusCode: 200, data: <dynamic>[]));
    }
  }

  DioException _httpError(RequestOptions options, int code) => DioException(
        requestOptions: options,
        type: DioExceptionType.badResponse,
        response: Response<dynamic>(requestOptions: options, statusCode: code),
      );
}
