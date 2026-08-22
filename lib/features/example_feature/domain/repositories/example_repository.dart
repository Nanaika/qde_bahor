import 'package:dartz/dartz.dart';
import 'package:qde_eco_bahor/core/error/failures.dart';
import 'package:qde_eco_bahor/features/example_feature/domain/entities/example_entity.dart';

abstract class ExampleRepository {
  Future<Either<Failure, List<ExampleEntity>>> getExampleData();
}
