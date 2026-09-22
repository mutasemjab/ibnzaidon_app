import 'package:ibnzaidon/core/utils/parsers.dart';
import 'package:ibnzaidon/shared/domain/entities/course.dart';

IdName? parseIdName(Object? raw) {
  final map = asMap(raw);
  if (map == null) return null;
  final id = tryParseInt(map['id']);
  if (id == null) return null;
  return IdName(id: id, name: parseString(map['name'] ?? map['name_ar']));
}

TeacherRef? parseTeacherRef(Object? raw) {
  final map = asMap(raw);
  if (map == null) return null;
  final id = tryParseInt(map['id']);
  if (id == null) return null;
  return TeacherRef(
    id: id,
    name: parseString(map['name']),
    avatar: tryParseString(map['avatar']),
  );
}

final class CourseModel extends Course {
  const CourseModel({
    required super.id,
    required super.title,
    super.description,
    super.thumbnail,
    super.price,
    super.oldPrice,
    super.isFree,
    super.canPurchaseViaStore,
    super.discountPercent,
    super.averageRating,
    super.totalStudents,
    super.durationHours,
    super.difficultyLevel,
    super.isLive,
    super.teacher,
    super.category,
    super.subject,
    super.classInfo,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    final price = parseDouble(json['price']);
    final oldPrice = tryParseDouble(json['old_price']);
    return CourseModel(
      id: parseInt(json['id']),
      title: parseString(json['title'] ?? json['title_ar'] ?? json['title_en']),
      description: tryParseString(json['description']),
      thumbnail: tryParseString(json['thumbnail']),
      price: price,
      oldPrice: oldPrice,
      isFree: parseBool(json['is_free']),
      canPurchaseViaStore: parseBool(json['can_purchase_via_store']),
      discountPercent: _discount(json['discount'], price, oldPrice),
      averageRating: parseDouble(json['average_rating']),
      totalStudents: parseInt(json['total_students']),
      durationHours: parseDouble(json['duration_hours']),
      difficultyLevel: tryParseString(json['difficulty_level']),
      isLive: parseBool(json['is_live']),
      teacher: parseTeacherRef(json['teacher']),
      category: parseIdName(json['category']),
      subject: parseIdName(json['subject']),
      classInfo: parseIdName(json['class']),
    );
  }

  /// `discount` may be a percent or missing; derive it from the old price
  /// when the backend omits it.
  static int _discount(Object? raw, double price, double? oldPrice) {
    final given = tryParseDouble(raw);
    if (given != null && given > 0) return given.round().clamp(0, 100);
    if (oldPrice != null && oldPrice > price && oldPrice > 0) {
      return (((oldPrice - price) / oldPrice) * 100).round();
    }
    return 0;
  }
}

final class TeacherModel extends Teacher {
  const TeacherModel({
    required super.id,
    required super.name,
    super.specialization,
    super.avatar,
    super.yearsOfExperience,
    super.averageRating,
    super.totalStudents,
    super.totalCourses,
    super.isVerified,
  });

  factory TeacherModel.fromJson(Map<String, dynamic> json) => TeacherModel(
    id: parseInt(json['id']),
    name: parseString(json['name']),
    specialization: tryParseString(json['specialization']),
    avatar: tryParseString(json['avatar']),
    yearsOfExperience: parseInt(json['years_of_experience']),
    averageRating: parseDouble(json['average_rating']),
    totalStudents: parseInt(json['total_students']),
    totalCourses: parseInt(json['total_courses']),
    isVerified: parseBool(json['is_verified']),
  );
}
