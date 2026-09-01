import 'package:equatable/equatable.dart';
import 'restricted_product_model.dart';

abstract class RestrictedProductsEvent extends Equatable {
  const RestrictedProductsEvent();

  @override
  List<Object?> get props => [];
}

/// Получение всех ограничений юзера
class LoadRestrictedProductsEvent extends RestrictedProductsEvent {
  final String userId;

  const LoadRestrictedProductsEvent(this.userId);

  @override
  List<Object?> get props => [userId];
} // Новый евент для обновления

class UpdateRestrictedProductEvent extends RestrictedProductsEvent {
  final String userId;
  final RestrictedProductModel restriction;

  const UpdateRestrictedProductEvent({
    required this.userId,
    required this.restriction,
  });

  @override
  List<Object?> get props => [userId, restriction];
}

/// Добавление / Запрет продукта
class AddRestrictedProductEvent extends RestrictedProductsEvent {
  final String userId;
  final RestrictedProductModel restriction;

  const AddRestrictedProductEvent({
    required this.userId,
    required this.restriction,
  });

  @override
  List<Object?> get props => [userId, restriction];
}

/// Удаление ограничения (снятие запрета)
class DeleteRestrictedProductEvent extends RestrictedProductsEvent {
  final String userId;
  final String productId;

  const DeleteRestrictedProductEvent({
    required this.userId,
    required this.productId,
  });

  @override
  List<Object?> get props => [userId, productId];
}
