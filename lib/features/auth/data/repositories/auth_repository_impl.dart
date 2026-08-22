import 'package:qde_eco_bahor/core/error/failures.dart';
import 'package:qde_eco_bahor/core/network/network_info.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<UserModel> login(String email, String password) async {
    try {
      return await remoteDataSource.login(email, password);
    } on Failure catch (failure) {
      rethrow;
    } catch (e) {
      throw ServerFailure('Error: $e');
    }
  }

  @override
  Future<UserModel> register(String email, String password, String name) async {
    try {
      return await remoteDataSource.register(email, password, name);
    } on Failure catch (failure) {
      rethrow;
    } catch (e) {
      throw ServerFailure('Error: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await remoteDataSource.logout();
    } on Failure catch (failure) {
      rethrow;
    } catch (e) {
      throw ServerFailure('Error: $e');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      return await remoteDataSource.getCurrentUser();
    } on Failure catch (failure) {
      rethrow;
    } catch (e) {
      throw ServerFailure('Error: $e');
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    try {
      final user = await remoteDataSource.getCurrentUser();
      return user != null;
    } on Failure catch (failure) {
      rethrow;
    } catch (e) {
      throw ServerFailure('Неожиданная ошибка: $e');
    }
  }
}
