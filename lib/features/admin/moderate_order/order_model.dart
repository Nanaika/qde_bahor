import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qde_eco_bahor/features/admin/presentation/manage_orders_page.dart';

import '../../auth/data/models/user_model.dart';
import '../../cart/cart_item.dart';

class OrderModel {
  final String id;
  final List<CartItem> items;
  final UserModel owner;
  final num totalPrice;
  final num totalDiscountPrice;
  final DateTime? createdAt;
  final OrderStatus warehouseStatus;
  final OrderStatus accountingStatus;
  final String warehouseDeclinedMessage;
  final String accountingDeclinedMessage;

  // Новые поля для подсчета количества и бонусов
  final int totalPaidCount;
  final int totalBonusCount;
  final int totalQuantityCount;

  final DriverStatus driverStatus;
  final String driverPhone;
  final String driverDescription;

  OrderModel({
    required this.id,
    required this.items,
    required this.owner,
    required this.totalPrice,
    this.totalDiscountPrice = 0,
    this.createdAt,
    this.warehouseStatus = OrderStatus.waiting,
    this.accountingStatus = OrderStatus.waiting,
    this.warehouseDeclinedMessage = '',
    this.accountingDeclinedMessage = '',
    this.totalPaidCount = 0,
    this.totalBonusCount = 0,
    this.totalQuantityCount = 0,
    this.driverStatus = DriverStatus.waiting,
    this.driverPhone = '',
    this.driverDescription = '',
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
      totalDiscountPrice: json['totalDiscountPrice'] as num? ?? 0,
      createdAt: json['createdAt'] is Timestamp ? (json['createdAt'] as Timestamp).toDate() : null,
      warehouseStatus: OrderStatus.values.firstWhere(
        (e) => e.name == json['warehouseStatus'],
        orElse: () => OrderStatus.waiting,
      ),
      accountingStatus: OrderStatus.values.firstWhere(
        (e) => e.name == json['accountingStatus'],
        orElse: () => OrderStatus.waiting,
      ),
      warehouseDeclinedMessage: json['warehouseDeclinedMessage'] as String? ?? '',
      accountingDeclinedMessage: json['accountingDeclinedMessage'] as String? ?? '',
      totalPaidCount: json['totalPaidCount'] as int? ?? 0,
      totalBonusCount: json['totalBonusCount'] as int? ?? 0,
      totalQuantityCount: json['totalQuantityCount'] as int? ?? 0,
      driverStatus: DriverStatus.values.firstWhere(
        (e) => e.name == json['driverStatus'],
        orElse: () => DriverStatus.waiting,
      ),
      driverPhone: json['driverPhone'] as String? ?? '',
      driverDescription: json['driverDescription'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'items': items.map((item) => item.toJson()).toList(),
        'owner': owner.toJson(),
        'totalPrice': totalPrice,
        'totalDiscountPrice': totalDiscountPrice,
        'createdAt': FieldValue.serverTimestamp(),
        'warehouseStatus': warehouseStatus.name,
        'accountingStatus': accountingStatus.name,
        'warehouseDeclinedMessage': warehouseDeclinedMessage,
        'accountingDeclinedMessage': accountingDeclinedMessage,
        'totalPaidCount': totalPaidCount,
        'totalBonusCount': totalBonusCount,
        'totalQuantityCount': totalQuantityCount,
        'driverStatus': driverStatus.name,
        'driverPhone': driverPhone,
        'driverDescription': driverDescription,
      };

  OrderModel copyWith({
    String? id,
    List<CartItem>? items,
    UserModel? owner,
    num? totalPrice,
    num? totalDiscountPrice,
    DateTime? createdAt,
    OrderStatus? warehouseStatus,
    OrderStatus? accountingStatus,
    String? warehouseDeclinedMessage,
    String? accountingDeclinedMessage,
    int? totalPaidCount,
    int? totalBonusCount,
    int? totalQuantityCount,
    DriverStatus? driverStatus,
    String? driverPhone,
    String? driverDescription,
  }) {
    return OrderModel(
      id: id ?? this.id,
      items: items ?? this.items,
      owner: owner ?? this.owner,
      totalPrice: totalPrice ?? this.totalPrice,
      totalDiscountPrice: totalDiscountPrice ?? this.totalDiscountPrice,
      createdAt: createdAt ?? this.createdAt,
      warehouseStatus: warehouseStatus ?? this.warehouseStatus,
      accountingStatus: accountingStatus ?? this.accountingStatus,
      warehouseDeclinedMessage: warehouseDeclinedMessage ?? this.warehouseDeclinedMessage,
      accountingDeclinedMessage: accountingDeclinedMessage ?? this.accountingDeclinedMessage,
      totalPaidCount: totalPaidCount ?? this.totalPaidCount,
      totalBonusCount: totalBonusCount ?? this.totalBonusCount,
      totalQuantityCount: totalQuantityCount ?? this.totalQuantityCount,
      driverStatus: driverStatus ?? this.driverStatus,
      driverPhone: driverPhone ?? this.driverPhone,
      driverDescription: driverDescription ?? this.driverDescription,
    );
  }
}
