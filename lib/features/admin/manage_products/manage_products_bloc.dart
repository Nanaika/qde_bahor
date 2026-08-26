import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import 'manage_products_event.dart';
import 'manage_products_repository.dart';
import 'manage_products_state.dart';

class ManageProductsBloc extends Bloc<ManageProductsEvent, ManageProductsState> {
  final ManageProductsRepository repository;

  ManageProductsBloc({required this.repository}) : super(ManageProductsInitial()) {
    on<GetProductsEvent>(_onGetProducts);
    on<SetLoadingEvent>((event, emit) {
      emit(ManageProductsLoading());
    });
  }

  Future<void> _onGetProducts(ManageProductsEvent event, Emitter<ManageProductsState> emit) async {
    emit(ManageProductsLoading());

    try {
      final products = await repository.getProducts();

      emit(ManageProductsSuccess(products));
    } on Failure catch (failure) {
      emit(ManageProductsError(failure));
    } catch (e) {
      emit(ManageProductsError(ServerFailure(e.toString())));
    }
  }
}
