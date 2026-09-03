import 'package:qde_eco_bahor/features/admin/models/product_model.dart';
import 'package:qde_eco_bahor/features/admin/models/product_type_model.dart';

import '../models/product_variant.dart';

abstract class ManageProductsEvent {}

class GetProductsEvent extends ManageProductsEvent {}

class GetProductsTypesEvent extends ManageProductsEvent {}

class SetLoadingEvent extends ManageProductsEvent {}

class AddProductsTypeEvent extends ManageProductsEvent {
  final ProductTypeModel model;

  AddProductsTypeEvent(this.model);
}

class EditProductsTypeEvent extends ManageProductsEvent {
  final ProductTypeModel model;

  EditProductsTypeEvent(this.model);
}

class DeleteProductsTypeEvent extends ManageProductsEvent {
  final String id;

  DeleteProductsTypeEvent(this.id);
}

class UpdateProductVariantsEvent extends ManageProductsEvent {
  final ProductModel product;

  UpdateProductVariantsEvent({required this.product});
}
