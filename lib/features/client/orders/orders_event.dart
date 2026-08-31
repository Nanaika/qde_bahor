import 'package:equatable/equatable.dart';

import '../../admin/moderate_order/order_model.dart';

abstract class ClientOrdersEvent extends Equatable {
  const ClientOrdersEvent();

  @override
  List<Object?> get props => [];
}

class SubscribeToClientOrdersEvent extends ClientOrdersEvent {
  final String userId;
  const SubscribeToClientOrdersEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

class ClientOrdersUpdatedEvent extends ClientOrdersEvent {
  final List<OrderModel> orders;
  const ClientOrdersUpdatedEvent(this.orders);

  @override
  List<Object?> get props => [orders];
}

class ClientOrdersErrorEvent extends ClientOrdersEvent {
  final String message;
  const ClientOrdersErrorEvent(this.message);

  @override
  List<Object?> get props => [message];
}
