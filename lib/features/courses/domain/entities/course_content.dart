import 'package:equatable/equatable.dart';
import 'package:ibnzaidon/shared/domain/entities/course.dart';

export 'package:ibnzaidon/features/courses/domain/entities/course_enrollment.dart';
export 'package:ibnzaidon/features/courses/domain/entities/course_units.dart';

enum LessonType {
  video,
  pdf,
  other;

  static LessonType parse(String? raw) => switch (raw?.toLowerCase()) {
    'video' => LessonType.video,
    'pdf' || 'file' || 'document' => LessonType.pdf,
    _ => LessonType.other,
  };
}

/// Lesson row inside `GET courses/{id}` (public outline, no lock info).
class LessonOutline extends Equatable {
  const LessonOutline({
    required this.id,
    required this.title,
    required this.type,
    this.durationMinutes = 0,
    this.orderIndex = 0,
    this.isFree = false,
  });

  final int id;
  final String title;
  final LessonType type;
  final int durationMinutes;
  final int orderIndex;
  final bool isFree;

  @override
  List<Object?> get props => [
    id,
    title,
    type,
    durationMinutes,
    orderIndex,
    isFree,
  ];
}

class UnitOutline extends Equatable {
  const UnitOutline({
    required this.id,
    required this.title,
    required this.orderIndex,
    required this.lessons,
  });

  final int id;
  final String title;
  final int orderIndex;
  final List<LessonOutline> lessons;

  @override
  List<Object?> get props => [id, title, orderIndex, lessons];
}

class CourseDetail extends Equatable {
  const CourseDetail({
    required this.course,
    this.whatYouLearn = const [],
    this.requirements = const [],
    this.totalVideos = 0,
    this.totalPdfs = 0,
    this.sequential = false,
    this.enrollmentsCount = 0,
    this.units = const [],
    this.isEnrolled = false,
    this.progress = 0,
  });

  final Course course;
  final List<String> whatYouLearn;
  final List<String> requirements;
  final int totalVideos;
  final int totalPdfs;
  final bool sequential;
  final int enrollmentsCount;
  final List<UnitOutline> units;
  final bool isEnrolled;

  /// Normalized to 0..1.
  final double progress;

  int get totalLessons =>
      units.fold(0, (sum, unit) => sum + unit.lessons.length);

  CourseDetail copyWith({bool? isEnrolled, double? progress}) => CourseDetail(
    course: course,
    whatYouLearn: whatYouLearn,
    requirements: requirements,
    totalVideos: totalVideos,
    totalPdfs: totalPdfs,
    sequential: sequential,
    enrollmentsCount: enrollmentsCount,
    units: units,
    isEnrolled: isEnrolled ?? this.isEnrolled,
    progress: progress ?? this.progress,
  );

  @override
  List<Object?> get props => [
    course,
    whatYouLearn,
    requirements,
    totalVideos,
    totalPdfs,
    sequential,
    enrollmentsCount,
    units,
    isEnrolled,
    progress,
  ];
}
