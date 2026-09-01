import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:qde_eco_bahor/core/utils/app_constants.dart';
import 'package:qde_eco_bahor/features/admin/manage_products/manage_products_event.dart';
import 'package:qde_eco_bahor/features/admin/manage_products/product_types_bloc.dart';
import 'package:qde_eco_bahor/features/admin/restriction/restricted_product_model.dart';
import 'package:qde_eco_bahor/features/auth/domain/repositories/auth_repository.dart';
import 'package:qde_eco_bahor/features/cart/cart_bloc.dart';

import '../../../admin/discount/discount_model.dart';
import '../../../admin/manage_products/manage_products_state.dart';
import '../../data/models/user_model.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({
    required this.authRepository,
  }) : super(const AuthInitialState()) {
    on<LoginEvent>(_onLogin);
    on<RegisterEvent>(_onRegister);
    on<LogoutEvent>(_onLogout);
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<RefreshUserEvent>(_onRefreshUser);
  }

  Future<void> _onRefreshUser(
    RefreshUserEvent event,
    Emitter<AuthState> emit,
  ) async {
    if (state is! AuthAuthenticatedState) return;
    // await Future.delayed(const Duration(seconds: 11));
    final currentUser = (state as AuthAuthenticatedState).user;

    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(currentUser.id).get();

      if (doc.exists && doc.data() != null) {
        final updatedUser = UserModel.fromJson(doc.data()!);
        emit(AuthAuthenticatedState(updatedUser));
      }
    } catch (e) {
      emit(AuthErrorState(e));
    }
  }

  Future<void> _onLogin(
    LoginEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoadingState());
    try {
      final user = await authRepository.login(event.email, event.password);
      emit(AuthAuthenticatedState(user));
    } catch (failure) {
      emit(AuthErrorState(failure));
    }
  }

  Future<void> _onRegister(
    RegisterEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoadingState());
    try {
      final user = await authRepository.register(event.email, event.password, event.name);
      emit(AuthAuthenticatedState(user));
    } catch (failure) {
      emit(AuthErrorState(failure));
    }
  }

  Future<void> _onLogout(
    LogoutEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoadingState());
    try {
      await authRepository.logout();
      emit(const AuthUnauthenticatedState());
    } catch (failure) {
      emit(AuthErrorState(failure));
    }
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final user = await authRepository.getCurrentUser();
      if (user != null) {
        final discountsSnapshot = await FirebaseFirestore.instance
            .collection(AppConstants.users)
            .doc(user.id)
            .collection(AppConstants.discounts)
            .get();

        final discounts = discountsSnapshot.docs.map((doc) => DiscountModel.fromJson(doc.data())).toList();

        final restrictedSnapshot = await FirebaseFirestore.instance
            .collection(AppConstants.users)
            .doc(user.id)
            .collection(AppConstants.restrictedProducts)
            .get();

        final restricted = restrictedSnapshot.docs.map((doc) => RestrictedProductModel.fromJson(doc.data())).toList();

        final typesBloc = GetIt.I<ProductTypesBloc>();
        typesBloc.add(GetProductsTypesEvent());
        final cartBloc = GetIt.I<CartCubit>();
        await cartBloc.loadCart(user.id);

        await typesBloc.stream.firstWhere(
          (state) => state is ManageProductsTypeSuccess || state is ManageProductsError,
        );

        emit(AuthAuthenticatedState(user.copyWith(discounts: discounts, restricted: restricted)));
      } else {
        emit(const AuthUnauthenticatedState());
      }
    } catch (failure) {
      emit(AuthErrorState(failure));
    }
  }
}
