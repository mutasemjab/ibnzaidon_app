import 'package:ibnzaidon/core/utils/parsers.dart';
import 'package:ibnzaidon/features/courses/domain/entities/course_content.dart';
import 'package:ibnzaidon/shared/data/models/course_model.dart';

/// Parsers for the courses feature. Backend quirks handled here:
/// `progress` is 0..1 on course detail but 0..100 on my-courses.
abstract final class CourseModels {
  static List<String> _textList(Object? raw) {
    if (raw is List) {
      return [
        for (final item in raw)
          if (tryParseString(item) != null) tryParseString(item)!,
      ];
    }
    final text = tryParseString(raw);
    if (text == null) return const [];
    return text
        .split(RegExp(r'[\r\n]+|\|'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
  }

  static LessonOutline lessonOutline(Map<String, dynamic> json) =>
      LessonOutline(
        id: parseInt(json['id']),
        title: parseString(json['title']),
        type: LessonType.parse(tryParseString(json['lesson_type'])),
        durationMinutes: parseInt(json['duration_minutes']),
        orderIndex: parseInt(json['order_index']),
        isFree: parseBool(json['is_free']),
      );

  static UnitOutline unitOutline(Map<String, dynamic> json) => UnitOutline(
    id: parseInt(json['id']),
    title: parseString(json['title']),
    orderIndex: parseInt(json['order_index']),
    lessons: mapList(json['lessons'], lessonOutline),
  );

  static CourseDetail courseDetail(Map<String, dynamic> json) {
    final courseJson = asMap(json['course']) ?? json;
    return CourseDetail(
      course: CourseModel.fromJson(courseJson),
      whatYouLearn: _textList(courseJson['what_you_learn']),
      requirements: _textList(courseJson['requirements']),
      totalVideos: parseInt(courseJson['total_videos']),
      totalPdfs: parseInt(courseJson['total_pdfs']),
      sequential: parseBool(courseJson['sequential']),
      enrollmentsCount: parseInt(courseJson['enrollments_count']),
      units: mapList(courseJson['units'], unitOutline),
      isEnrolled: parseBool(courseJson['is_enrolled'] ?? json['is_enrolled']),
      progress: normalizeProgress(
        courseJson['progress'] ?? json['progress'],
        isPercentage: false,
      ),
    );
  }

  static UnitLesson unitLesson(Map<String, dynamic> json) => UnitLesson(
    id: parseInt(json['id']),
    title: parseString(json['title']),
    type: LessonType.parse(tryParseString(json['lesson_type'])),
    durationMinutes: parseInt(json['duration_minutes']),
    orderIndex: parseInt(json['order_index']),
    isFree: parseBool(json['is_free']),
    isLocked: parseBool(json['is_locked']),
    isLockedBySequence: parseBool(json['is_locked_by_sequence']),
    videoUrl: tryParseString(json['video_url']),
    fileUrl: tryParseString(json['file_url']),
  );

  static UnitExam unitExam(Map<String, dynamic> json) => UnitExam(
    id: parseInt(json['id']),
    title: parseString(json['title']),
    durationMinutes: parseInt(json['duration_minutes']),
    totalQuestions: parseInt(json['total_questions']),
    totalMarks: parseDouble(json['total_marks']),
  );

  static CourseUnit courseUnit(Map<String, dynamic> json) => CourseUnit(
    id: parseInt(json['id']),
    title: parseString(json['title']),
    description: tryParseString(json['description']),
    orderIndex: parseInt(json['order_index']),
    lessons: mapList(json['lessons'], unitLesson),
    exams: mapList(json['exams'], unitExam),
  );

  static CourseUnits courseUnits(Map<String, dynamic> data) => CourseUnits(
    courseId: parseInt(data['course_id']),
    courseName: parseString(data['course_name']),
    isEnrolled: parseBool(data['is_enrolled']),
    units: mapList(data['units'], courseUnit),
  );

  static CourseProgress courseProgress(Map<String, dynamic> data) {
    final positions = <int, WatchPosition>{};
    final rawPositions = asMap(data['watch_positions']);
    if (rawPositions != null) {
      for (final entry in rawPositions.entries) {
        final lessonId = int.tryParse(entry.key);
        final value = asMap(entry.value);
        if (lessonId == null || value == null) continue;
        positions[lessonId] = WatchPosition(
          watchSeconds: parseInt(value['watch_seconds']),
          isCompleted: parseBool(value['is_completed']),
        );
      }
    }
    return CourseProgress(
      percentage: normalizeProgress(data['percentage'], isPercentage: true),
      completedLessons: parseInt(data['completed_lessons']),
      totalLessons: parseInt(data['total_lessons']),
      completedExams: parseInt(data['completed_exams']),
      totalExams: parseInt(data['total_exams']),
      completedLessonIds: {
        for (final id in asList(data['completed_lesson_ids']))
          if (tryParseInt(id) != null) tryParseInt(id)!,
      },
      watchPositions: positions,
    );
  }

  static String? _nameOf(Object? raw) {
    final map = asMap(raw);
    return map == null ? tryParseString(raw) : tryParseString(map['name']);
  }

  static Enrollment enrollment(Map<String, dynamic> json) {
    final course = asMap(json['course']) ?? const <String, dynamic>{};
    return Enrollment(
      enrollmentId: parseInt(json['enrollment_id'] ?? json['id']),
      enrolledAt: tryParseDate(json['enrolled_at']),
      progress: normalizeProgress(
        json['progress_percentage'],
        isPercentage: true,
      ),
      isCompleted: parseBool(json['is_completed']),
      completedAt: tryParseDate(json['completed_at']),
      course: EnrolledCourse(
        id: parseInt(course['id']),
        title: parseString(course['title']),
        thumbnail: tryParseString(course['thumbnail']),
        durationHours: parseDouble(course['duration_hours']),
        difficultyLevel: tryParseString(course['difficulty_level']),
        teacherName: _nameOf(course['teacher']),
        subjectName: _nameOf(course['subject']),
      ),
    );
  }

  static ActivationResult activation(Map<String, dynamic> data) =>
      ActivationResult(
        courseId: parseInt(data['course_id']),
        courseName: parseString(data['course_name']),
      );

  static PurchaseVerification purchaseVerification(Map<String, dynamic> data) =>
      PurchaseVerification(
        courseId: parseInt(data['course_id']),
        transactionId: parseString(data['transaction_id']),
        isEnrolled: parseBool(data['is_enrolled']),
        environment: tryParseString(data['environment']),
      );
}
