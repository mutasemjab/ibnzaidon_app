import 'package:equatable/equatable.dart';
import 'package:ibnzaidon/features/courses/domain/entities/course_content.dart';

class Lesson extends Equatable {
  const Lesson({
    required this.id,
    required this.title,
    required this.type,
    this.videoUrl,
    this.fileUrl,
    this.durationMinutes = 0,
    this.isFree = false,
    this.isEnrolled = false,
    this.unitId,
    this.courseId,
  });

  final int id;
  final String title;
  final LessonType type;
  final String? videoUrl;
  final String? fileUrl;
  final int durationMinutes;
  final bool isFree;
  final bool isEnrolled;
  final int? unitId;
  final int? courseId;

  @override
  List<Object?> get props => [
    id,
    title,
    type,
    videoUrl,
    fileUrl,
    durationMinutes,
    isFree,
    isEnrolled,
    unitId,
    courseId,
  ];
}

class LessonProgressResult extends Equatable {
  const LessonProgressResult({
    required this.lessonId,
    required this.watchSeconds,
    required this.isCompleted,
    this.coursePercentage,
  });

  final int lessonId;
  final int watchSeconds;
  final bool isCompleted;

  /// 0..1, when the server returns course progress.
  final double? coursePercentage;

  @override
  List<Object?> get props => [
    lessonId,
    watchSeconds,
    isCompleted,
    coursePercentage,
  ];
}

class LessonProgressUpdate extends Equatable {
  const LessonProgressUpdate({
    required this.lessonId,
    this.watchSeconds,
    this.isCompleted,
  });

  final int lessonId;
  final int? watchSeconds;
  final bool? isCompleted;

  @override
  List<Object?> get props => [lessonId, watchSeconds, isCompleted];
}
