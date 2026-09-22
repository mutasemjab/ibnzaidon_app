import 'package:equatable/equatable.dart';

class EnrolledCourse extends Equatable {
  const EnrolledCourse({
    required this.id,
    required this.title,
    this.thumbnail,
    this.durationHours = 0,
    this.difficultyLevel,
    this.teacherName,
    this.subjectName,
  });

  final int id;
  final String title;
  final String? thumbnail;
  final double durationHours;
  final String? difficultyLevel;
  final String? teacherName;
  final String? subjectName;

  @override
  List<Object?> get props => [
    id,
    title,
    thumbnail,
    durationHours,
    difficultyLevel,
    teacherName,
    subjectName,
  ];
}

class Enrollment extends Equatable {
  const Enrollment({
    required this.enrollmentId,
    required this.course,
    this.enrolledAt,
    this.progress = 0,
    this.isCompleted = false,
    this.completedAt,
  });

  final int enrollmentId;
  final EnrolledCourse course;
  final DateTime? enrolledAt;

  /// Normalized 0..1 (the API sends 0..100).
  final double progress;
  final bool isCompleted;
  final DateTime? completedAt;

  @override
  List<Object?> get props => [
    enrollmentId,
    course,
    enrolledAt,
    progress,
    isCompleted,
    completedAt,
  ];
}

class CourseQuery extends Equatable {
  const CourseQuery({
    this.search = '',
    this.categoryId,
    this.subjectId,
    this.teacherId,
    this.featured = false,
    this.trending = false,
  });

  final String search;
  final int? categoryId;
  final int? subjectId;
  final int? teacherId;
  final bool featured;
  final bool trending;

  bool get hasFilters =>
      categoryId != null ||
      subjectId != null ||
      teacherId != null ||
      featured ||
      trending;

  CourseQuery copyWith({
    String? search,
    int? categoryId,
    int? subjectId,
    int? teacherId,
    bool? featured,
    bool? trending,
    bool clearCategory = false,
    bool clearSubject = false,
    bool clearTeacher = false,
  }) => CourseQuery(
    search: search ?? this.search,
    categoryId: clearCategory ? null : categoryId ?? this.categoryId,
    subjectId: clearSubject ? null : subjectId ?? this.subjectId,
    teacherId: clearTeacher ? null : teacherId ?? this.teacherId,
    featured: featured ?? this.featured,
    trending: trending ?? this.trending,
  );

  @override
  List<Object?> get props => [
    search,
    categoryId,
    subjectId,
    teacherId,
    featured,
    trending,
  ];
}

class ActivationResult extends Equatable {
  const ActivationResult({required this.courseId, required this.courseName});

  final int courseId;
  final String courseName;

  @override
  List<Object?> get props => [courseId, courseName];
}

/// Everything `POST purchases/apple/verify` needs.
class ApplePurchaseProof extends Equatable {
  const ApplePurchaseProof({
    required this.courseId,
    required this.productId,
    required this.transactionId,
    required this.signedTransaction,
    required this.purchaseToken,
    this.transactionDate,
  });

  final int courseId;
  final String productId;
  final String transactionId;
  final String signedTransaction;

  /// `student.app_account_token` (UUID).
  final String purchaseToken;
  final String? transactionDate;

  @override
  List<Object?> get props => [
    courseId,
    productId,
    transactionId,
    signedTransaction,
    purchaseToken,
    transactionDate,
  ];
}

class PurchaseVerification extends Equatable {
  const PurchaseVerification({
    required this.courseId,
    required this.transactionId,
    required this.isEnrolled,
    this.environment,
  });

  final int courseId;
  final String transactionId;
  final bool isEnrolled;
  final String? environment;

  @override
  List<Object?> get props => [courseId, transactionId, isEnrolled, environment];
}
