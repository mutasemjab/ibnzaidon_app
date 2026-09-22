import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ibnzaidon/core/error/failure.dart';
import 'package:ibnzaidon/core/usecase/usecase.dart';
import 'package:ibnzaidon/features/exams/domain/entities/exam_entities.dart';
import 'package:ibnzaidon/features/exams/domain/repositories/exams_repository.dart';
import 'package:ibnzaidon/shared/domain/paged_list.dart';

final class ExamsPageParams extends Equatable {
  const ExamsPageParams({required this.page, required this.query});

  final int page;
  final ExamQuery query;

  @override
  List<Object?> get props => [page, query];
}

class GetExamsUseCase implements UseCase<PagedList<Exam>, ExamsPageParams> {
  const GetExamsUseCase(this._repository);

  final ExamsRepository _repository;

  @override
  Future<Either<Failure, PagedList<Exam>>> call(ExamsPageParams params) =>
      _repository.getExams(params.page, params.query);
}

class GetExamDetailUseCase implements UseCase<ExamDetail, int> {
  const GetExamDetailUseCase(this._repository);

  final ExamsRepository _repository;

  @override
  Future<Either<Failure, ExamDetail>> call(int examId) =>
      _repository.getExamDetail(examId);
}

class StartExamUseCase implements UseCase<ExamAttemptSession, int> {
  const StartExamUseCase(this._repository);

  final ExamsRepository _repository;

  @override
  Future<Either<Failure, ExamAttemptSession>> call(int examId) =>
      _repository.startExam(examId);
}

final class SubmitAttemptParams extends Equatable {
  const SubmitAttemptParams({required this.attemptId, required this.answers});

  final int attemptId;

  /// question id -> option id
  final Map<int, int> answers;

  @override
  List<Object?> get props => [attemptId, answers];
}

class SubmitAttemptUseCase implements UseCase<ExamResult, SubmitAttemptParams> {
  const SubmitAttemptUseCase(this._repository);

  final ExamsRepository _repository;

  @override
  Future<Either<Failure, ExamResult>> call(SubmitAttemptParams params) =>
      _repository.submitAttempt(params.attemptId, params.answers);
}

class GetMyExamsUseCase implements UseCase<PagedList<AttemptHistoryItem>, int> {
  const GetMyExamsUseCase(this._repository);

  final ExamsRepository _repository;

  @override
  Future<Either<Failure, PagedList<AttemptHistoryItem>>> call(int page) =>
      _repository.getMyExams(page);
}

/// Local autosave of in-progress answers.
class ExamDraftUseCases {
  const ExamDraftUseCases(this._repository);

  final ExamDraftRepository _repository;

  ExamDraft? load(int attemptId) => _repository.load(attemptId);
  Future<void> save(int attemptId, ExamDraft draft) =>
      _repository.save(attemptId, draft);
  Future<void> clear(int attemptId) => _repository.clear(attemptId);
}
