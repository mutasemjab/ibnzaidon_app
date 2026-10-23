import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:ibnzaidon/core/bloc/resource_bloc.dart';
import 'package:ibnzaidon/core/error/failure.dart';
import 'package:ibnzaidon/features/packages/domain/entities/package.dart';
import 'package:ibnzaidon/features/packages/domain/usecases/packages_usecases.dart';

final class PackageDetailState extends Equatable {
  const PackageDetailState({
    this.status = ResourceStatus.initial,
    this.detail,
    this.selectedCourseIds = const {},
    this.failure,
  });

  final ResourceStatus status;
  final PackageDetail? detail;

  /// Course ids the student has checked so far, capped at
  /// `detail.package.pickCount`.
  final Set<int> selectedCourseIds;
  final Failure? failure;

  bool get isLoading =>
      status == ResourceStatus.initial || status == ResourceStatus.loading;

  bool get canActivate =>
      detail != null && selectedCourseIds.length == detail!.package.pickCount;

  PackageDetailState copyWith({
    ResourceStatus? status,
    PackageDetail? detail,
    Set<int>? selectedCourseIds,
    Failure? failure,
    bool clearFailure = false,
  }) => PackageDetailState(
    status: status ?? this.status,
    detail: detail ?? this.detail,
    selectedCourseIds: selectedCourseIds ?? this.selectedCourseIds,
    failure: clearFailure ? null : failure ?? this.failure,
  );

  @override
  List<Object?> get props => [status, detail, selectedCourseIds, failure];
}

sealed class PackageDetailEvent extends Equatable {
  const PackageDetailEvent();

  @override
  List<Object?> get props => [];
}

final class PackageDetailRequested extends PackageDetailEvent {
  const PackageDetailRequested();
}

final class PackageCourseToggled extends PackageDetailEvent {
  const PackageCourseToggled(this.courseId);

  final int courseId;

  @override
  List<Object?> get props => [courseId];
}

class PackageDetailBloc extends Bloc<PackageDetailEvent, PackageDetailState> {
  PackageDetailBloc(this._getPackageDetail, {required this.packageId})
    : super(const PackageDetailState()) {
    on<PackageDetailRequested>(_onRequested, transformer: restartable());
    on<PackageCourseToggled>(_onToggled);
  }

  final int packageId;
  final GetPackageDetailUseCase _getPackageDetail;

  Future<void> _onRequested(
    PackageDetailRequested event,
    Emitter<PackageDetailState> emit,
  ) async {
    emit(state.copyWith(status: ResourceStatus.loading, clearFailure: true));
    final result = await _getPackageDetail(packageId);
    emit(
      result.fold(
        (failure) =>
            state.copyWith(status: ResourceStatus.failure, failure: failure),
        (detail) => state.copyWith(
          status: ResourceStatus.success,
          detail: detail,
          clearFailure: true,
        ),
      ),
    );
  }

  /// Unchecking always works; checking a new course is ignored once
  /// `pickCount` is already reached instead of bumping something else off —
  /// the student has to uncheck one first, same as most "pick N" pickers.
  void _onToggled(
    PackageCourseToggled event,
    Emitter<PackageDetailState> emit,
  ) {
    final detail = state.detail;
    if (detail == null) return;
    final selected = {...state.selectedCourseIds};
    if (!selected.remove(event.courseId)) {
      if (selected.length >= detail.package.pickCount) return;
      selected.add(event.courseId);
    }
    emit(state.copyWith(selectedCourseIds: selected));
  }
}
