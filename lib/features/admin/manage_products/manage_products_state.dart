import 'package:qde_eco_bahor/features/admin/models/product_model.dart';

import '../../../../core/error/failures.dart';
import '../models/product_type_model.dart';

abstract class ManageProductsState {}

class ManageProductsInitial extends ManageProductsState {}

class ManageProductsLoading extends ManageProductsState {}

class ManageProductsSuccess extends ManageProductsState {
  final List<ProductModel> products;

  ManageProductsSuccess(this.products);
}

class ManageProductsTypeSuccess extends ManageProductsState {
  final List<ProductTypeModel> types;

  ManageProductsTypeSuccess(this.types);
}

class ManageProductsError extends ManageProductsState {
  final Failure failure;

  ManageProductsError(this.failure);
}
