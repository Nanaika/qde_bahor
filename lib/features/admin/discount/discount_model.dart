import 'package:equatable/equatable.dart';

class DiscountModel extends Equatable {
  final String id;
  final String productId;
  final String productName;
  final String variantId;
  final String productVariant;
  final double discountPercent;

  const DiscountModel({
    this.id = '',
    required this.productId,
    required this.productName,
    required this.variantId,
    required this.productVariant,
    required this.discountPercent,
  });

  DiscountModel copyWith({
    String? id,
    String? productId,
    String? productName,
    String? variantId,
    String? productVariant,
    double? discountPercent,
  }) {
    return DiscountModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      variantId: variantId ?? this.variantId,
      productVariant: productVariant ?? this.productVariant,
      discountPercent: discountPercent ?? this.discountPercent,
    );
  }

  factory DiscountModel.fromJson(Map<String, dynamic> json) {
    return DiscountModel(
      id: json['id'] ?? '',
      productId: json['productId'] ?? '',
      productName: json['productName'] ?? '',
      variantId: json['variantId'] ?? '',
      productVariant: json['productVariant'] ?? '',
      discountPercent: (json['discountPercent'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'variantId': variantId,
      'productVariant': productVariant,
      'discountPercent': discountPercent,
    };
  }

  @override
  List<Object?> get props => [
        id,
        productId,
        productName,
        variantId,
        productVariant,
        discountPercent,
      ];
}
