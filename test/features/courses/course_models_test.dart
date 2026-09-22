import 'package:flutter_test/flutter_test.dart';
import 'package:ibnzaidon/features/courses/data/models/course_models.dart';
import 'package:ibnzaidon/features/courses/domain/entities/course_content.dart';
import 'package:ibnzaidon/shared/data/models/course_model.dart';

void main() {
  group('CourseModel.fromJson', () {
    test('parses decimals sent as numeric strings and 1/0 booleans', () {
      final course = CourseModel.fromJson(const {
        'id': '7',
        'title': 'Algebra',
        'price': '12.50',
        'old_price': 20,
        'average_rating': '4.75',
        'is_free': 0,
        'can_purchase_via_store': 1,
        'total_students': '1200',
        'duration_hours': '8.5',
        'teacher': {'id': 3, 'name': 'Sami', 'avatar': null},
      });
      expect(course.id, 7);
      expect(course.price, 12.5);
      expect(course.oldPrice, 20.0);
      expect(course.averageRating, 4.75);
      expect(course.isFree, isFalse);
      expect(course.canPurchaseViaStore, isTrue);
      expect(course.totalStudents, 1200);
      expect(course.durationHours, 8.5);
      expect(course.teacher?.name, 'Sami');
      expect(course.teacher?.avatar, isNull);
    });

    test('derives the discount from the old price when omitted', () {
      final course = CourseModel.fromJson(const {
        'id': 1,
        'title': 'x',
        'price': 15,
        'old_price': 20,
      });
      expect(course.discountPercent, 25);
    });

    test('tolerates a completely sparse payload', () {
      final course = CourseModel.fromJson(const {'id': 2});
      expect(course.title, '');
      expect(course.thumbnail, isNull);
      expect(course.price, 0);
    });
  });

  group('CourseModels', () {
    test('course detail progress is 0..1 (not divided)', () {
      final detail = CourseModels.courseDetail({
        'id': 1,
        'title': 'c',
        'progress': 0.4,
        'is_enrolled': true,
        'what_you_learn': ['a', 'b'],
        'requirements': 'one\ntwo',
        'units': [
          {
            'id': 1,
            'title': 'U',
            'order_index': 1,
            'lessons': [
              {'id': 9, 'title': 'L', 'lesson_type': 'video', 'is_free': 1},
            ],
          },
        ],
      });
      expect(detail.progress, 0.4);
      expect(detail.isEnrolled, isTrue);
      expect(detail.whatYouLearn, ['a', 'b']);
      expect(detail.requirements, ['one', 'two']);
      expect(detail.units.single.lessons.single.type, LessonType.video);
      expect(detail.units.single.lessons.single.isFree, isTrue);
    });

    test('my-courses progress_percentage 0..100 is normalized to 0..1', () {
      final enrollment = CourseModels.enrollment({
        'enrollment_id': 5,
        'progress_percentage': 60,
        'is_completed': 0,
        'enrolled_at': '2025-01-02',
        'course': {
          'id': 3,
          'title': 'Physics',
          'teacher': 'Ms. Lina',
          'subject': {'id': 1, 'name': 'Science'},
        },
      });
      expect(enrollment.progress, 0.6);
      expect(enrollment.course.teacherName, 'Ms. Lina');
      expect(enrollment.course.subjectName, 'Science');
      expect(enrollment.enrolledAt, DateTime(2025, 1, 2));
    });

    test('units expose lock flags and ordered lessons', () {
      final units = CourseModels.courseUnits({
        'course_id': 1,
        'course_name': 'c',
        'is_enrolled': 1,
        'units': [
          {
            'id': 1,
            'title': 'u1',
            'lessons': [
              {'id': 1, 'title': 'a', 'is_locked': 0},
              {
                'id': 2,
                'title': 'b',
                'is_locked': 1,
                'is_locked_by_sequence': 1,
              },
            ],
            'exams': [
              {'id': 9, 'title': 'quiz', 'total_marks': '10.5'},
            ],
          },
        ],
      });
      expect(units.isEnrolled, isTrue);
      expect(units.orderedLessons.map((l) => l.id), [1, 2]);
      expect(units.orderedLessons.last.isLockedBySequence, isTrue);
      expect(units.units.single.exams.single.totalMarks, 10.5);
    });

    test('my-progress parses watch positions keyed by lesson id', () {
      final progress = CourseModels.courseProgress({
        'percentage': 50,
        'completed_lesson_ids': [1, '2'],
        'watch_positions': {
          '3': {'watch_seconds': 95, 'is_completed': 0},
        },
      });
      expect(progress.percentage, 0.5);
      expect(progress.completedLessonIds, {1, 2});
      expect(progress.watchPositions[3]?.watchSeconds, 95);
    });
  });
}
