import 'package:dartz/dartz.dart';
import 'package:qde_eco_bahor/core/error/failures.dart';
import 'package:qde_eco_bahor/core/network/network_info.dart';
import 'package:qde_eco_bahor/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:qde_eco_bahor/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:qde_eco_bahor/features/auth/domain/entities/user_entity.dart';
import 'package:qde_eco_bahor/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, UserEntity>> login(String email, String password) async {
    try {
      final userModel = await remoteDataSource.login(email, password);
      await localDataSource.cacheUser(userModel);
      return Right(userModel.toEntity());
    } on ValidationFailure catch (failure) {
      return Left(failure);
    } on ServerFailure catch (failure) {
      return Left(failure);
    } on NetworkFailure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Неожиданная ошибка: $e'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> register(String email, String password, String name) async {
    try {
      final userModel = await remoteDataSource.register(email, password, name);
      await localDataSource.cacheUser(userModel);
      return Right(userModel.toEntity());
    } on ValidationFailure catch (failure) {
      return Left(failure);
    } on ServerFailure catch (failure) {
      return Left(failure);
    } on NetworkFailure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Неожиданная ошибка: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    try {
      await remoteDataSource.logout();
      await localDataSource.clearCache();
      return const Right(unit);
    } on ServerFailure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Неожиданная ошибка: $e'));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final userModel = await remoteDataSource.getCurrentUser();
      if (userModel != null) {
        return Right(userModel.toEntity());
      }
      return const Right(null);
    } on ServerFailure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Неожиданная ошибка: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> isAuthenticated() async {
    try {
      final user = await remoteDataSource.getCurrentUser();
      return Right(user != null);
    } on ServerFailure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Неожиданная ошибка: $e'));
    }
  }
}
