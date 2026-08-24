import '../../../../core/error/failures.dart';

abstract class AddProductState {}

class AddProductInitial extends AddProductState {}

class AddProductLoading extends AddProductState {}

class AddProductSuccess extends AddProductState {}

class AddProductError extends AddProductState {
  final Failure failure;

  AddProductError(this.failure);
}
