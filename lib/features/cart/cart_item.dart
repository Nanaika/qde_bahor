import 'package:cloud_firestore/cloud_firestore.dart';

import '../admin/models/product_model.dart';
import '../admin/models/product_variant.dart';

class CartItem {
  final ProductModel product;
  final ProductVariant variant;
  int quantity;

  CartItem({
    required this.product,
    required this.variant,
    required this.quantity,
  });

  // Возвращаем затертое поле/геттер totalPrice:
  num get totalPrice => (variant.price) * quantity;

  Map<String, dynamic> toJson() => {
        'product': product.toJson(),
        'variant': variant.toJson(),
        'quantity': quantity,
      };

  factory CartItem.fromJson(Map<String, dynamic> json) {
    final rawProduct = Map<String, dynamic>.from(json['product'] as Map);

    // Конвертируем строки формата "Timestamp(seconds=..., nanoseconds=...)" обратно в Timestamp
    rawProduct.forEach((key, value) {
      if (value is String && value.startsWith('Timestamp(')) {
        final regExp = RegExp(r'seconds=(\d+),\s*nanoseconds=(\d+)');
        final match = regExp.firstMatch(value);
        if (match != null) {
          final seconds = int.parse(match.group(1)!);
          final nanoseconds = int.parse(match.group(2)!);
          rawProduct[key] = Timestamp(seconds, nanoseconds);
        }
      }
    });

    return CartItem(
      product: ProductModel.fromJson(rawProduct),
      variant: ProductVariant.fromJson(
        Map<String, dynamic>.from(json['variant'] as Map),
      ),
      quantity: json['quantity'] as int,
    );
  }
  // factory CartItem.fromJson(Map<String, dynamic> json) {
  //   return CartItem(
  //     product: ProductModel.fromJson(
  //       Map<String, dynamic>.from(json['product'] as Map),
  //     ),
  //     variant: ProductVariant.fromJson(
  //       Map<String, dynamic>.from(json['variant'] as Map),
  //     ),
  //     quantity: json['quantity'] as int,
  //   );
  // }
}
