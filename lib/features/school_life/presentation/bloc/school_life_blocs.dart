import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ibnzaidon/core/bloc/resource_bloc.dart';
import 'package:ibnzaidon/core/bloc/submission_status.dart';
import 'package:ibnzaidon/core/error/failure.dart';
import 'package:ibnzaidon/core/usecase/usecase.dart';
import 'package:ibnzaidon/features/school_life/domain/entities/school_record.dart';
import 'package:ibnzaidon/features/school_life/domain/usecases/school_life_usecases.dart';

class SchoolRecordsBloc extends ResourceBloc<List<SchoolRecord>> {
  SchoolRecordsBloc(this._getRecords, {required this.kind});

  final GetSchoolRecordsUseCase _getRecords;
  final SchoolRecordKind kind;

  @override
  Future<Either<Failure, List<SchoolRecord>>> load() => _getRecords(kind);
}

final class ConductState extends Equatable {
  const ConductState({
    this.status = ResourceStatus.initial,
    this.overview,
    this.signing = SubmissionStatus.idle,
    this.failure,
  });

  final ResourceStatus status;
  final ConductOverview? overview;
  final SubmissionStatus signing;
  final Failure? failure;

  @override
  List<Object?> get props => [status, overview, signing, failure];
}

sealed class ConductEvent {
  const ConductEvent();
}

final class ConductRequested extends ConductEvent {
  const ConductRequested();
}

final class ConductSignRequested extends ConductEvent {
  const ConductSignRequested();
}

class ConductBloc extends Bloc<ConductEvent, ConductState> {
  ConductBloc({
    required GetConductUseCase getConduct,
    required SignConductUseCase signConduct,
  }) : _getConduct = getConduct,
       _signConduct = signConduct,
       super(const ConductState()) {
    on<ConductRequested>(_onRequested, transformer: restartable());
    on<ConductSignRequested>(_onSign, transformer: droppable());
  }

  final GetConductUseCase _getConduct;
  final SignConductUseCase _signConduct;

  Future<void> _onRequested(
    ConductRequested event,
    Emitter<ConductState> emit,
  ) async {
    emit(const ConductState(status: ResourceStatus.loading));
    final result = await _getConduct(const NoParams());
    emit(
      result.fold(
        (failure) =>
            ConductState(status: ResourceStatus.failure, failure: failure),
        (overview) =>
            ConductState(status: ResourceStatus.success, overview: overview),
      ),
    );
  }

  Future<void> _onSign(
    ConductSignRequested event,
    Emitter<ConductState> emit,
  ) async {
    final overview = state.overview;
    if (overview == null) return;
    emit(
      ConductState(
        status: ResourceStatus.success,
        overview: overview,
        signing: SubmissionStatus.submitting,
      ),
    );
    final result = await _signConduct(const NoParams());
    emit(
      result.fold(
        (failure) => ConductState(
          status: ResourceStatus.success,
          overview: overview,
          signing: SubmissionStatus.failure,
          failure: failure,
        ),
        (status) => ConductState(
          status: ResourceStatus.success,
          overview: ConductOverview(
            document: overview.document,
            status: status,
          ),
          signing: SubmissionStatus.success,
        ),
      ),
    );
  }
}
