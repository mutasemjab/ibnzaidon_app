import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ibnzaidon/core/bloc/resource_bloc.dart';
import 'package:ibnzaidon/core/bloc/submission_status.dart';
import 'package:ibnzaidon/core/di/injector.dart';
import 'package:ibnzaidon/core/utils/context_extensions.dart';
import 'package:ibnzaidon/core/utils/formatters.dart';
import 'package:ibnzaidon/design_system/components/app_button.dart';
import 'package:ibnzaidon/design_system/components/app_card.dart';
import 'package:ibnzaidon/design_system/components/app_tabs.dart';
import 'package:ibnzaidon/design_system/components/layout_helpers.dart';
import 'package:ibnzaidon/design_system/components/overlays.dart';
import 'package:ibnzaidon/design_system/components/skeleton.dart';
import 'package:ibnzaidon/design_system/components/state_views.dart';
import 'package:ibnzaidon/design_system/tokens/app_palette.dart';
import 'package:ibnzaidon/design_system/tokens/app_tokens.dart';
import 'package:ibnzaidon/features/school_life/domain/entities/school_record.dart';
import 'package:ibnzaidon/features/school_life/presentation/bloc/school_life_blocs.dart';
import 'package:ibnzaidon/shared/presentation/auth_gate.dart';
import 'package:ibnzaidon/shared/presentation/failure_view.dart';

/// Generic list for the contract-less endpoints. [kinds] with more than one
/// entry render as a segmented switch (planner, schedules).
class SchoolRecordsPage extends StatefulWidget {
  const SchoolRecordsPage({
    required this.title,
    required this.kinds,
    super.key,
  });

  final String title;
  final Map<SchoolRecordKind, String> kinds;

  @override
  State<SchoolRecordsPage> createState() => _SchoolRecordsPageState();
}

class _SchoolRecordsPageState extends State<SchoolRecordsPage> {
  late SchoolRecordKind _kind = widget.kinds.keys.first;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: AuthGate(
        builder: (_) => ContentConstraint(
          child: Column(
            children: [
              if (widget.kinds.length > 1)
                Padding(
                  padding: const EdgeInsetsDirectional.all(AppSpacing.gutter),
                  child: AppSegmentedControl<SchoolRecordKind>(
                    segments: widget.kinds,
                    selected: _kind,
                    onChanged: (value) => setState(() => _kind = value),
                  ),
                ),
              Expanded(
                child: BlocProvider(
                  key: ValueKey(_kind),
                  create: (_) =>
                      getIt<SchoolRecordsBloc>(param1: _kind)
                        ..add(const ResourceRequested()),
                  child: const _RecordsList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecordsList extends StatelessWidget {
  const _RecordsList();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SchoolRecordsBloc, ResourceState<List<SchoolRecord>>>(
      builder: (context, state) {
        if (state.isLoading) {
          return SkeletonList(itemBuilder: (_) => const SkeletonRow());
        }
        final records = state.data;
        if (records == null) {
          return FailureView(
            failure: state.failure!,
            onRetry: () => context.read<SchoolRecordsBloc>().add(
              const ResourceRequested(),
            ),
          );
        }
        if (records.isEmpty) return const EmptyState();
        return AppRefreshIndicator(
          onRefresh: () async =>
              context.read<SchoolRecordsBloc>().add(const ResourceRefreshed()),
          child: ListView.separated(
            padding: const EdgeInsetsDirectional.all(AppSpacing.gutter),
            itemCount: records.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, i) => Staggered(
              index: i,
              child: _RecordCard(record: records[i]),
            ),
          ),
        );
      },
    );
  }
}

class _RecordCard extends StatelessWidget {
  const _RecordCard({required this.record});

  final SchoolRecord record;

  @override
  Widget build(BuildContext context) {
    final date = record.date;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (record.title != null)
            Text(record.title!, style: context.text.titleSmall),
          if (date != null)
            Text(
              AppFormatters.date(date, context.languageCode),
              style: context.text.labelSmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          if (record.body != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(record.body!, style: context.text.bodyMedium),
          ],
          if (record.fields.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.xs,
              children: [
                for (final entry in record.fields.entries)
                  Chip(label: Text('${entry.key}: ${entry.value}')),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class ConductPage extends StatelessWidget {
  const ConductPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.schoolConduct)),
      body: AuthGate(
        builder: (_) => BlocProvider(
          create: (_) => getIt<ConductBloc>()..add(const ConductRequested()),
          child: const _ConductView(),
        ),
      ),
    );
  }
}

class _ConductView extends StatelessWidget {
  const _ConductView();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocConsumer<ConductBloc, ConductState>(
      listenWhen: (a, b) => a.signing != b.signing,
      listener: (context, state) {
        if (state.signing == SubmissionStatus.success) {
          AppSnackbar.show(
            context,
            l10n.conductSigned,
            type: AppSnackbarType.success,
          );
        } else if (state.signing == SubmissionStatus.failure) {
          context.showFailure(state.failure!);
        }
      },
      builder: (context, state) {
        if (state.status == ResourceStatus.loading ||
            state.status == ResourceStatus.initial) {
          return const SkeletonShimmer(
            child: Padding(
              padding: EdgeInsetsDirectional.all(AppSpacing.gutter),
              child: SkeletonBox(height: 240, radius: AppRadii.card),
            ),
          );
        }
        final overview = state.overview;
        if (overview == null) {
          return FailureView(
            failure: state.failure!,
            onRetry: () =>
                context.read<ConductBloc>().add(const ConductRequested()),
          );
        }
        final signed = overview.status.isSigned;
        return ContentConstraint(
          child: ListView(
            padding: const EdgeInsetsDirectional.all(AppSpacing.gutter),
            children: [
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (overview.document.title != null)
                      Text(
                        overview.document.title!,
                        style: context.text.titleMedium,
                      ),
                    if (overview.document.body != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        overview.document.body!,
                        style: context.text.bodyMedium,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              if (signed)
                Row(
                  children: [
                    Icon(
                      Icons.verified_rounded,
                      color: context.palette.success,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(l10n.conductSigned, style: context.text.titleSmall),
                  ],
                )
              else
                AppButton(
                  label: l10n.conductSign,
                  icon: Icons.draw_rounded,
                  isLoading: state.signing == SubmissionStatus.submitting,
                  onPressed: () => context.read<ConductBloc>().add(
                    const ConductSignRequested(),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
