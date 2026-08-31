import 'package:equatable/equatable.dart';

import '../../auth/data/models/user_model.dart';

abstract class UsersState extends Equatable {
  const UsersState();

  @override
  List<Object?> get props => [];
}

class UsersInitialState extends UsersState {
  const UsersInitialState();
}

class UsersLoadingState extends UsersState {
  const UsersLoadingState();
}

class UsersLoadedState extends UsersState {
  final List<UserModel> users;
  final bool isUpdating; // Флаг: прямо сейчас идёт обновление

  const UsersLoadedState(this.users, {this.isUpdating = false});

  @override
  List<Object?> get props => [users, isUpdating];
}

class UsersErrorState extends UsersState {
  final String message;

  const UsersErrorState(this.message);

  @override
  List<Object?> get props => [message];
}
