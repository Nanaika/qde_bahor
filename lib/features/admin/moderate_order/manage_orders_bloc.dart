import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'manage_order_state.dart';
import 'manage_orders_event.dart';
import 'order_model.dart';

class ManageOrdersBloc extends Bloc<ManageOrdersEvent, ManageOrdersState> {
  final FirebaseFirestore _firestore;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _subscription;

  ManageOrdersBloc({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        super(ManageOrdersInitial()) {
    on<SubscribeToManageOrdersEvent>(_onSubscribe);
    on<ManageOrdersUpdatedEvent>(_onUpdated);
    on<ManageOrdersErrorEvent>(_onError);
  }

  Future<void> _onSubscribe(
    SubscribeToManageOrdersEvent event,
    Emitter<ManageOrdersState> emit,
  ) async {
    emit(ManageOrdersLoading());

    await _subscription?.cancel();

    _subscription = _firestore.collection('orders').orderBy('createdAt', descending: true).snapshots().listen(
      (snapshot) {
        try {
          final List<OrderModel> orders = snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return OrderModel.fromJson(data);
          }).toList();

          add(ManageOrdersUpdatedEvent(orders));
        } catch (e) {
          add(ManageOrdersErrorEvent('Ошибка парсинга: $e'));
        }
      },
      onError: (error) {
        add(ManageOrdersErrorEvent('Ошибка Firestore: $error'));
      },
    );
  }

  void _onUpdated(
    ManageOrdersUpdatedEvent event,
    Emitter<ManageOrdersState> emit,
  ) {
    emit(ManageOrdersSuccess(event.orders));
  }

  void _onError(
    ManageOrdersErrorEvent event,
    Emitter<ManageOrdersState> emit,
  ) {
    emit(ManageOrdersError(event.message));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
