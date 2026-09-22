import 'package:equatable/equatable.dart';
import 'package:ibnzaidon/features/courses/domain/entities/course_content.dart';

/// Lesson row from `GET courses/{id}/units` (with lock state).
class UnitLesson extends Equatable {
  const UnitLesson({
    required this.id,
    required this.title,
    required this.type,
    this.durationMinutes = 0,
    this.orderIndex = 0,
    this.isFree = false,
    this.isLocked = false,
    this.isLockedBySequence = false,
    this.videoUrl,
    this.fileUrl,
  });

  final int id;
  final String title;
  final LessonType type;
  final int durationMinutes;
  final int orderIndex;
  final bool isFree;
  final bool isLocked;
  final bool isLockedBySequence;
  final String? videoUrl;
  final String? fileUrl;

  @override
  List<Object?> get props => [
    id,
    title,
    type,
    durationMinutes,
    orderIndex,
    isFree,
    isLocked,
    isLockedBySequence,
    videoUrl,
    fileUrl,
  ];
}

class UnitExam extends Equatable {
  const UnitExam({
    required this.id,
    required this.title,
    this.durationMinutes = 0,
    this.totalQuestions = 0,
    this.totalMarks = 0,
  });

  final int id;
  final String title;
  final int durationMinutes;
  final int totalQuestions;
  final double totalMarks;

  @override
  List<Object?> get props => [
    id,
    title,
    durationMinutes,
    totalQuestions,
    totalMarks,
  ];
}

class CourseUnit extends Equatable {
  const CourseUnit({
    required this.id,
    required this.title,
    required this.orderIndex,
    this.description,
    this.lessons = const [],
    this.exams = const [],
  });

  final int id;
  final String title;
  final String? description;
  final int orderIndex;
  final List<UnitLesson> lessons;
  final List<UnitExam> exams;

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    orderIndex,
    lessons,
    exams,
  ];
}

class CourseUnits extends Equatable {
  const CourseUnits({
    required this.courseId,
    required this.courseName,
    required this.isEnrolled,
    required this.units,
  });

  final int courseId;
  final String courseName;
  final bool isEnrolled;
  final List<CourseUnit> units;

  /// Lessons in reading order, used for next/previous navigation.
  List<UnitLesson> get orderedLessons => [
    for (final unit in units) ...unit.lessons,
  ];

  @override
  List<Object?> get props => [courseId, courseName, isEnrolled, units];
}

/// `GET courses/{id}/my-progress`.
class CourseProgress extends Equatable {
  const CourseProgress({
    this.percentage = 0,
    this.completedLessons = 0,
    this.totalLessons = 0,
    this.completedExams = 0,
    this.totalExams = 0,
    this.completedLessonIds = const {},
    this.watchPositions = const {},
  });

  /// 0..1
  final double percentage;
  final int completedLessons;
  final int totalLessons;
  final int completedExams;
  final int totalExams;
  final Set<int> completedLessonIds;
  final Map<int, WatchPosition> watchPositions;

  @override
  List<Object?> get props => [
    percentage,
    completedLessons,
    totalLessons,
    completedExams,
    totalExams,
    completedLessonIds,
    watchPositions,
  ];
}

class WatchPosition extends Equatable {
  const WatchPosition({required this.watchSeconds, required this.isCompleted});

  final int watchSeconds;
  final bool isCompleted;

  @override
  List<Object?> get props => [watchSeconds, isCompleted];
}
