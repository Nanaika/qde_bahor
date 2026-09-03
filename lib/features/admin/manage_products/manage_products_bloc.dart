import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../models/product_model.dart';
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
    on<UpdateProductVariantsEvent>(_onUpdatePromoProductVariants);
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

  Future<void> _onUpdatePromoProductVariants(
    UpdateProductVariantsEvent event,
    Emitter<ManageProductsState> emit,
  ) async {
    // 1. Запоминаем текущие товары из стейта перед показом загрузки
    final currentState = state;
    List<ProductModel> currentProducts = [];

    if (currentState is ManageProductsSuccess) {
      currentProducts = currentState.products;
    }

    emit(ManageProductsLoading());

    try {
      // 2. Апдейтим в БД через репозиторий
      await repository.updateVariantPromo(event.product);

      // 3. Меням только один этот товар в текущем списке
      final updatedList = currentProducts.map((product) {
        return product.id == event.product.id ? event.product : product;
      }).toList();

      // 4. Отдаем обноволенный список без сетевого getProducts()
      emit(ManageProductsSuccess(updatedList));
    } on Failure catch (failure) {
      emit(ManageProductsError(failure));
    } catch (e) {
      emit(ManageProductsError(ServerFailure(e.toString())));
    }
  }
}
