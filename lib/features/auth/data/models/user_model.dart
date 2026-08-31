import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String userName;
  final String name;
  final String company;
  final String number;
  final bool isModerated;
  final DateTime? createdAt;
  final UserType userType; // Больше не nullable

  const UserModel({
    required this.id,
    required this.userName,
    required this.name,
    required this.company,
    required this.number,
    this.isModerated = false,
    this.createdAt,
    this.userType = UserType.client, // По умолчанию — клиент
  });

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
    );
  }

  // Вспомогательный метод для безопасного парсинга enum
  static UserType _parseUserType(dynamic value) {
    if (value is String) {
      return UserType.values.firstWhere(
        (type) => type.name == value,
        orElse: () => UserType.client,
      );
    }
    return UserType.client;
  }

  // В JSON для сохранения в Firestore
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
      ];
}

enum UserType { client, accounting, warehouse }
