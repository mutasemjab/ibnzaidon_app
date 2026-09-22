import 'package:equatable/equatable.dart';

class Student extends Equatable {
  const Student({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.avatar,
    this.className,
    this.classId,
    this.gender,
    this.isActive = true,
    this.appAccountToken,
  });

  final int id;
  final String name;
  final String phone;
  final String? email;
  final String? avatar;
  final String? className;
  final int? classId;
  final String? gender;
  final bool isActive;

  /// UUID used as `purchase_token` for Apple purchase verification.
  final String? appAccountToken;

  @override
  List<Object?> get props => [
    id,
    name,
    phone,
    email,
    avatar,
    className,
    classId,
    gender,
    isActive,
    appAccountToken,
  ];
}

final class AuthSession extends Equatable {
  const AuthSession({required this.token, required this.student});

  final String token;
  final Student student;

  @override
  List<Object?> get props => [token, student];
}
