import 'package:equatable/equatable.dart';

class IdName extends Equatable {
  const IdName({required this.id, required this.name});

  final int id;
  final String name;

  @override
  List<Object?> get props => [id, name];
}

class TeacherRef extends Equatable {
  const TeacherRef({required this.id, required this.name, this.avatar});

  final int id;
  final String name;
  final String? avatar;

  @override
  List<Object?> get props => [id, name, avatar];
}

/// Course card as returned by list/home/subject/teacher endpoints.
class Course extends Equatable {
  const Course({
    required this.id,
    required this.title,
    this.description,
    this.thumbnail,
    this.price = 0,
    this.oldPrice,
    this.isFree = false,
    this.canPurchaseViaStore = false,
    this.discountPercent = 0,
    this.averageRating = 0,
    this.totalStudents = 0,
    this.durationHours = 0,
    this.difficultyLevel,
    this.isLive = false,
    this.teacher,
    this.category,
    this.subject,
    this.classInfo,
  });

  final int id;
  final String title;
  final String? description;
  final String? thumbnail;
  final double price;
  final double? oldPrice;
  final bool isFree;
  final bool canPurchaseViaStore;
  final int discountPercent;
  final double averageRating;
  final int totalStudents;
  final double durationHours;
  final String? difficultyLevel;
  final bool isLive;
  final TeacherRef? teacher;
  final IdName? category;
  final IdName? subject;
  final IdName? classInfo;

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    thumbnail,
    price,
    oldPrice,
    isFree,
    canPurchaseViaStore,
    discountPercent,
    averageRating,
    totalStudents,
    durationHours,
    difficultyLevel,
    isLive,
    teacher,
    category,
    subject,
    classInfo,
  ];
}

class Teacher extends Equatable {
  const Teacher({
    required this.id,
    required this.name,
    this.specialization,
    this.avatar,
    this.yearsOfExperience = 0,
    this.averageRating = 0,
    this.totalStudents = 0,
    this.totalCourses = 0,
    this.isVerified = false,
  });

  final int id;
  final String name;
  final String? specialization;
  final String? avatar;
  final int yearsOfExperience;
  final double averageRating;
  final int totalStudents;
  final int totalCourses;
  final bool isVerified;

  @override
  List<Object?> get props => [
    id,
    name,
    specialization,
    avatar,
    yearsOfExperience,
    averageRating,
    totalStudents,
    totalCourses,
    isVerified,
  ];
}
