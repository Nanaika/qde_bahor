import 'package:qde_eco_bahor/features/admin/models/product_model.dart';

abstract class AddProductRepository {
  Future add(ProductModel item);
}
