import 'package:ibnzaidon/app/router/app_routes.dart';
import 'package:ibnzaidon/core/utils/parsers.dart';

/// Maps a notification `type` + `data` payload to an in-app route.
///
/// Assumption (unverified with the backend): `data` carries `course_id`,
/// `lesson_id`, `exam_id` or `teacher_id`. Unknown shapes fall back to the
/// notifications list.
abstract final class NotificationLinkResolver {
  static String resolve(String? type, Map<String, Object?> data) {
    final courseId = tryParseInt(data['course_id']);
    final lessonId = tryParseInt(data['lesson_id']);
    final examId = tryParseInt(data['exam_id']);
    final teacherId = tryParseInt(data['teacher_id']);
    final kind = (type ?? '').toLowerCase();

    if (lessonId != null && courseId != null) {
      return AppRoutes.lesson(courseId, lessonId);
    }
    if (examId != null) return AppRoutes.exam(examId);
    if (courseId != null) return AppRoutes.course(courseId);
    if (teacherId != null) return AppRoutes.teacher(teacherId);
    if (kind.contains('announcement')) return AppRoutes.announcements;
    return AppRoutes.notifications;
  }
}
