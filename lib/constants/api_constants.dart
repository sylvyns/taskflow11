/// Настройки сервера, с которого импортируются задачи.
class ApiConstants {
  ApiConstants._();

  /// Бесплатный тестовый REST API.
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';

  /// GET /todos — список задач.
  static const String todos = '/todos';

  static const Duration timeout = Duration(seconds: 10);
}
