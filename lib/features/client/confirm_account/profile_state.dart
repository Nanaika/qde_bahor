import 'package:equatable/equatable.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitialState extends ProfileState {}

class ProfileSubmittingState extends ProfileState {}

class ProfileSubmitSuccessState extends ProfileState {
  final String message;

  const ProfileSubmitSuccessState({
    this.message = 'Profile details submitted for verification successfully.',
  });

  @override
  List<Object?> get props => [message];
}

class ProfileSubmitErrorState extends ProfileState {
  final String message;

  const ProfileSubmitErrorState(this.message);

  @override
  List<Object?> get props => [message];
}

class ProfileModerationStatusState extends ProfileState {
  final bool isPending; // Есть ли докуемент в коллекции модерации
  final bool isModerated; // Проверен ли юзер

  const ProfileModerationStatusState({
    required this.isPending,
    required this.isModerated,
  });

  @override
  List<Object?> get props => [isPending, isModerated];
}
