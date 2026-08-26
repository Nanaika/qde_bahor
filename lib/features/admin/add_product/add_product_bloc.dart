import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import 'add_product_event.dart';
import 'add_product_repository.dart';
import 'add_product_state.dart';

class AddProductBloc extends Bloc<AddProductEvent, AddProductState> {
  final AddProductRepository repository;

  AddProductBloc({required this.repository}) : super(AddProductInitial()) {
    on<AddEvent>(_onAddProduct);
    on<EditEvent>(_onEditProduct);
    on<DeleteEvent>(_onDeleteProduct);
  }

  Future<void> _onAddProduct(AddEvent event, Emitter<AddProductState> emit) async {
    emit(AddProductLoading());

    try {
      await repository.add(event.item, event.imageBytes);

      emit(AddProductSuccess());
    } on Failure catch (failure) {
      emit(AddProductError(failure));
    } catch (e) {
      emit(AddProductError(ServerFailure(e.toString())));
    }
  }

  Future<void> _onEditProduct(EditEvent event, Emitter<AddProductState> emit) async {
    emit(AddProductLoading());

    try {
      await repository.update(event.item, event.imageBytes);

      emit(AddProductSuccess());
    } on Failure catch (failure) {
      emit(AddProductError(failure));
    } catch (e) {
      emit(AddProductError(ServerFailure(e.toString())));
    }
  }

  Future<void> _onDeleteProduct(DeleteEvent event, Emitter<AddProductState> emit) async {
    emit(AddProductLoading());

    try {
      await repository.delete(event.id);

      emit(AddProductSuccess());
    } on Failure catch (failure) {
      emit(AddProductError(failure));
    } catch (e) {
      emit(AddProductError(ServerFailure(e.toString())));
    }
  }
}
