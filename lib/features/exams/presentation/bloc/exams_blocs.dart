import 'package:fpdart/fpdart.dart';
import 'package:ibnzaidon/core/bloc/paged_bloc.dart';
import 'package:ibnzaidon/core/bloc/resource_bloc.dart';
import 'package:ibnzaidon/core/error/failure.dart';
import 'package:ibnzaidon/features/exams/domain/entities/exam_entities.dart';
import 'package:ibnzaidon/features/exams/domain/usecases/exams_usecases.dart';
import 'package:ibnzaidon/shared/domain/paged_list.dart';

class ExamsBloc extends PagedBloc<Exam, ExamQuery> {
  ExamsBloc(this._getExams, {super.initialQuery = const ExamQuery()});

  final GetExamsUseCase _getExams;

  @override
  Future<Either<Failure, PagedList<Exam>>> fetchPage(
    int page,
    ExamQuery query,
  ) => _getExams(ExamsPageParams(page: page, query: query));
}

class MyExamsBloc extends PagedBloc<AttemptHistoryItem, NoQuery> {
  MyExamsBloc(this._getMyExams) : super(initialQuery: const NoQuery());

  final GetMyExamsUseCase _getMyExams;

  @override
  Future<Either<Failure, PagedList<AttemptHistoryItem>>> fetchPage(
    int page,
    NoQuery query,
  ) => _getMyExams(page);
}

class ExamDetailBloc extends ResourceBloc<ExamDetail> {
  ExamDetailBloc(this._getExamDetail, {required this.examId});

  final GetExamDetailUseCase _getExamDetail;
  final int examId;

  @override
  Future<Either<Failure, ExamDetail>> load() => _getExamDetail(examId);
}
