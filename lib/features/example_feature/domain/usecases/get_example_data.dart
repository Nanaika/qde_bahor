import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:qde_eco_bahor/core/error/failures.dart';
import 'package:qde_eco_bahor/features/example_feature/domain/entities/example_entity.dart';
import 'package:qde_eco_bahor/features/example_feature/domain/repositories/example_repository.dart';

class GetExampleData {
  final ExampleRepository repository;

  GetExampleData(this.repository);

  Future<Either<Failure, List<ExampleEntity>>> call(NoParams params) async {
    return await repository.getExampleData();
  }
}

class NoParams extends Equatable {
  @override
  List<Object> get props => [];
}
