import 'package:fpdart/fpdart.dart';
import 'package:ibnzaidon/core/error/failure.dart';
import 'package:ibnzaidon/features/library/domain/entities/library_item.dart';
import 'package:ibnzaidon/shared/domain/paged_list.dart';

abstract interface class LibraryRepository {
  Future<Either<Failure, PagedList<LibraryItem>>> getItems(
    LibraryKind kind,
    int page,
    LibraryQuery query,
  );
}

/// Downloads PDFs into an offline cache.
abstract interface class PdfFileRepository {
  Future<String?> cachedPath(String url);

  Future<Either<Failure, String>> download(
    String url, {
    void Function(double progress)? onProgress,
  });
}
