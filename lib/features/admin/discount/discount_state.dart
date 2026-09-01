import 'package:equatable/equatable.dart';

import 'discount_model.dart';

abstract class DiscountsState extends Equatable {
  const DiscountsState();

  @override
  List<Object?> get props => [];
}

class DiscountsInitialState extends DiscountsState {
  const DiscountsInitialState();
}

class DiscountsLoadingState extends DiscountsState {
  const DiscountsLoadingState();
}

class DiscountsLoadedState extends DiscountsState {
  final List<DiscountModel> discounts;
  final bool isActionInProgress; // Для показа локального лоадера при добавлении/удалении

  const DiscountsLoadedState(
    this.discounts, {
    this.isActionInProgress = false,
  });

  @override
  List<Object?> get props => [discounts, isActionInProgress];
}

class DiscountsErrorState extends DiscountsState {
  final String message;

  const DiscountsErrorState(this.message);

  @override
  List<Object?> get props => [message];
}
