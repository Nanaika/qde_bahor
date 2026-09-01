import 'package:equatable/equatable.dart';

class RestrictedProductModel extends Equatable {
  final String productId;
  final String productName;
  final DateTime? addedAt;

  const RestrictedProductModel({
    required this.productId,
    this.productName = '',
    this.addedAt,
  });

  factory RestrictedProductModel.fromJson(Map<String, dynamic> json) {
    return RestrictedProductModel(
      productId: json['productId'] as String? ?? json['id'] as String? ?? '',
      productName: json['productName'] as String? ?? '',
      addedAt: json['addedAt'] != null ? DateTime.tryParse(json['addedAt'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'productName': productName,
        'addedAt': addedAt?.toIso8601String(),
      };

  @override
  List<Object?> get props => [productId, productName, addedAt];
}
