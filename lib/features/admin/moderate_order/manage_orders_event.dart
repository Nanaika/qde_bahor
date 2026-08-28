import 'package:equatable/equatable.dart';
import 'package:qde_eco_bahor/features/admin/moderate_order/order_model.dart';

abstract class ManageOrdersEvent extends Equatable {
  const ManageOrdersEvent();

  @override
  List<Object?> get props => [];
}

/// Старт прослушивания Firestore
class SubscribeToManageOrdersEvent extends ManageOrdersEvent {
  const SubscribeToManageOrdersEvent();
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
