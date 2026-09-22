import 'package:fpdart/fpdart.dart';
import 'package:ibnzaidon/core/bloc/paged_bloc.dart';
import 'package:ibnzaidon/core/error/failure.dart';
import 'package:ibnzaidon/features/library/domain/entities/library_item.dart';
import 'package:ibnzaidon/features/library/domain/usecases/library_usecases.dart';
import 'package:ibnzaidon/shared/domain/paged_list.dart';

/// One bloc class for all three file libraries; [kind] picks the endpoint.
class LibraryBloc extends PagedBloc<LibraryItem, LibraryQuery> {
  LibraryBloc(this._getItems, {required this.kind})
    : super(initialQuery: const LibraryQuery());

  final GetLibraryItemsUseCase _getItems;
  final LibraryKind kind;

  @override
  Future<Either<Failure, PagedList<LibraryItem>>> fetchPage(
    int page,
    LibraryQuery query,
  ) => _getItems(LibraryPageParams(kind: kind, page: page, query: query));
}
