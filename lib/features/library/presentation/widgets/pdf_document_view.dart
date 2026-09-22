import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ibnzaidon/core/di/injector.dart';
import 'package:ibnzaidon/core/l10n/failure_message.dart';
import 'package:ibnzaidon/core/utils/context_extensions.dart';
import 'package:ibnzaidon/design_system/components/skeleton.dart';
import 'package:ibnzaidon/design_system/components/state_views.dart';
import 'package:ibnzaidon/features/library/presentation/bloc/pdf_file_cubit.dart';
import 'package:pdfx/pdfx.dart';

/// In-app PDF viewer: downloads (or reuses the offline cache) then renders
/// with pdfx. Used by the standalone viewer and by PDF lessons.
class PdfDocumentView extends StatelessWidget {
  const PdfDocumentView({required this.url, super.key});

  final String url;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<PdfFileCubit>(param1: url),
      child: _Loader(url: url),
    );
  }
}

class _Loader extends StatefulWidget {
  const _Loader({required this.url});

  final String url;

  @override
  State<_Loader> createState() => _LoaderState();
}

class _LoaderState extends State<_Loader> {
  @override
  void initState() {
    super.initState();
    context.read<PdfFileCubit>().ensureDownloaded();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PdfFileCubit, PdfFileState>(
      builder: (context, state) {
        if (state.status == PdfFileStatus.failure) {
          return ErrorState(
            message:
                state.failure?.localized(context.l10n) ??
                context.l10n.pdfViewerFailed,
            onRetry: () => context.read<PdfFileCubit>().ensureDownloaded(),
          );
        }
        if (!state.isReady) {
          return Center(
            child: SizedBox(
              width: 200,
              child: state.progress > 0
                  ? LinearProgressIndicator(value: state.progress)
                  : const SkeletonShimmer(child: SkeletonBox(height: 8)),
            ),
          );
        }
        return _PdfPages(path: state.path!);
      },
    );
  }
}

class _PdfPages extends StatefulWidget {
  const _PdfPages({required this.path});

  final String path;

  @override
  State<_PdfPages> createState() => _PdfPagesState();
}

class _PdfPagesState extends State<_PdfPages> {
  late final PdfControllerPinch _controller = PdfControllerPinch(
    document: PdfDocument.openFile(widget.path),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PdfViewPinch(
          controller: _controller,
          builders: PdfViewPinchBuilders<DefaultBuilderOptions>(
            options: const DefaultBuilderOptions(),
            documentLoaderBuilder: (_) =>
                const Center(child: CircularProgressIndicator()),
            pageLoaderBuilder: (_) =>
                const Center(child: CircularProgressIndicator()),
            errorBuilder: (_, _) =>
                ErrorState(message: context.l10n.pdfViewerFailed),
          ),
        ),
        PositionedDirectional(
          bottom: 16,
          start: 0,
          end: 0,
          child: Center(
            child: ValueListenableBuilder<int>(
              valueListenable: _controller.pageListenable,
              builder: (context, page, _) => DecoratedBox(
                decoration: BoxDecoration(
                  color: context.colors.inverseSurface.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: Text(
                    context.l10n.pdfPageOf(
                      page,
                      _controller.pagesCount ?? page,
                    ),
                    style: context.text.labelMedium?.copyWith(
                      color: context.colors.onInverseSurface,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
