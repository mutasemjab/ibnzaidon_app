import 'package:fpdart/fpdart.dart';
import 'package:ibnzaidon/core/error/failure.dart';
import 'package:ibnzaidon/core/usecase/usecase.dart';
import 'package:ibnzaidon/features/lessons/domain/entities/lesson.dart';
import 'package:ibnzaidon/features/lessons/domain/repositories/lessons_repository.dart';

class GetLessonUseCase implements UseCase<Lesson, int> {
  const GetLessonUseCase(this._repository);

  final LessonsRepository _repository;

  @override
  Future<Either<Failure, Lesson>> call(int lessonId) =>
      _repository.getLesson(lessonId);
}

class ReportLessonProgressUseCase
    implements UseCase<LessonProgressResult, LessonProgressUpdate> {
  const ReportLessonProgressUseCase(this._repository);

  final LessonsRepository _repository;

  @override
  Future<Either<Failure, LessonProgressResult>> call(
    LessonProgressUpdate update,
  ) => _repository.reportProgress(update);
}
