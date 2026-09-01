import 'package:equatable/equatable.dart';
import 'restricted_product_model.dart';

abstract class RestrictedProductsState extends Equatable {
  const RestrictedProductsState();

  @override
  List<Object?> get props => [];
}

class RestrictedProductsInitialState extends RestrictedProductsState {}

class RestrictedProductsLoadingState extends RestrictedProductsState {}

class RestrictedProductsSuccessState extends RestrictedProductsState {
  final List<RestrictedProductModel> restrictions;

  const RestrictedProductsSuccessState(this.restrictions);

  @override
  List<Object?> get props => [restrictions];
}

class RestrictedProductsErrorState extends RestrictedProductsState {
  final String message;

  const RestrictedProductsErrorState(this.message);

  @override
  List<Object?> get props => [message];
}
