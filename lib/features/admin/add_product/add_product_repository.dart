import 'dart:typed_data';

import 'package:qde_eco_bahor/features/admin/models/product_model.dart';

abstract class AddProductRepository {
  Future add(
    ProductModel item,
    Uint8List imageBytes,
  );

  Future update(
    ProductModel item,
    Uint8List? imageBytes,
  );

  Future delete(String id);
}
