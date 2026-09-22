import 'package:fpdart/fpdart.dart';
import 'package:ibnzaidon/core/error/failure.dart';
import 'package:ibnzaidon/core/network/api_client.dart';
import 'package:ibnzaidon/core/network/api_guard.dart';
import 'package:ibnzaidon/core/utils/parsers.dart';
import 'package:ibnzaidon/features/courses/domain/entities/course_content.dart';
import 'package:ibnzaidon/features/lessons/domain/entities/lesson.dart';
import 'package:ibnzaidon/features/lessons/domain/repositories/lessons_repository.dart';

class LessonsRepositoryImpl implements LessonsRepository {
  const LessonsRepositoryImpl({
    required ApiClient client,
    required ApiGuard guard,
  }) : _client = client,
       _guard = guard;

  final ApiClient _client;
  final ApiGuard _guard;

  @override
  Future<Either<Failure, Lesson>> getLesson(int id) => _guard.run(() async {
    final data = (await _client.get('lessons/$id')).dataMap;
    final json = asMap(data['lesson']) ?? data;
    return Lesson(
      id: parseInt(json['id']),
      title: parseString(json['title']),
      type: LessonType.parse(tryParseString(json['lesson_type'])),
      videoUrl: tryParseString(json['video_url']),
      fileUrl: tryParseString(json['file_url']),
      durationMinutes: parseInt(json['duration_minutes']),
      isFree: parseBool(json['is_free']),
      isEnrolled: parseBool(json['is_enrolled']),
      unitId: tryParseInt(json['unit_id']),
      courseId: tryParseInt(json['course_id']),
    );
  });

  @override
  Future<Either<Failure, LessonProgressResult>> reportProgress(
    LessonProgressUpdate update,
  ) => _guard.run(() async {
    final data = (await _client.post(
      'lessons/${update.lessonId}/progress',
      body: {
        if (update.watchSeconds != null) 'watch_seconds': update.watchSeconds,
        if (update.isCompleted != null) 'is_completed': update.isCompleted,
      },
    )).dataMap;
    final course = asMap(data['course_progress']);
    return LessonProgressResult(
      lessonId: parseInt(data['lesson_id'], fallback: update.lessonId),
      watchSeconds: parseInt(data['watch_seconds']),
      isCompleted: parseBool(data['is_completed']),
      coursePercentage: course == null
          ? null
          : normalizeProgress(course['percentage'], isPercentage: true),
    );
  });
}
