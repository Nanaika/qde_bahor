import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qde_eco_bahor/core/utils/app_constants.dart';
import 'package:qde_eco_bahor/features/admin/moderate_order/status_type.dart';

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
    on<UpdateStatusEvent>(_onUpdateStatus);
    on<UpdateDriverStatusEvent>(_onUpdateDriverStatus);
    on<DeleteOrderEvent>(_onDeleteOrder);
  }

  Future<void> _onDeleteOrder(
    DeleteOrderEvent event,
    Emitter<ManageOrdersState> emit,
  ) async {
    try {
      await _firestore.collection(AppConstants.orders).doc(event.docId).delete();
    } catch (e) {
      emit(ManageOrdersError('Error on delete order: $e'));
    }
  }

  Future<void> _onUpdateDriverStatus(
    UpdateDriverStatusEvent event,
    Emitter<ManageOrdersState> emit,
  ) async {
    try {
      final ref = _firestore.collection(AppConstants.orders).doc(event.docId);

      final updateData = <String, dynamic>{
        'driverStatus': event.status.name,
      };

      if (event.driverPhone != null) {
        updateData['driverPhone'] = event.driverPhone;
      }
      if (event.driverDescription != null) {
        updateData['driverDescription'] = event.driverDescription;
      }

      await ref.update(updateData);
    } catch (e) {
      emit(ManageOrdersError('Error driver status update: $e'));
    }
  }

  Future<void> _onSubscribe(
    SubscribeToManageOrdersEvent event,
    Emitter<ManageOrdersState> emit,
  ) async {
    emit(ManageOrdersLoading());

    await _subscription?.cancel();

    _subscription =
        _firestore.collection(AppConstants.orders).orderBy('createdAt', descending: true).snapshots().listen(
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

  Future<void> _onUpdateStatus(
    UpdateStatusEvent event,
    Emitter<ManageOrdersState> emit,
  ) async {
    try {
      final ref = _firestore.collection(AppConstants.orders).doc(event.docId);

      switch (event.statusType) {
        case StatusType.storage:
          await ref.update({'warehouseStatus': event.status.name, 'warehouseDeclinedMessage': event.reason});
          break;
        case StatusType.accounting:
          await ref.update({'accountingStatus': event.status.name, 'accountingDeclinedMessage': event.reason});
          break;
      }
    } catch (e) {
      emit(ManageOrdersError('Error: $e'));
    }
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
