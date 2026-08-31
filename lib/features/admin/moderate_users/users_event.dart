import 'package:equatable/equatable.dart';

import '../../auth/data/models/user_model.dart';

abstract class UsersEvent extends Equatable {
  const UsersEvent();

  @override
  List<Object?> get props => [];
}

class FetchAllUsersEvent extends UsersEvent {
  const FetchAllUsersEvent();
}

class UpdateUserRoleEvent extends UsersEvent {
  final String userId;
  final UserType userType;

  const UpdateUserRoleEvent({
    required this.userId,
    required this.userType,
  });

  @override
  List<Object?> get props => [userId, userType];
}

class UpdateUserModerationEvent extends UsersEvent {
  final String userId;
  final bool isModerated;

  const UpdateUserModerationEvent({
    required this.userId,
    required this.isModerated,
  });

  @override
  List<Object?> get props => [userId, isModerated];
}
