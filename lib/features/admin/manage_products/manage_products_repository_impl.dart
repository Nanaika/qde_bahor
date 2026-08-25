import 'package:qde_eco_bahor/features/admin/models/product_model.dart';
import 'package:qde_eco_bahor/features/admin/models/product_type_model.dart';

import '../../../core/network/network_info.dart';
import 'manage_products_remote_datasource.dart';
import 'manage_products_repository.dart';

class ManageProductsRepositoryImpl implements ManageProductsRepository {
  final ManageProductsRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  ManageProductsRepositoryImpl({required this.remoteDataSource, required this.networkInfo});

  @override
  Future<List<ProductModel>> getProducts() async {
    return await remoteDataSource.getProducts();
  }

  @override
  Future<List<ProductTypeModel>> getTypes() async {
    return await remoteDataSource.getTypes();
  }

  @override
  Future<void> addType(ProductTypeModel model) async {
    return await remoteDataSource.addType(model);
  }

  @override
  Future<void> deleteType(String id) async {
    return await remoteDataSource.deleteType(id);
  }

  @override
  Future<void> updateType(ProductTypeModel model) async {
    return await remoteDataSource.updateType(model);
  }
}
