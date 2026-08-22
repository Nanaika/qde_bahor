import 'package:qde_eco_bahor/core/error/failures.dart';
import 'package:qde_eco_bahor/features/auth/data/models/user_model.dart';

/// Моковый источник данных для аутентификации
/// В реальном проекте здесь будет API вызов
abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> register(String email, String password, String name);
  Future<void> logout();
  Future<UserModel?> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  // Моковое хранилище для демонстрации
  UserModel? _currentUser;

  @override
  Future<UserModel> login(String email, String password) async {
    // Имитация сетевой задержки
    await Future.delayed(const Duration(seconds: 1));

    // Моковая валидация
    if (email.isEmpty || password.isEmpty) {
      throw const ValidationFailure('Email и пароль обязательны');
    }

    if (password.length < 6) {
      throw const ValidationFailure('Пароль должен содержать минимум 6 символов');
    }

    // Моковый пользователь
    _currentUser = UserModel(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      name: email.split('@')[0],
      avatarUrl: null,
    );

    return _currentUser!;
  }

  @override
  Future<UserModel> register(String email, String password, String name) async {
    // Имитация сетевой задержки
    await Future.delayed(const Duration(seconds: 1));

    // Моковая валидация
    if (email.isEmpty || password.isEmpty || name.isEmpty) {
      throw const ValidationFailure('Все поля обязательны');
    }

    if (password.length < 6) {
      throw const ValidationFailure('Пароль должен содержать минимум 6 символов');
    }

    // Моковый пользователь
    _currentUser = UserModel(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      name: name,
      avatarUrl: null,
    );

    return _currentUser!;
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = null;
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _currentUser;
  }
}
