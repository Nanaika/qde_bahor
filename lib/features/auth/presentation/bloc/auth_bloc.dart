import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:qde_eco_bahor/features/admin/manage_products/manage_products_event.dart';
import 'package:qde_eco_bahor/features/admin/manage_products/product_types_bloc.dart';
import 'package:qde_eco_bahor/features/auth/domain/repositories/auth_repository.dart';
import 'package:qde_eco_bahor/features/cart/cart_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../admin/manage_products/manage_products_state.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({
    required this.authRepository,
  }) : super(const AuthInitialState()) {
    on<AuthEvent>((event, emit) async {
      if (event is LoginEvent) {
        await _onLogin(event.email, event.password, emit);
      } else if (event is RegisterEvent) {
        await _onRegister(event.email, event.password, event.name, emit);
      } else if (event is LogoutEvent) {
        await _onLogout(emit);
      } else if (event is CheckAuthStatusEvent) {
        await _onCheckAuthStatus(emit);
      }
    });
  }

  Future<void> _onLogin(String email, String password, Emitter<AuthState> emit) async {
    emit(const AuthLoadingState());
    try {
      final user = await authRepository.login(email, password);
      emit(AuthAuthenticatedState(user));
    } catch (failure) {
      emit(AuthErrorState(failure));
    }
  }

  Future<void> _onRegister(String email, String password, String name, Emitter<AuthState> emit) async {
    emit(const AuthLoadingState());
    try {
      final user = await authRepository.register(email, password, name);
      emit(AuthAuthenticatedState(user));
    } catch (failure) {
      emit(AuthErrorState(failure));
    }
  }

  Future<void> _onLogout(Emitter<AuthState> emit) async {
    emit(const AuthLoadingState());
    try {
      await authRepository.logout();
      emit(const AuthUnauthenticatedState());
    } catch (failure) {
      emit(AuthErrorState(failure));
    }
  }

  Future<void> _onCheckAuthStatus(Emitter<AuthState> emit) async {
    try {
      final user = await authRepository.getCurrentUser();
      if (user != null) {
        final typesBloc = GetIt.I<ProductTypesBloc>();
        typesBloc.add(GetProductsTypesEvent());
        final cartBloc = GetIt.I<CartCubit>();
        await cartBloc.loadCart(user.id);
        // 3. ЖДЕМ, пока ProductTypesBloc вернет Success или Error
        await typesBloc.stream.firstWhere(
          (state) => state is ManageProductsTypeSuccess || state is ManageProductsError,
        );

        emit(AuthAuthenticatedState(user));
      } else {
        emit(const AuthUnauthenticatedState());
      }
    } catch (failure) {
      emit(AuthErrorState(failure));
    }
  }
}
