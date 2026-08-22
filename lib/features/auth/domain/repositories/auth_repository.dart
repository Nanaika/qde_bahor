import 'package:dartz/dartz.dart';
import 'package:qde_eco_bahor/core/error/failures.dart';
import 'package:qde_eco_bahor/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> login(String email, String password);
  Future<Either<Failure, UserEntity>> register(String email, String password, String name);
  Future<Either<Failure, Unit>> logout();
  Future<Either<Failure, UserEntity?>> getCurrentUser();
  Future<Either<Failure, bool>> isAuthenticated();
}
