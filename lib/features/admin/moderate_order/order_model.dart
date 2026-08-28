import 'package:cloud_firestore/cloud_firestore.dart';

import '../../auth/data/models/user_model.dart';
import '../../cart/cart_item.dart';

class OrderModel {
  final String id;
  final List<CartItem> items;
  final UserModel owner;
  final num totalPrice;
  final DateTime? createdAt;

  OrderModel({
    required this.id,
    required this.items,
    required this.owner,
    required this.totalPrice,
    this.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];

    return OrderModel(
      id: json['id'] as String? ?? '',
      items: rawItems.map((item) => CartItem.fromJson(Map<String, dynamic>.from(item as Map))).toList(),
      owner: UserModel.fromJson(
        Map<String, dynamic>.from(json['owner'] as Map? ?? {}),
      ),
      totalPrice: json['totalPrice'] as num? ?? 0,
      createdAt: json['createdAt'] is Timestamp ? (json['createdAt'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'items': items.map((item) => item.toJson()).toList(),
        'owner': owner.toJson(),
        'totalPrice': totalPrice,
        'createdAt': FieldValue.serverTimestamp(),
      };

  OrderModel copyWith({
    String? id,
    List<CartItem>? items,
    UserModel? owner,
    num? totalPrice,
    DateTime? createdAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      items: items ?? this.items,
      owner: owner ?? this.owner,
      totalPrice: totalPrice ?? this.totalPrice,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
