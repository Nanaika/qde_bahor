import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qde_eco_bahor/core/utils/app_constants.dart';

import '../../admin/moderate_order/order_model.dart';
import 'orders_event.dart';
import 'orders_state.dart';

class ClientOrdersBloc extends Bloc<ClientOrdersEvent, ClientOrdersState> {
  final FirebaseFirestore _firestore;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _subscription;

  ClientOrdersBloc({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        super(ClientOrdersInitial()) {
    on<SubscribeToClientOrdersEvent>(_onSubscribe);
    on<ClientOrdersUpdatedEvent>(_onUpdated);
    on<ClientOrdersErrorEvent>(_onError);
  }

  Future<void> _onSubscribe(
    SubscribeToClientOrdersEvent event,
    Emitter<ClientOrdersState> emit,
  ) async {
    emit(ClientOrdersLoading());

    await _subscription?.cancel();
    print('==================  ${event.userId}');
    _subscription = _firestore
        .collection(AppConstants.orders)
        .where('owner.id', isEqualTo: event.userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen(
      (snapshot) {
        try {
          final List<OrderModel> orders = snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return OrderModel.fromJson(data);
          }).toList();

          add(ClientOrdersUpdatedEvent(orders));
        } catch (e) {
          add(ClientOrdersErrorEvent('Parsing error: $e'));
        }
      },
      onError: (error) {
        add(ClientOrdersErrorEvent('Error Firestore: $error'));
      },
    );
  }

  void _onUpdated(
    ClientOrdersUpdatedEvent event,
    Emitter<ClientOrdersState> emit,
  ) {
    emit(ClientOrdersSuccess(event.orders));
  }

  void _onError(
    ClientOrdersErrorEvent event,
    Emitter<ClientOrdersState> emit,
  ) {
    emit(ClientOrdersError(event.message));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
