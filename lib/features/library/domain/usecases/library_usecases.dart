import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ibnzaidon/core/error/failure.dart';
import 'package:ibnzaidon/core/usecase/usecase.dart';
import 'package:ibnzaidon/features/library/domain/entities/library_item.dart';
import 'package:ibnzaidon/features/library/domain/repositories/library_repositories.dart';
import 'package:ibnzaidon/shared/domain/paged_list.dart';

final class LibraryPageParams extends Equatable {
  const LibraryPageParams({
    required this.kind,
    required this.page,
    required this.query,
  });

  final LibraryKind kind;
  final int page;
  final LibraryQuery query;

  @override
  List<Object?> get props => [kind, page, query];
}

class GetLibraryItemsUseCase
    implements UseCase<PagedList<LibraryItem>, LibraryPageParams> {
  const GetLibraryItemsUseCase(this._repository);

  final LibraryRepository _repository;

  @override
  Future<Either<Failure, PagedList<LibraryItem>>> call(
    LibraryPageParams params,
  ) => _repository.getItems(params.kind, params.page, params.query);
}

class GetCachedPdfUseCase {
  const GetCachedPdfUseCase(this._repository);

  final PdfFileRepository _repository;

  Future<String?> call(String url) => _repository.cachedPath(url);
}

final class DownloadPdfParams {
  const DownloadPdfParams(this.url, {this.onProgress});

  final String url;
  final void Function(double progress)? onProgress;
}

class DownloadPdfUseCase implements UseCase<String, DownloadPdfParams> {
  const DownloadPdfUseCase(this._repository);

  final PdfFileRepository _repository;

  @override
  Future<Either<Failure, String>> call(DownloadPdfParams params) =>
      _repository.download(params.url, onProgress: params.onProgress);
}
