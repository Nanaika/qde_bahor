import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qde_eco_bahor/core/utils/app_constants.dart';

import '../../../../core/services/telegram_service.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);

  Future<UserModel> register(String email, String password, String name);

  Future<void> logout();

  Future<UserModel?> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  UserModel? _currentUser;
  final firebaseAuth = FirebaseAuth.instance;
  final db = FirebaseFirestore.instance;

  @override
  Future<UserModel> login(String email, String password) async {
    return _currentUser!;
  }

  @override
  Future<UserModel> register(String email, String password, String name) async {
    return _currentUser!;
  }

  @override
  Future<void> logout() async {
    _currentUser = null;
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    // 1. Анонимный вход в Firebase Auth
    final userCredential = await firebaseAuth.signInAnonymously();
    final uid = userCredential.user?.uid;

    // 2. Сбор данных из Telegram WebApp
    final tgId = TelegramService.userId?.toString() ?? '123456789';
    final name = TelegramService.firstName ?? 'Test name';
    final username = TelegramService.username ?? 'testUserName';

    // 3. Запись / обновление профиля в Firestore
    final userDocRef = db.collection(AppConstants.users).doc(tgId);
    final docSnap = await userDocRef.get();

    if (!docSnap.exists) {
      final newUser = UserModel(
        id: tgId,
        userName: username,
        name: name,
        company: '',
        number: '',
        isModerated: false,
        authUid: uid ?? '',
      );

      await userDocRef.set(newUser.toJson());
    }

    return UserModel(
      id: tgId,
      name: name,
      userName: username,
      company: '',
      number: '',
      authUid: uid ?? '',
    );
  }
}
