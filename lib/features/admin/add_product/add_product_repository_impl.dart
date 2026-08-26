import 'dart:typed_data';

import 'package:qde_eco_bahor/features/admin/models/product_model.dart';

import '../../../core/network/network_info.dart';
import 'add_product_remote_datasource.dart';
import 'add_product_repository.dart';

class AddProductRepositoryImpl implements AddProductRepository {
  final AddProductRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  AddProductRepositoryImpl({required this.remoteDataSource, required this.networkInfo});

  @override
  Future<dynamic> add(
    ProductModel item,
    Uint8List imageBytes,
  ) async {
    await remoteDataSource.add(item, imageBytes);
  }

  @override
  Future<dynamic> update(ProductModel item, Uint8List? imageBytes) async {
    await remoteDataSource.update(item, imageBytes);
  }

  @override
  Future<dynamic> delete(String id) async {
    await remoteDataSource.delete(id);
  }
}
