import 'package:qde_eco_bahor/features/admin/models/product_model.dart';
import 'package:qde_eco_bahor/features/admin/models/product_type_model.dart';

abstract class ManageProductsRepository {
  Future<List<ProductModel>> getProducts();
  Future<List<ProductTypeModel>> getTypes();
  Future addType(ProductTypeModel model);
  Future deleteType(String id);
  Future updateType(ProductTypeModel model);
}
