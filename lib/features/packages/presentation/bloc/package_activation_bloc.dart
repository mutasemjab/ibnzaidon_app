import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:ibnzaidon/core/bloc/submission_status.dart';
import 'package:ibnzaidon/core/error/failure.dart';
import 'package:ibnzaidon/features/packages/domain/entities/package.dart';
import 'package:ibnzaidon/features/packages/domain/usecases/packages_usecases.dart';

final class PackageActivationSubmitted extends Equatable {
  const PackageActivationSubmitted(this.cardCode);

  final String cardCode;

  @override
  List<Object?> get props => [cardCode];
}

final class PackageActivationState extends Equatable {
  const PackageActivationState({
    this.status = SubmissionStatus.idle,
    this.result,
    this.failure,
  });

  final SubmissionStatus status;
  final PackageActivationResult? result;
  final Failure? failure;

  @override
  List<Object?> get props => [status, result, failure];
}

/// Card (scratch code) activation for one package. `packageId` and the
/// confirmed `courseIds` are fixed at construction — selection itself lives
/// on `PackageDetailBloc`, this bloc only submits the already-validated pick.
class PackageActivationBloc
    extends Bloc<PackageActivationSubmitted, PackageActivationState> {
  PackageActivationBloc({
    required this.packageId,
    required this.courseIds,
    required ActivatePackageUseCase activatePackage,
  }) : _activatePackage = activatePackage,
       super(const PackageActivationState()) {
    on<PackageActivationSubmitted>(_onSubmitted, transformer: droppable());
  }

  final int packageId;
  final List<int> courseIds;
  final ActivatePackageUseCase _activatePackage;

  Future<void> _onSubmitted(
    PackageActivationSubmitted event,
    Emitter<PackageActivationState> emit,
  ) async {
    emit(const PackageActivationState(status: SubmissionStatus.submitting));
    final result = await _activatePackage(
      ActivatePackageParams(
        packageId: packageId,
        cardCode: event.cardCode,
        courseIds: courseIds,
      ),
    );
    emit(
      result.fold(
        (failure) => PackageActivationState(
          status: SubmissionStatus.failure,
          failure: failure,
        ),
        (activation) => PackageActivationState(
          status: SubmissionStatus.success,
          result: activation,
        ),
      ),
    );
  }
}
