import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ibnzaidon/app/router/app_routes.dart';
import 'package:ibnzaidon/core/di/injector.dart';
import 'package:ibnzaidon/core/utils/context_extensions.dart';
import 'package:ibnzaidon/core/utils/formatters.dart';
import 'package:ibnzaidon/design_system/components/app_card.dart';
import 'package:ibnzaidon/design_system/components/app_icon_button.dart';
import 'package:ibnzaidon/design_system/components/chips.dart';
import 'package:ibnzaidon/design_system/components/overlays.dart';
import 'package:ibnzaidon/design_system/tokens/app_palette.dart';
import 'package:ibnzaidon/design_system/tokens/app_tokens.dart';
import 'package:ibnzaidon/features/library/domain/entities/library_item.dart';
import 'package:ibnzaidon/features/library/presentation/bloc/pdf_file_cubit.dart';
import 'package:ibnzaidon/features/library/presentation/pages/pdf_viewer_page.dart';
import 'package:share_plus/share_plus.dart';

/// File card with open / offline-download / share actions.
class LibraryItemCard extends StatelessWidget {
  const LibraryItemCard({required this.item, super.key});

  final LibraryItem item;

  @override
  Widget build(BuildContext context) {
    final url = item.pdfUrl;
    if (url == null) {
      return _CardBody(
        item: item,
        state: const PdfFileState(status: PdfFileStatus.failure),
      );
    }
    return BlocProvider(
      create: (_) => getIt<PdfFileCubit>(param1: url)..check(),
      child: BlocBuilder<PdfFileCubit, PdfFileState>(
        builder: (context, state) => _CardBody(item: item, state: state),
      ),
    );
  }
}

class _CardBody extends StatelessWidget {
  const _CardBody({required this.item, required this.state});

  final LibraryItem item;
  final PdfFileState state;

  Future<void> _open(BuildContext context) async {
    final url = item.pdfUrl;
    if (url == null) return;
    await context.push(
      AppRoutes.pdfViewer,
      extra: PdfViewerArgs(title: item.title, url: url),
    );
  }

  Future<void> _share(BuildContext context) async {
    final cubit = context.read<PdfFileCubit>();
    await cubit.ensureDownloaded();
    final path = cubit.state.path;
    if (path == null) {
      if (context.mounted) {
        AppSnackbar.show(
          context,
          context.l10n.libraryDownloadFailed,
          type: AppSnackbarType.error,
        );
      }
      return;
    }
    await SharePlus.instance.share(
      ShareParams(files: [XFile(path)], title: item.title),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = context.colors;
    final subtitle = [
      item.subject?.name,
      item.teacher?.name,
    ].whereType<String>().join(' · ');
    return AppCard(
      onTap: item.pdfUrl == null ? null : () => _open(context),
      semanticLabel: item.title,
      padding: const EdgeInsetsDirectional.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: scheme.errorContainer,
                  borderRadius: AppRadii.fieldRadius,
                ),
                child: SizedBox.square(
                  dimension: AppSizes.avatarMd,
                  child: Icon(
                    Icons.picture_as_pdf_rounded,
                    color: scheme.error,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.titleSmall,
                    ),
                    if (subtitle.isNotEmpty)
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
              if (item.pdfUrl != null)
                AppIconButton(
                  icon: Icons.ios_share_rounded,
                  tooltip: l10n.libraryShareFile,
                  onPressed: () => _share(context),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: [
              if (item.tag != null)
                StatChip(
                  icon: Icons.label_outline_rounded,
                  label: item.tag!,
                  tint: scheme.primaryContainer,
                  onTint: scheme.onPrimaryContainer,
                ),
              if (item.year != null)
                StatChip(icon: Icons.event_rounded, label: '${item.year}'),
              if (item.pages > 0)
                StatChip(
                  icon: Icons.description_outlined,
                  label: l10n.libraryPages(item.pages),
                ),
              if (item.fileSize != null)
                StatChip(icon: Icons.storage_rounded, label: item.fileSize!),
              if (state.isReady)
                StatChip(
                  icon: Icons.offline_pin_rounded,
                  label: l10n.libraryDownloaded,
                  tint: context.palette.successContainer,
                  onTint: context.palette.onSuccessContainer,
                ),
            ],
          ),
          if (state.status == PdfFileStatus.downloading) ...[
            const SizedBox(height: AppSpacing.sm),
            LinearProgressIndicator(
              value: state.progress > 0 ? state.progress : null,
            ),
            Text(
              l10n.libraryDownloading(AppFormatters.percent(state.progress)),
              style: context.text.labelSmall,
            ),
          ],
        ],
      ),
    );
  }
}
