import 'package:equatable/equatable.dart';
import 'package:qde_eco_bahor/features/admin/moderate_order/order_model.dart';
import 'package:qde_eco_bahor/features/admin/moderate_order/presentation/manage_orders_page.dart';
import 'package:qde_eco_bahor/features/admin/moderate_order/status_type.dart';

abstract class ManageOrdersEvent extends Equatable {
  const ManageOrdersEvent();

  @override
  List<Object?> get props => [];
}

/// Старт прослушивания Firestore
class SubscribeToManageOrdersEvent extends ManageOrdersEvent {
  const SubscribeToManageOrdersEvent();
}

class UpdateStatusEvent extends ManageOrdersEvent {
  final String docId;
  final StatusType statusType;
  final OrderStatus status;
  final String reason;
  const UpdateStatusEvent({required this.docId, required this.statusType, required this.status, required this.reason});
}

/// Новый снимок из Firestore
class ManageOrdersUpdatedEvent extends ManageOrdersEvent {
  final List<OrderModel> orders;

  const ManageOrdersUpdatedEvent(this.orders);

  @override
  List<Object?> get props => [orders];
}

/// Ошибка при чтении потока
class ManageOrdersErrorEvent extends ManageOrdersEvent {
  final String message;

  const ManageOrdersErrorEvent(this.message);

  @override
  List<Object?> get props => [message];
}
