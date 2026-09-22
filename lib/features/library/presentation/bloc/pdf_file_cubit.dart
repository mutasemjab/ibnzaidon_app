import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ibnzaidon/core/error/failure.dart';
import 'package:ibnzaidon/features/library/domain/usecases/library_usecases.dart';

enum PdfFileStatus { checking, remote, downloading, ready, failure }

final class PdfFileState extends Equatable {
  const PdfFileState({
    this.status = PdfFileStatus.checking,
    this.progress = 0,
    this.path,
    this.failure,
  });

  final PdfFileStatus status;
  final double progress;
  final String? path;
  final Failure? failure;

  bool get isReady => status == PdfFileStatus.ready && path != null;

  @override
  List<Object?> get props => [status, progress, path, failure];
}

/// Tracks one PDF: cached on disk (offline) or downloadable with progress.
class PdfFileCubit extends Cubit<PdfFileState> {
  PdfFileCubit({
    required this.url,
    required GetCachedPdfUseCase getCached,
    required DownloadPdfUseCase download,
  }) : _getCached = getCached,
       _download = download,
       super(const PdfFileState());

  final String url;
  final GetCachedPdfUseCase _getCached;
  final DownloadPdfUseCase _download;

  Future<void> check() async {
    final path = await _getCached(url);
    if (isClosed) return;
    emit(
      path == null
          ? const PdfFileState(status: PdfFileStatus.remote)
          : PdfFileState(status: PdfFileStatus.ready, path: path),
    );
  }

  /// Ensures the file is local. Safe to call repeatedly.
  Future<void> ensureDownloaded() async {
    if (state.isReady || state.status == PdfFileStatus.downloading) return;
    final cached = await _getCached(url);
    if (isClosed) return;
    if (cached != null) {
      emit(PdfFileState(status: PdfFileStatus.ready, path: cached));
      return;
    }
    emit(const PdfFileState(status: PdfFileStatus.downloading));
    final result = await _download(
      DownloadPdfParams(
        url,
        onProgress: (value) {
          if (!isClosed) {
            emit(
              PdfFileState(status: PdfFileStatus.downloading, progress: value),
            );
          }
        },
      ),
    );
    if (isClosed) return;
    emit(
      result.fold(
        (failure) =>
            PdfFileState(status: PdfFileStatus.failure, failure: failure),
        (path) => PdfFileState(status: PdfFileStatus.ready, path: path),
      ),
    );
  }
}
