import '../../data/models/user_model.dart';

abstract class AuthState {
  const AuthState();
}

class AuthInitialState extends AuthState {
  const AuthInitialState();
}

class AuthLoadingState extends AuthState {
  const AuthLoadingState();
}

class AuthAuthenticatedState extends AuthState {
  final UserModel user;
  const AuthAuthenticatedState(this.user);
}

class AuthUnauthenticatedState extends AuthState {
  const AuthUnauthenticatedState();
}

class AuthErrorState extends AuthState {
  final dynamic failure;
  const AuthErrorState(this.failure);
}
