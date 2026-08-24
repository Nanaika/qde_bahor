import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qde_eco_bahor/features/admin/models/product_model.dart';

import '../../../core/utils/app_constants.dart';

abstract class AddProductRemoteDataSource {
  Future add(ProductModel item);
}

class AddProductRemoteDataSourceImpl implements AddProductRemoteDataSource {
  final db = FirebaseFirestore.instance;

  @override
  Future<void> add(ProductModel item) async {
    final docRef = db.collection(AppConstants.products).doc();

    final updatedItem = item.copyWith(id: docRef.id);

    await docRef.set({
      ...updatedItem.toJson(),
      'date': FieldValue.serverTimestamp(), // Точное время сервера Firestore
    });
  }
}
