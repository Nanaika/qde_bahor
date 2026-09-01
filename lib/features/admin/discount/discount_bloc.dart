import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'discount_event.dart';
import 'discount_model.dart';
import 'discount_state.dart';

class DiscountsBloc extends Bloc<DiscountsEvent, DiscountsState> {
  final FirebaseFirestore _firestore;

  DiscountsBloc({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        super(const DiscountsInitialState()) {
    on<FetchUserDiscountsEvent>(_onFetchUserDiscounts);
    on<SaveDiscountEvent>(_onSaveDiscount);
    on<DeleteDiscountEvent>(_onDeleteDiscount);
  }

  // Получить подколлекцию
  CollectionReference<Map<String, dynamic>> _discountsRef(String userId) {
    return _firestore.collection('users').doc(userId).collection('discounts');
  }

  // 1. ПОЛУЧЕНИЕ ВСЕХ СКИДОК
  Future<void> _onFetchUserDiscounts(
    FetchUserDiscountsEvent event,
    Emitter<DiscountsState> emit,
  ) async {
    emit(const DiscountsLoadingState());
    try {
      final snapshot = await _discountsRef(event.userId).get();
      final discounts = snapshot.docs.map((doc) => DiscountModel.fromJson({'id': doc.id, ...doc.data()})).toList();

      emit(DiscountsLoadedState(discounts));
    } catch (e) {
      emit(DiscountsErrorState('Failed to fetch discounts: $e'));
    }
  }

  // 2. СОХРАНЕНИЕ / ОБНОВЛЕНИЕ СКИДКИ
  Future<void> _onSaveDiscount(
    SaveDiscountEvent event,
    Emitter<DiscountsState> emit,
  ) async {
    if (state is! DiscountsLoadedState) return;
    final currentState = state as DiscountsLoadedState;

    emit(DiscountsLoadedState(currentState.discounts, isActionInProgress: true));

    try {
      final collection = _discountsRef(event.userId);
      String discountId = event.discount.id;

      if (discountId.isEmpty) {
        // Создание новой скидки с новым doc.id
        final docRef = collection.doc();
        discountId = docRef.id;
        final newDiscount = event.discount.copyWith(id: discountId);
        await docRef.set(newDiscount.toJson());
      } else {
        // Обновление существующей скидки
        await collection.doc(discountId).set(
              event.discount.toJson(),
              SetOptions(merge: true),
            );
      }

      // Обновляем локальный список без повторного запроса get()
      final updatedList = List<DiscountModel>.from(currentState.discounts);
      final index = updatedList.indexWhere((d) => d.id == discountId);
      final savedDiscount = event.discount.copyWith(id: discountId);

      if (index >= 0) {
        updatedList[index] = savedDiscount;
      } else {
        updatedList.add(savedDiscount);
      }

      emit(DiscountsLoadedState(updatedList, isActionInProgress: false));
    } catch (e) {
      emit(DiscountsErrorState('Failed to save discount: $e'));
    }
  }

  // 3. УДАЛЕНИЕ СКИДКИ
  Future<void> _onDeleteDiscount(
    DeleteDiscountEvent event,
    Emitter<DiscountsState> emit,
  ) async {
    if (state is! DiscountsLoadedState) return;
    final currentState = state as DiscountsLoadedState;

    emit(DiscountsLoadedState(currentState.discounts, isActionInProgress: true));

    try {
      await _discountsRef(event.userId).doc(event.discountId).delete();

      final updatedList = currentState.discounts.where((d) => d.id != event.discountId).toList();

      emit(DiscountsLoadedState(updatedList, isActionInProgress: false));
    } catch (e) {
      emit(DiscountsErrorState('Failed to delete discount: $e'));
    }
  }
}
