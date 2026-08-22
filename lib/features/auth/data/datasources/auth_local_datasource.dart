import 'package:shared_preferences/shared_preferences.dart';
import 'package:qde_eco_bahor/core/error/failures.dart';
import 'package:qde_eco_bahor/features/auth/data/models/user_model.dart';

/// Локальное хранилище для аутентификации
abstract class AuthLocalDataSource {
  Future<void> cacheUser(UserModel user);
  Future<UserModel?> getCachedUser();
  Future<void> clearCache();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String _userKey = 'cached_user';

  AuthLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      final userJson = user.toJson();
      await sharedPreferences.setString(_userKey, userJson.toString());
    } catch (e) {
      throw CacheFailure('Ошибка сохранения пользователя: $e');
    }
  }

  @override
  Future<UserModel?> getCachedUser() async {
    try {
      final userJsonString = sharedPreferences.getString(_userKey);
      if (userJsonString == null) {
        return null;
      }
      // В реальном проекте здесь будет парсинг JSON
      // Для мокового примера возвращаем null
      return null;
    } catch (e) {
      throw CacheFailure('Ошибка получения пользователя: $e');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await sharedPreferences.remove(_userKey);
    } catch (e) {
      throw CacheFailure('Ошибка очистки кэша: $e');
    }
  }
}
