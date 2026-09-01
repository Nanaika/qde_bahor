import 'package:equatable/equatable.dart';
import 'discount_model.dart';

abstract class DiscountsEvent extends Equatable {
  const DiscountsEvent();

  @override
  List<Object?> get props => [];
}

// Загрузить скидки конкретного юзера
class FetchUserDiscountsEvent extends DiscountsEvent {
  final String userId;

  const FetchUserDiscountsEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

// Добавить или обновить скидку
class SaveDiscountEvent extends DiscountsEvent {
  final String userId;
  final DiscountModel discount;

  const SaveDiscountEvent({
    required this.userId,
    required this.discount,
  });

  @override
  List<Object?> get props => [userId, discount];
}

// Удалить скидку по ее ID
class DeleteDiscountEvent extends DiscountsEvent {
  final String userId;
  final String discountId;

  const DeleteDiscountEvent({
    required this.userId,
    required this.discountId,
  });

  @override
  List<Object?> get props => [userId, discountId];
}
