import 'package:equatable/equatable.dart';
import 'package:qde_eco_bahor/features/admin/moderate_order/order_model.dart';

abstract class ManageOrdersState extends Equatable {
  const ManageOrdersState();

  @override
  List<Object?> get props => [];
}

class ManageOrdersInitial extends ManageOrdersState {}

class ManageOrdersLoading extends ManageOrdersState {}

class ManageOrdersStatusLoading extends ManageOrdersState {}

class ManageOrdersSuccess extends ManageOrdersState {
  final List<OrderModel> orders;

  const ManageOrdersSuccess(this.orders);

  @override
  List<Object?> get props => [orders];
}

class ManageOrdersError extends ManageOrdersState {
  final String message;

  const ManageOrdersError(this.message);

  @override
  List<Object?> get props => [message];
}
