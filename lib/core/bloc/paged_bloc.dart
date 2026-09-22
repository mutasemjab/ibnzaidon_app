import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ibnzaidon/core/error/failure.dart';
import 'package:ibnzaidon/core/network/locale_code_provider.dart';
import 'package:ibnzaidon/shared/domain/paged_list.dart';

enum PagedStatus { initial, loading, success, failure, loadingMore }

/// Reusable snapshot for every infinite-scroll list in the app.
final class PagedState<T, Q> extends Equatable {
  const PagedState({
    required this.query,
    this.status = PagedStatus.initial,
    this.items = const [],
    this.page = 0,
    this.hasReachedMax = false,
    this.total = 0,
    this.extra = const {},
    this.failure,
  });

  final PagedStatus status;
  final List<T> items;
  final int page;
  final bool hasReachedMax;
  final int total;
  final Q query;
  final Map<String, Object?> extra;
  final Failure? failure;

  bool get isInitialLoading =>
      (status == PagedStatus.loading || status == PagedStatus.initial) &&
      items.isEmpty;
  bool get isEmpty => status == PagedStatus.success && items.isEmpty;
  bool get hasFullScreenFailure =>
      status == PagedStatus.failure && items.isEmpty;
  bool get hasFooterFailure =>
      status == PagedStatus.failure && items.isNotEmpty;

  PagedState<T, Q> copyWith({
    PagedStatus? status,
    List<T>? items,
    int? page,
    bool? hasReachedMax,
    int? total,
    Q? query,
    Map<String, Object?>? extra,
    Failure? failure,
    bool clearFailure = false,
  }) => PagedState<T, Q>(
    status: status ?? this.status,
    items: items ?? this.items,
    page: page ?? this.page,
    hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    total: total ?? this.total,
    query: query ?? this.query,
    extra: extra ?? this.extra,
    failure: clearFailure ? null : failure ?? this.failure,
  );

  @override
  List<Object?> get props => [
    status,
    items,
    page,
    hasReachedMax,
    total,
    query,
    extra,
    failure,
  ];
}

abstract class PagedEvent<Q> extends Equatable {
  const PagedEvent();

  @override
  List<Object?> get props => [];
}

final class PagedStarted<Q> extends PagedEvent<Q> {
  const PagedStarted();
}

final class PagedNextPageRequested<Q> extends PagedEvent<Q> {
  const PagedNextPageRequested();
}

final class PagedRefreshed<Q> extends PagedEvent<Q> {
  const PagedRefreshed();
}

/// [debounce] is used for search boxes: the previous pending event is
/// cancelled if a new one arrives within [PagedBloc.searchDebounce].
final class PagedQueryChanged<Q> extends PagedEvent<Q> {
  const PagedQueryChanged(this.query, {this.debounce = false});

  final Q query;
  final bool debounce;

  @override
  List<Object?> get props => [query, debounce];
}

/// Base for every paginated feature bloc. Subclasses only supply
/// [fetchPage]; ordering/stale-response protection lives here once.
abstract class PagedBloc<T, Q extends Equatable>
    extends Bloc<PagedEvent<Q>, PagedState<T, Q>> {
  PagedBloc({required Q initialQuery})
    : super(PagedState<T, Q>(query: initialQuery)) {
    on<PagedStarted<Q>>(
      (event, emit) => _loadFirst(emit, state.query),
      transformer: restartable(),
    );
    on<PagedRefreshed<Q>>(
      (event, emit) => _loadFirst(emit, state.query, keepItems: true),
      transformer: restartable(),
    );
    on<PagedQueryChanged<Q>>(_onQueryChanged, transformer: restartable());
    on<PagedNextPageRequested<Q>>(_onNextPage, transformer: droppable());
    _localeSubscription = LocaleChanges.stream.listen((_) {
      if (state.status != PagedStatus.initial) add(PagedRefreshed<Q>());
    });
  }

  static const searchDebounce = Duration(milliseconds: 400);

  late final StreamSubscription<String> _localeSubscription;

  @override
  Future<void> close() async {
    await _localeSubscription.cancel();
    return super.close();
  }

  int _ticket = 0;

  Future<Either<Failure, PagedList<T>>> fetchPage(int page, Q query);

  Future<void> _onQueryChanged(
    PagedQueryChanged<Q> event,
    Emitter<PagedState<T, Q>> emit,
  ) async {
    if (event.query == state.query && state.status != PagedStatus.failure) {
      return;
    }
    if (event.debounce) {
      await Future<void>.delayed(searchDebounce);
      if (emit.isDone) return;
    }
    await _loadFirst(emit, event.query);
  }

  Future<void> _loadFirst(
    Emitter<PagedState<T, Q>> emit,
    Q query, {
    bool keepItems = false,
  }) async {
    final ticket = ++_ticket;
    emit(
      state.copyWith(
        status: PagedStatus.loading,
        query: query,
        items: keepItems ? state.items : <T>[],
        page: keepItems ? state.page : 0,
        hasReachedMax: false,
        clearFailure: true,
      ),
    );
    final result = await fetchPage(1, query);
    if (emit.isDone || ticket != _ticket) return;
    emit(
      result.fold(
        (failure) => state.copyWith(
          status: PagedStatus.failure,
          failure: failure,
          items: keepItems ? state.items : <T>[],
        ),
        (page) => state.copyWith(
          status: PagedStatus.success,
          items: page.items,
          page: 1,
          hasReachedMax: !page.hasMore,
          total: page.total,
          extra: page.extra,
          clearFailure: true,
        ),
      ),
    );
  }

  Future<void> _onNextPage(
    PagedNextPageRequested<Q> event,
    Emitter<PagedState<T, Q>> emit,
  ) async {
    if (state.hasReachedMax ||
        state.status == PagedStatus.loading ||
        state.status == PagedStatus.initial) {
      return;
    }
    final ticket = _ticket;
    final nextPage = state.page + 1;
    emit(state.copyWith(status: PagedStatus.loadingMore, clearFailure: true));
    final result = await fetchPage(nextPage, state.query);
    if (emit.isDone || ticket != _ticket) return;
    emit(
      result.fold(
        (failure) =>
            state.copyWith(status: PagedStatus.failure, failure: failure),
        (page) => state.copyWith(
          status: PagedStatus.success,
          items: [...state.items, ...page.items],
          page: nextPage,
          hasReachedMax: !page.hasMore,
          total: page.total,
          extra: page.extra,
        ),
      ),
    );
  }
}

/// Query type for lists that have no filters.
final class NoQuery extends Equatable {
  const NoQuery();

  @override
  List<Object?> get props => [];
}
