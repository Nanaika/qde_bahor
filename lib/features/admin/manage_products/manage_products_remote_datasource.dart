import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qde_eco_bahor/features/admin/models/product_type_model.dart';

import '../../../core/utils/app_constants.dart';
import '../models/product_model.dart';

abstract class ManageProductsRemoteDataSource {
  Future<List<ProductModel>> getProducts();

  Future<List<ProductTypeModel>> getTypes();

  Future addType(ProductTypeModel model);

  Future deleteType(String id);

  Future updateType(ProductTypeModel model);

  Future updateVariantPromo(ProductModel model);
}

class ManageProductsRemoteDataSourceImpl implements ManageProductsRemoteDataSource {
  final db = FirebaseFirestore.instance;

  @override
  Future<List<ProductModel>> getProducts() async {
    final querySnapshot = await db
        .collection(AppConstants.products)
        .orderBy('date', descending: true) // Сортировка по дате добавления (новые сверху)
        .get();

    return querySnapshot.docs.map((doc) {
      return ProductModel.fromJson({
        ...doc.data(),
      });
    }).toList();
  }

  @override
  Future<List<ProductTypeModel>> getTypes() async {
    final querySnapshot = await db.collection(AppConstants.productsTypes).get();

    return querySnapshot.docs.map((doc) {
      return ProductTypeModel.fromJson(doc.data());
    }).toList();
  }

  @override
  Future<dynamic> addType(ProductTypeModel model) async {
    // 1. Создаем ссылку на новый документ, чтобы получить сгенерированный ID
    final docRef = db.collection(AppConstants.productsTypes).doc();

    // 2. Формируем итоговый объект с сохраненным ID
    final dataToSave = model.toJson()..['id'] = docRef.id;

    // 3. Записываем в Firestore
    await docRef.set(dataToSave);
  }

  @override
  Future<dynamic> deleteType(String id) async {
    await db.collection(AppConstants.productsTypes).doc(id).delete();
  }

  @override
  Future<dynamic> updateType(ProductTypeModel model) async {
    await db.collection(AppConstants.productsTypes).doc(model.id).set(
          model.toJson(),
          SetOptions(merge: true),
        );
  }

  @override
  Future<dynamic> updateVariantPromo(ProductModel model) async {
    await db.collection(AppConstants.products).doc(model.id).update({
      'variants': model.variants.map((v) => v.toJson()).toList(),
    });
  }
}
