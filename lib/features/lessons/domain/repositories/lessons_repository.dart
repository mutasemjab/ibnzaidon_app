import 'package:fpdart/fpdart.dart';
import 'package:ibnzaidon/core/error/failure.dart';
import 'package:ibnzaidon/features/lessons/domain/entities/lesson.dart';

abstract interface class LessonsRepository {
  Future<Either<Failure, Lesson>> getLesson(int id);
  Future<Either<Failure, LessonProgressResult>> reportProgress(
    LessonProgressUpdate update,
  );
}
