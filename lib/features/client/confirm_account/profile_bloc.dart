import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qde_eco_bahor/core/utils/app_constants.dart';
import 'package:qde_eco_bahor/features/client/confirm_account/user_profile_model.dart';
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
      final userProfileModel = UserProfileModel(
          id: event.id, fullName: event.fullName, companyName: event.companyName, phoneNumber: event.phoneNumber);
      final ref = db.collection(AppConstants.moderateUsers).doc(event.id);
      await ref.set(userProfileModel.toJson());

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
