import 'package:dio/dio.dart';
import 'package:qde_eco_bahor/core/error/failures.dart';
import 'package:qde_eco_bahor/features/example_feature/data/models/example_model.dart';

abstract class ExampleRemoteDataSource {
  Future<List<ExampleModel>> getExampleData();
}

class ExampleRemoteDataSourceImpl implements ExampleRemoteDataSource {
  final Dio client;

  ExampleRemoteDataSourceImpl({required this.client});

  @override
  Future<List<ExampleModel>> getExampleData() async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      return [
        const ExampleModel(
          id: 1,
          title: 'Example Item 1',
          description: 'This is an example item',
        ),
        const ExampleModel(
          id: 2,
          title: 'Example Item 2',
          description: 'Another example item',
        ),
        const ExampleModel(
          id: 3,
          title: 'Example Item 3',
          description: 'Yet another example item',
        ),
      ];
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerFailure('Server error: ${e.response!.statusCode}');
      } else {
        throw NetworkFailure('Network error: ${e.message}');
      }
    } catch (e) {
      throw ServerFailure('Unexpected error: $e');
    }
  }
}
