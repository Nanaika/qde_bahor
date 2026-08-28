import 'package:equatable/equatable.dart';

import '../../admin/moderate_order/order_model.dart';

abstract class OrderEvent extends Equatable {
  const OrderEvent();

  @override
  List<Object?> get props => [];
}

class CreateOrderEvent extends OrderEvent {
  final OrderModel order;

  const CreateOrderEvent(this.order);

  @override
  List<Object?> get props => [order];
}
