import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../presentation/add_product_page.dart';
import 'add_product_event.dart';
import 'add_product_repository.dart';
import 'add_product_state.dart';

class AddProductBloc extends Bloc<AddProductEvent, AddProductState> {
  final AddProductRepository repository;

  AddProductBloc({required this.repository}) : super(AddProductInitial()) {
    on<AddEvent>(_onConfirmAccount);
  }

  Future<void> _onConfirmAccount(AddEvent event, Emitter<AddProductState> emit) async {
    emit(AddProductLoading());

    try {
      await repository.add(event.item);

      emit(AddProductSuccess());
    } on Failure catch (failure) {
      emit(AddProductError(failure));
    } catch (e) {
      emit(AddProductError(ServerFailure(e.toString())));
    }
  }
}
