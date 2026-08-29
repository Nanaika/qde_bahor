import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class SubmitProfileForVerificationEvent extends ProfileEvent {
  final String id;
  final String fullName;
  final String companyName;
  final String phoneNumber;

  const SubmitProfileForVerificationEvent({
    required this.id,
    required this.fullName,
    required this.companyName,
    required this.phoneNumber,
  });

  @override
  List<Object?> get props => [id, fullName, companyName, phoneNumber];
}

class CheckModerationStatusEvent extends ProfileEvent {
  final String userId;
  const CheckModerationStatusEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}
