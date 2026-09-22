import 'package:equatable/equatable.dart';
import 'package:ibnzaidon/features/auth/domain/entities/student.dart';

class ProfileStat extends Equatable {
  const ProfileStat({required this.key, required this.value});

  final String key;
  final double value;

  @override
  List<Object?> get props => [key, value];
}

class Profile extends Equatable {
  const Profile({
    required this.student,
    this.nationalId,
    this.dateOfBirth,
    this.nationality,
    this.stats = const [],
  });

  final Student student;
  final String? nationalId;
  final DateTime? dateOfBirth;
  final String? nationality;

  /// The API's `stats` object as key/value pairs (keys are not contractually
  /// fixed, the UI localizes the ones it knows).
  final List<ProfileStat> stats;

  @override
  List<Object?> get props => [
    student,
    nationalId,
    dateOfBirth,
    nationality,
    stats,
  ];
}

class ProfileUpdate extends Equatable {
  const ProfileUpdate({
    this.name,
    this.email,
    this.phone,
    this.nationalId,
    this.gender,
    this.dateOfBirth,
    this.nationality,
    this.classId,
    this.avatarPath,
    this.currentPassword,
    this.newPassword,
    this.newPasswordConfirmation,
  });

  final String? name;
  final String? email;
  final String? phone;
  final String? nationalId;
  final String? gender;
  final DateTime? dateOfBirth;
  final String? nationality;
  final int? classId;

  /// Local file path of the new avatar (multipart, ≤ 2 MB).
  final String? avatarPath;
  final String? currentPassword;
  final String? newPassword;
  final String? newPasswordConfirmation;

  @override
  List<Object?> get props => [
    name,
    email,
    phone,
    nationalId,
    gender,
    dateOfBirth,
    nationality,
    classId,
    avatarPath,
    currentPassword,
    newPassword,
    newPasswordConfirmation,
  ];
}
