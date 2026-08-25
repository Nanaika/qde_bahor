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
    return ProductModel(
      date: json['date'] as Timestamp?,
      id: json['id'] as String? ?? '',
      productType: _parseProductType(json['productType']) ?? ProductTypeModel(id: '', name: {}),
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      photoUrl: json['photoUrl'] as String? ?? '',
      variants: (json['variants'] as List<dynamic>?)
              ?.map((e) => ProductVariant.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'id': id,
      'productType': productType.name,
      'name': name,
      'description': description,
      'photoUrl': photoUrl,
      'variants': variants.map((v) => v.toJson()).toList(),
    };
  }
}

ProductTypeModel? _parseProductType(dynamic jsonValue) {
  if (jsonValue == null) return null;

// Если в Firestore лежит полноценный объект/Map
  if (jsonValue is Map<String, dynamic>) {
    return ProductTypeModel.fromJson(jsonValue);
  }

// Фолбэк: если осталась старая запись, где хранился только String (например, ID или имя)
  if (jsonValue is String) {
    return ProductTypeModel(
      id: jsonValue,
      name: {'ru': jsonValue},
    );
  }

  return null;
}
