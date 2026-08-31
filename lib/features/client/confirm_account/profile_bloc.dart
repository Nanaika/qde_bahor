import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qde_eco_bahor/core/utils/app_constants.dart';
import 'package:qde_eco_bahor/features/client/confirm_account/user_profile_model.dart';
import '../../auth/data/models/user_model.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(ProfileInitialState()) {
    on<SubmitProfileForVerificationEvent>(_onSubmitProfile);
    on<CheckModerationStatusEvent>(_onCheckModerationStatus);
  }

  final db = FirebaseFirestore.instance;

  Future<void> _onSubmitProfile(
    SubmitProfileForVerificationEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileSubmittingState());

    try {
      final userProfileModel = UserModel(
        id: event.id,
        name: event.fullName,
        company: event.companyName,
        number: event.phoneNumber,
        userName: event.username,
      );

      final batch = db.batch();

// Ссылка на документ в коллекции модерации
      final moderateRef = db.collection(AppConstants.moderateUsers).doc(event.id);

// Ссылка на документ в основной коллекции пользователей
      final userRef = db.collection(AppConstants.users).doc(event.id);

      final data = userProfileModel.toJson();

// 1. Записываем в moderateUsers
      batch.set(moderateRef, data, SetOptions(merge: true));

// 2. Обновляем те же поля в основной коллекции users
      batch.update(userRef, data);

// Атомарно коммитим обе операции за один сетевой запрос
      await batch.commit();

      emit(const ProfileSubmitSuccessState());
    } catch (e) {
      emit(ProfileSubmitErrorState(e.toString()));
    }
  }

  Future<void> _onCheckModerationStatus(
    CheckModerationStatusEvent event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      // 1. Проверяем, есть ли документ юзера на модерации в Firestore
      final doc = await db.collection(AppConstants.moderateUsers).doc(event.userId).get();

      final bool isPending = doc.exists; // Если документ есть в базе — он НА МОДЕРАЦИИ

      emit(ProfileModerationStatusState(
        isPending: isPending,
        isModerated: false, // Флаг смодерирован ли юзер берётся из AuthState
      ));
    } catch (e) {
      emit(ProfileSubmitErrorState(e.toString()));
    }
  }
}
