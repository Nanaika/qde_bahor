import 'dart:typed_data';

import 'package:qde_eco_bahor/features/admin/models/product_model.dart';

abstract class AddProductEvent {}

class AddEvent extends AddProductEvent {
  final ProductModel item;
  final Uint8List imageBytes;

  AddEvent(this.item, this.imageBytes);
}
