import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qde_eco_bahor/core/utils/app_constants.dart';

import '../../auth/data/models/user_model.dart';
import 'users_event.dart';
import 'users_state.dart';

class UsersBloc extends Bloc<UsersEvent, UsersState> {
  final FirebaseFirestore _firestore;

  UsersBloc({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        super(const UsersInitialState()) {
    on<FetchAllUsersEvent>(_onFetchAllUsers);
    on<UpdateUserRoleEvent>(_onUpdateUserRole);
    on<UpdateUserModerationEvent>(_onUpdateUserModeration);
  }

  Future<void> _onFetchAllUsers(
    FetchAllUsersEvent event,
    Emitter<UsersState> emit,
  ) async {
    emit(const UsersLoadingState());
    try {
      final querySnapshot = await _firestore.collection(AppConstants.users).get();

      final users = querySnapshot.docs.map((doc) => UserModel.fromJson(doc.data())).toList();

      emit(UsersLoadedState(users));
    } catch (e) {
      emit(UsersErrorState(e.toString()));
    }
  }

  Future<void> _onUpdateUserRole(
    UpdateUserRoleEvent event,
    Emitter<UsersState> emit,
  ) async {
    if (state is! UsersLoadedState) return;
    final currentState = state as UsersLoadedState;
    emit(UsersLoadedState(currentState.users, isUpdating: true));
    try {
      // 1. Обновляем документ в Firestore
      await _firestore.collection(AppConstants.users).doc(event.userId).update({
        'userType': event.userType.name,
      });

      // 2. Локально обновляем список в state
      final updatedUsers = currentState.users.map((user) {
        if (user.id == event.userId) {
          return UserModel(
            id: user.id,
            userName: user.userName,
            name: user.name,
            company: user.company,
            number: user.number,
            isModerated: user.isModerated,
            createdAt: user.createdAt,
            userType: event.userType,
          );
        }
        return user;
      }).toList();

      emit(UsersLoadedState(updatedUsers, isUpdating: false));
    } catch (e) {
      emit(UsersErrorState('Failed to update role: $e'));
    }
  }

  Future<void> _onUpdateUserModeration(
    UpdateUserModerationEvent event,
    Emitter<UsersState> emit,
  ) async {
    if (state is! UsersLoadedState) return;
    final currentState = state as UsersLoadedState;
    emit(UsersLoadedState(currentState.users, isUpdating: true));
    try {
      // 1. Создаем батч
      final batch = _firestore.batch();

      // Ссылка на документ в основной коллекции пользователей
      final userRef = _firestore.collection(AppConstants.users).doc(event.userId);

      // Ссылка на документ в коллекции модерации
      final moderationRef = _firestore.collection(AppConstants.moderateUsers).doc(event.userId);

      // 2. Добавляем операции в батч
      batch.update(userRef, {
        'isModerated': event.isModerated,
      });

      // delete() в батче идемпотентен: если документа нет — Firestore просто проигнорирует удаление
      batch.delete(moderationRef);

      // 3. Атомарно выполняем обе операции
      await batch.commit();

      // 4. Локально обновляем состояние списка
      final updatedUsers = currentState.users.map((user) {
        if (user.id == event.userId) {
          return UserModel(
            id: user.id,
            userName: user.userName,
            name: user.name,
            company: user.company,
            number: user.number,
            isModerated: event.isModerated,
            createdAt: user.createdAt,
            userType: user.userType,
          );
        }
        return user;
      }).toList();

      emit(UsersLoadedState(updatedUsers, isUpdating: false));
    } catch (e) {
      emit(UsersErrorState('Failed to update moderation: $e'));
    }
  }
}
