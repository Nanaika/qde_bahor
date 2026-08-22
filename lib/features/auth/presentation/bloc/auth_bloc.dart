import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:qde_eco_bahor/core/error/failures.dart';
import 'package:qde_eco_bahor/features/auth/domain/entities/user_entity.dart';
import 'package:qde_eco_bahor/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:qde_eco_bahor/features/auth/domain/usecases/login_usecase.dart';
import 'package:qde_eco_bahor/features/auth/domain/usecases/logout_usecase.dart';
import 'package:qde_eco_bahor/features/auth/domain/usecases/register_usecase.dart';

part 'auth_bloc.freezed.dart';
part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;

  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.getCurrentUserUseCase,
  }) : super(const AuthState.initial()) {
    on<AuthEvent>((event, emit) async {
      await event.when(
        login: (email, password) => _onLogin(email, password, emit),
        register: (email, password, name) => _onRegister(email, password, name, emit),
        logout: () => _onLogout(emit),
        checkAuthStatus: () => _onCheckAuthStatus(emit),
      );
    });
  }

  Future<void> _onLogin(String email, String password, Emitter<AuthState> emit) async {
    emit(const AuthState.loading());
    final result = await loginUseCase(LoginParams(email: email, password: password));
    result.fold(
      (failure) => emit(AuthState.error(failure)),
      (user) => emit(AuthState.authenticated(user)),
    );
  }

  Future<void> _onRegister(String email, String password, String name, Emitter<AuthState> emit) async {
    emit(const AuthState.loading());
    final result = await registerUseCase(RegisterParams(email: email, password: password, name: name));
    result.fold(
      (failure) => emit(AuthState.error(failure)),
      (user) => emit(AuthState.authenticated(user)),
    );
  }

  Future<void> _onLogout(Emitter<AuthState> emit) async {
    emit(const AuthState.loading());
    final result = await logoutUseCase();
    result.fold(
      (failure) => emit(AuthState.error(failure)),
      (_) => emit(const AuthState.unauthenticated()),
    );
  }

  Future<void> _onCheckAuthStatus(Emitter<AuthState> emit) async {
    final result = await getCurrentUserUseCase();
    result.fold(
      (failure) => emit(AuthState.error(failure)),
      (user) => user != null ? emit(AuthState.authenticated(user)) : emit(const AuthState.unauthenticated()),
    );
  }
}
