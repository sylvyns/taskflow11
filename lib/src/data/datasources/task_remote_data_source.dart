import 'dart:math';

import '../../../constants/api_constants.dart';
import '../../../core/error/exceptions.dart';
import '../../../core/rest_client/rest_client.dart';
import '../../../models/remote_task_model.dart';

/// Remote DataSource — загрузка задач с сервера.
abstract class TaskRemoteDataSource {
  Future<List<RemoteTaskModel>> fetchTasks({int limit = 10});
}

class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  TaskRemoteDataSourceImpl(this._client);

  final RestClient _client;
  final Random _random = Random();

  @override
  Future<List<RemoteTaskModel>> fetchTasks({int limit = 10}) async {
    final data = await _client.get(
      ApiConstants.todos,
      // Случайное смещение — чтобы каждый раз приходили разные задачи.
      query: {'_start': _random.nextInt(190), '_limit': limit},
    );
    if (data is! List) throw const ServerException(); // неожиданный формат ответа
    return data.whereType<Map<String, dynamic>>().map(RemoteTaskModel.fromJson).toList();
  }
}
