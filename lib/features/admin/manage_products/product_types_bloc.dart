import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import 'manage_products_event.dart';
import 'manage_products_repository.dart';
import 'manage_products_state.dart';

class ProductTypesBloc extends Bloc<ManageProductsEvent, ManageProductsState> {
  final ManageProductsRepository repository;

  ProductTypesBloc({required this.repository}) : super(ManageProductsInitial()) {
    on<GetProductsTypesEvent>(_onGetTypes);
    on<AddProductsTypeEvent>(_onAddType);
    on<DeleteProductsTypeEvent>(_onDeleteType);
    on<EditProductsTypeEvent>(_onUpdateType);
    add(GetProductsTypesEvent());
  }

  Future<void> _onGetTypes(GetProductsTypesEvent event, Emitter<ManageProductsState> emit) async {
    emit(ManageProductsLoading());

    try {
      final types = await repository.getTypes();

      emit(ManageProductsTypeSuccess(types));
    } on Failure catch (failure) {
      emit(ManageProductsError(failure));
    } catch (e) {
      emit(ManageProductsError(ServerFailure(e.toString())));
    }
  }

  Future<void> _onAddType(AddProductsTypeEvent event, Emitter<ManageProductsState> emit) async {
    emit(ManageProductsLoading());

    try {
      await repository.addType(event.model);
      final types = await repository.getTypes();

      emit(ManageProductsTypeSuccess(types));
    } on Failure catch (failure) {
      emit(ManageProductsError(failure));
    } catch (e) {
      emit(ManageProductsError(ServerFailure(e.toString())));
    }
  }

  Future<void> _onDeleteType(DeleteProductsTypeEvent event, Emitter<ManageProductsState> emit) async {
    emit(ManageProductsLoading());

    try {
      await repository.deleteType(event.id);
      final types = await repository.getTypes();

      emit(ManageProductsTypeSuccess(types));
    } on Failure catch (failure) {
      emit(ManageProductsError(failure));
    } catch (e) {
      emit(ManageProductsError(ServerFailure(e.toString())));
    }
  }

  Future<void> _onUpdateType(EditProductsTypeEvent event, Emitter<ManageProductsState> emit) async {
    emit(ManageProductsLoading());

    try {
      await repository.updateType(event.model);
      final types = await repository.getTypes();

      emit(ManageProductsTypeSuccess(types));
    } on Failure catch (failure) {
      emit(ManageProductsError(failure));
    } catch (e) {
      emit(ManageProductsError(ServerFailure(e.toString())));
    }
  }
}
