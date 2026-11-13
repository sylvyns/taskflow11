import 'dart:io';

import 'package:dio/dio.dart';

import '../error/exceptions.dart';

/// Обёртка над Dio. Только здесь проект знает про Dio:
/// DataSource вызывает [get], а ошибки Dio превращаются в наши исключения.
class RestClient {
  RestClient(this._dio);

  final Dio _dio;

  Future<dynamic> get(String path, {Map<String, dynamic>? query}) async {
    try {
      final response = await _dio.get<dynamic>(path, queryParameters: query);
      return response.data;
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  AppException _mapDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return const NetworkException();
      case DioExceptionType.badResponse:
        final code = e.response?.statusCode ?? 0;
        if (code == 400) return const BadRequestException();
        if (code == 401 || code == 403) return const UnauthorizedException();
        if (code == 404) return const NotFoundException('Данные на сервере не найдены');
        return ServerException(code);
      case DioExceptionType.unknown:
        if (e.error is SocketException) return const NetworkException();
        return const UnknownException();
      default:
        return const UnknownException();
    }
  }
}
