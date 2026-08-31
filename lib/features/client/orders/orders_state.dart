import 'package:equatable/equatable.dart';

import '../../admin/moderate_order/order_model.dart';

abstract class ClientOrdersState extends Equatable {
  const ClientOrdersState();

  @override
  List<Object?> get props => [];
}

class ClientOrdersInitial extends ClientOrdersState {}

class ClientOrdersLoading extends ClientOrdersState {}

class ClientOrdersSuccess extends ClientOrdersState {
  final List<OrderModel> orders;
  const ClientOrdersSuccess(this.orders);

  @override
  List<Object?> get props => [orders];
}

class ClientOrdersError extends ClientOrdersState {
  final String message;
  const ClientOrdersError(this.message);

  @override
  List<Object?> get props => [message];
}
