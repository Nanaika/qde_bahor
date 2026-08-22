import 'package:qde_eco_bahor/features/auth/data/models/user_model.dart';

abstract class AuthRepository {
  Future<UserModel> login(String email, String password);
  Future<UserModel> register(String email, String password, String name);
  Future<void> logout();
  Future<UserModel?> getCurrentUser();
  Future<bool> isAuthenticated();
}
