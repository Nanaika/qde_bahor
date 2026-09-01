import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qde_eco_bahor/core/utils/app_constants.dart';

import 'restricted_product_model.dart';
import 'restricted_products_event.dart';
import 'restricted_products_state.dart';

class RestrictedProductsBloc extends Bloc<RestrictedProductsEvent, RestrictedProductsState> {
  final FirebaseFirestore _firestore;

  RestrictedProductsBloc({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        super(RestrictedProductsInitialState()) {
    on<LoadRestrictedProductsEvent>(_onLoadRestrictedProducts);
    on<AddRestrictedProductEvent>(_onAddRestrictedProduct);
    on<UpdateRestrictedProductEvent>(_onUpdateRestrictedProduct);
    on<DeleteRestrictedProductEvent>(_onDeleteRestrictedProduct);
  }

  /// Получение подколлекции restricted_products
  Future<void> _onLoadRestrictedProducts(
    LoadRestrictedProductsEvent event,
    Emitter<RestrictedProductsState> emit,
  ) async {
    emit(RestrictedProductsLoadingState());
    try {
      final snapshot = await _firestore
          .collection(AppConstants.users)
          .doc(event.userId)
          .collection(AppConstants.restrictedProducts)
          .get();

      final restrictions = snapshot.docs.map((doc) => RestrictedProductModel.fromJson(doc.data())).toList();

      emit(RestrictedProductsSuccessState(restrictions));
    } catch (e) {
      emit(RestrictedProductsErrorState(e.toString()));
    }
  }

  /// Добавление запрета на продукт (docId = productId)
  Future<void> _onAddRestrictedProduct(
    AddRestrictedProductEvent event,
    Emitter<RestrictedProductsState> emit,
  ) async {
    try {
      final docRef = _firestore
          .collection(AppConstants.users)
          .doc(event.userId)
          .collection(AppConstants.restrictedProducts)
          .doc(event.restriction.productId);

      await docRef.set({
        ...event.restriction.toJson(),
        'addedAt': FieldValue.serverTimestamp(),
      });

      add(LoadRestrictedProductsEvent(event.userId));
    } catch (e) {
      emit(RestrictedProductsErrorState(e.toString()));
    }
  }

  /// Обновление запрета на продукт
  Future<void> _onUpdateRestrictedProduct(
    UpdateRestrictedProductEvent event,
    Emitter<RestrictedProductsState> emit,
  ) async {
    try {
      final docRef = _firestore
          .collection(AppConstants.users)
          .doc(event.userId)
          .collection(AppConstants.restrictedProducts)
          .doc(event.restriction.productId);

      await docRef.update({
        ...event.restriction.toJson(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      add(LoadRestrictedProductsEvent(event.userId));
    } catch (e) {
      emit(RestrictedProductsErrorState(e.toString()));
    }
  }

  /// Удаление запрета с продукта
  Future<void> _onDeleteRestrictedProduct(
    DeleteRestrictedProductEvent event,
    Emitter<RestrictedProductsState> emit,
  ) async {
    try {
      await _firestore
          .collection(AppConstants.users)
          .doc(event.userId)
          .collection(AppConstants.restrictedProducts)
          .doc(event.productId)
          .delete();

      add(LoadRestrictedProductsEvent(event.userId));
    } catch (e) {
      emit(RestrictedProductsErrorState(e.toString()));
    }
  }
}
