import 'package:cloud_firestore/cloud_firestore.dart';

import '../../cart/cart_item.dart';

class OrderModel {
  final String id;
  final List<CartItem> items;
  final num totalPrice;
  final DateTime? createdAt;

  OrderModel({
    required this.id,
    required this.items,
    required this.totalPrice,
    this.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];

    return OrderModel(
      id: json['id'] as String? ?? '',
      items: rawItems.map((item) => CartItem.fromJson(Map<String, dynamic>.from(item as Map))).toList(),
      totalPrice: json['totalPrice'] as num? ?? 0,
      createdAt: json['createdAt'] is Timestamp ? (json['createdAt'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'items': items.map((item) => item.toJson()).toList(),
        'totalPrice': totalPrice,
        'createdAt': FieldValue.serverTimestamp(),
      };
}
