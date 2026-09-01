import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:qde_eco_bahor/features/admin/discount/discount_model.dart';
import 'package:qde_eco_bahor/features/admin/restriction/restricted_product_model.dart';

class UserModel extends Equatable {
  final String id;
  final String userName;
  final String name;
  final String company;
  final String number;
  final bool isModerated;
  final DateTime? createdAt;
  final UserType userType;
  final List<DiscountModel> discounts;
  final List<RestrictedProductModel> restricted;

  const UserModel({
    required this.id,
    required this.userName,
    required this.name,
    required this.company,
    required this.number,
    this.isModerated = false,
    this.createdAt,
    this.userType = UserType.client,
    this.discounts = const [],
    this.restricted = const [],
  });

  UserModel copyWith({
    String? id,
    String? userName,
    String? name,
    String? company,
    String? number,
    bool? isModerated,
    DateTime? createdAt,
    UserType? userType,
    List<DiscountModel>? discounts,
    List<RestrictedProductModel>? restricted,
  }) {
    return UserModel(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      name: name ?? this.name,
      company: company ?? this.company,
      number: number ?? this.number,
      isModerated: isModerated ?? this.isModerated,
      createdAt: createdAt ?? this.createdAt,
      userType: userType ?? this.userType,
      discounts: discounts ?? this.discounts,
      restricted: restricted ?? this.restricted,
    );
  }

  // Из JSON / Firestore Document
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      userName: json['userName'] as String? ?? '',
      name: json['name'] as String? ?? '',
      company: json['company'] as String? ?? '',
      number: json['number'] as String? ?? '',
      isModerated: json['isModerated'] as bool? ?? false,
      createdAt: json['createdAt'] != null ? (json['createdAt'] as Timestamp).toDate() : null,
      userType: _parseUserType(json['userType']),
      discounts: (json['discounts'] as List<dynamic>?)
              ?.map((e) => DiscountModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      restricted: (json['restricted'] as List<dynamic>?)
              ?.map((e) => RestrictedProductModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  static UserType _parseUserType(dynamic value) {
    if (value is String) {
      return UserType.values.firstWhere(
        (type) => type.name == value,
        orElse: () => UserType.client,
      );
    }
    return UserType.client;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userName': userName,
      'name': name,
      'company': company,
      'number': number,
      'isModerated': isModerated,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'userType': userType.name, // Сохраняем как строку ('client', 'admin' и т.д.)
      'discounts': discounts.map((d) => d.toJson()).toList(),
      'restricted': restricted.map((r) => r.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        userName,
        name,
        company,
        number,
        isModerated,
        createdAt,
        userType,
        discounts,
        restricted,
      ];
}

enum UserType { client, accounting, warehouse }
