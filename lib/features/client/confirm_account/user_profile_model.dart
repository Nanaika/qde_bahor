import 'package:equatable/equatable.dart';

class UserProfileModel extends Equatable {
  final String id;
  final String fullName;
  final String companyName;
  final String phoneNumber;

  const UserProfileModel({
    required this.id,
    required this.fullName,
    required this.companyName,
    required this.phoneNumber,
  });

  factory UserProfileModel.empty() {
    return const UserProfileModel(
      id: '',
      fullName: '',
      companyName: '',
      phoneNumber: '',
    );
  }

  UserProfileModel copyWith({
    String? id,
    String? fullName,
    String? companyName,
    String? phoneNumber,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      companyName: companyName ?? this.companyName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'companyName': companyName,
      'phoneNumber': phoneNumber,
    };
  }

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      companyName: json['companyName'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
    );
  }

  @override
  List<Object?> get props => [id, fullName, companyName, phoneNumber];
}
