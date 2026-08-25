import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qde_eco_bahor/features/admin/models/product_type_model.dart';
import 'package:qde_eco_bahor/features/admin/models/product_variant.dart';

class ProductModel {
  final Timestamp? date;
  final String? id;
  final ProductTypeModel productType;
  final String name;
  final String description;
  final String photoUrl;
  final List<ProductVariant> variants;

  const ProductModel({
    this.date,
    this.id,
    required this.productType,
    required this.name,
    required this.description,
    required this.photoUrl,
    required this.variants,
  });

  ProductModel copyWith({
    Timestamp? date,
    String? id,
    ProductTypeModel? productType,
    String? name,
    String? description,
    String? photoUrl,
    List<ProductVariant>? variants,
  }) {
    return ProductModel(
      date: date ?? this.date,
      id: id ?? this.id,
      productType: productType ?? this.productType,
      name: name ?? this.name,
      description: description ?? this.description,
      photoUrl: photoUrl ?? this.photoUrl,
      variants: variants ?? this.variants,
    );
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    print('====######  ${json}');

    return ProductModel(
      date: json['date'] as Timestamp?,
      id: json['id'] as String? ?? '',
      productType: ProductTypeModel.fromJson(json['productType']),
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      photoUrl: json['photoUrl'] as String? ?? '',
      variants: (json['variants'] as List<dynamic>?)
              ?.map((e) => ProductVariant.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date,
        'productType': productType.toJson(),
        'name': name,
        'description': description,
        'photoUrl': photoUrl,
        'variants': variants.map((v) => v.toJson()).toList(),
      };
}
