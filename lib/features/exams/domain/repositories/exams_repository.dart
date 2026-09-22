import 'package:fpdart/fpdart.dart';
import 'package:ibnzaidon/core/error/failure.dart';
import 'package:ibnzaidon/features/exams/domain/entities/exam_entities.dart';
import 'package:ibnzaidon/shared/domain/paged_list.dart';

abstract interface class ExamsRepository {
  Future<Either<Failure, PagedList<Exam>>> getExams(int page, ExamQuery query);
  Future<Either<Failure, ExamDetail>> getExamDetail(int id);
  Future<Either<Failure, ExamAttemptSession>> startExam(int id);
  Future<Either<Failure, ExamResult>> submitAttempt(
    int attemptId,
    Map<int, int> answers,
  );
  Future<Either<Failure, PagedList<AttemptHistoryItem>>> getMyExams(int page);
}

abstract interface class ExamDraftRepository {
  ExamDraft? load(int attemptId);
  Future<void> save(int attemptId, ExamDraft draft);
  Future<void> clear(int attemptId);
}
