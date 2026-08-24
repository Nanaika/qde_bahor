import 'package:qde_eco_bahor/features/admin/models/product_model.dart';

abstract class AddProductEvent {}

class AddEvent extends AddProductEvent {
  final ProductModel item;

  AddEvent(this.item);
}
