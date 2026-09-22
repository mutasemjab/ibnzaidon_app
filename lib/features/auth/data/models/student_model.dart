import 'package:ibnzaidon/core/utils/parsers.dart';
import 'package:ibnzaidon/features/auth/domain/entities/student.dart';

final class StudentModel extends Student {
  const StudentModel({
    required super.id,
    required super.name,
    required super.phone,
    super.email,
    super.avatar,
    super.className,
    super.classId,
    super.gender,
    super.isActive,
    super.appAccountToken,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    final classField = json['class'];
    final classMap = asMap(classField);
    return StudentModel(
      id: parseInt(json['id']),
      name: parseString(json['name']),
      phone: parseString(json['phone']),
      email: tryParseString(json['email']),
      avatar: tryParseString(json['avatar']),
      className: classMap == null
          ? tryParseString(classField)
          : tryParseString(classMap['name']),
      classId: tryParseInt(json['class_id'] ?? classMap?['id']),
      gender: tryParseString(json['gender']),
      isActive: parseBool(json['is_active'], fallback: true),
      appAccountToken: tryParseString(json['app_account_token']),
    );
  }

  factory StudentModel.fromEntity(Student student) => StudentModel(
    id: student.id,
    name: student.name,
    phone: student.phone,
    email: student.email,
    avatar: student.avatar,
    className: student.className,
    classId: student.classId,
    gender: student.gender,
    isActive: student.isActive,
    appAccountToken: student.appAccountToken,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phone': phone,
    'email': email,
    'avatar': avatar,
    'class': className,
    'class_id': classId,
    'gender': gender,
    'is_active': isActive,
    'app_account_token': appAccountToken,
  };
}
