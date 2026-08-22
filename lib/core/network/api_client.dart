import 'package:dio/dio.dart';
import 'package:qde_eco_bahor/core/error/failures.dart';

class ApiClient {
  final Dio dio;

  ApiClient(this.dio) {
    dio.options = BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          if (error.response != null) {
            final statusCode = error.response!.statusCode;
            if (statusCode != null) {
              if (statusCode >= 500) {
                return handler.reject(
                  DioException(
                    requestOptions: error.requestOptions,
                    error: const ServerFailure('Server error'),
                    response: error.response,
                  ),
                );
              } else if (statusCode == 404) {
                return handler.reject(
                  DioException(
                    requestOptions: error.requestOptions,
                    error: const ServerFailure('Resource not found'),
                    response: error.response,
                  ),
                );
              }
            }
          } else if (error.type == DioExceptionType.connectionTimeout ||
              error.type == DioExceptionType.receiveTimeout ||
              error.type == DioExceptionType.connectionError) {
            return handler.reject(
              DioException(
                requestOptions: error.requestOptions,
                error: const NetworkFailure('Connection timeout'),
              ),
            );
          }
          return handler.next(error);
        },
      ),
    );
  }
}
