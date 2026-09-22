import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ibnzaidon/core/error/failure.dart';
import 'package:ibnzaidon/core/network/locale_code_provider.dart';

enum ResourceStatus { initial, loading, success, failure }

final class ResourceState<T> extends Equatable {
  const ResourceState({
    this.status = ResourceStatus.initial,
    this.data,
    this.failure,
  });

  final ResourceStatus status;
  final T? data;
  final Failure? failure;

  bool get isLoading =>
      status == ResourceStatus.loading || status == ResourceStatus.initial;
  bool get hasData => data != null;

  ResourceState<T> copyWith({
    ResourceStatus? status,
    T? data,
    Failure? failure,
    bool clearFailure = false,
  }) => ResourceState<T>(
    status: status ?? this.status,
    data: data ?? this.data,
    failure: clearFailure ? null : failure ?? this.failure,
  );

  @override
  List<Object?> get props => [status, data, failure];
}

sealed class ResourceEvent {
  const ResourceEvent();
}

final class ResourceRequested extends ResourceEvent {
  const ResourceRequested();
}

final class ResourceRefreshed extends ResourceEvent {
  const ResourceRefreshed();
}

/// Base for screens that load one resource (detail pages, home sections).
abstract class ResourceBloc<T> extends Bloc<ResourceEvent, ResourceState<T>> {
  ResourceBloc() : super(ResourceState<T>()) {
    on<ResourceRequested>(
      (event, emit) => _load(emit, showLoading: true),
      transformer: restartable(),
    );
    on<ResourceRefreshed>(
      (event, emit) => _load(emit, showLoading: state.data == null),
      transformer: restartable(),
    );
    _localeSubscription = LocaleChanges.stream.listen((_) {
      if (state.status != ResourceStatus.initial) {
        add(const ResourceRefreshed());
      }
    });
  }

  late final StreamSubscription<String> _localeSubscription;

  Future<Either<Failure, T>> load();

  @override
  Future<void> close() async {
    await _localeSubscription.cancel();
    return super.close();
  }

  Future<void> _load(
    Emitter<ResourceState<T>> emit, {
    required bool showLoading,
  }) async {
    if (showLoading) {
      emit(state.copyWith(status: ResourceStatus.loading, clearFailure: true));
    }
    final result = await load();
    if (emit.isDone) return;
    emit(
      result.fold(
        (failure) =>
            state.copyWith(status: ResourceStatus.failure, failure: failure),
        (data) => state.copyWith(
          status: ResourceStatus.success,
          data: data,
          clearFailure: true,
        ),
      ),
    );
  }
}
