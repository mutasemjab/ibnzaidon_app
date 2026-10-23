import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ibnzaidon/core/bloc/resource_bloc.dart';
import 'package:ibnzaidon/core/di/injector.dart';
import 'package:ibnzaidon/core/utils/context_extensions.dart';
import 'package:ibnzaidon/design_system/components/layout_helpers.dart';
import 'package:ibnzaidon/design_system/components/skeleton.dart';
import 'package:ibnzaidon/design_system/tokens/app_tokens.dart';
import 'package:ibnzaidon/features/info_pages/domain/entities/info_page.dart';
import 'package:ibnzaidon/features/info_pages/presentation/bloc/info_page_bloc.dart';
import 'package:ibnzaidon/shared/presentation/failure_view.dart';

/// One generic page for all four static-content screens (terms, privacy,
/// about, support) — same layout, different `slug` and fallback title.
class InfoPageView extends StatelessWidget {
  const InfoPageView({
    required this.slug,
    required this.fallbackTitle,
    super.key,
  });

  final String slug;
  final String fallbackTitle;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<InfoPageBloc>(param1: slug)..add(const ResourceRequested()),
      child: _InfoPageScaffold(fallbackTitle: fallbackTitle),
    );
  }
}

class _InfoPageScaffold extends StatelessWidget {
  const _InfoPageScaffold({required this.fallbackTitle});

  final String fallbackTitle;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InfoPageBloc, ResourceState<InfoPage>>(
      builder: (context, state) => Scaffold(
        appBar: AppBar(
          title: Text(
            state.data?.title ?? fallbackTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        body: _body(context, state),
      ),
    );
  }

  Widget _body(BuildContext context, ResourceState<InfoPage> state) {
    if (state.isLoading && state.data == null) return const _Skeleton();
    final page = state.data;
    if (page == null) {
      return FailureView(
        failure: state.failure!,
        onRetry: () =>
            context.read<InfoPageBloc>().add(const ResourceRequested()),
      );
    }
    return ContentConstraint(
      child: SingleChildScrollView(
        padding: AppSpacing.pagePadding,
        child: Text(page.body, style: context.text.bodyMedium),
      ),
    );
  }
}

class _Skeleton extends StatelessWidget {
  const _Skeleton();

  @override
  Widget build(BuildContext context) => const SkeletonShimmer(
    child: Padding(
      padding: EdgeInsetsDirectional.all(AppSpacing.gutter),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBox(height: 16),
          SizedBox(height: AppSpacing.sm),
          SkeletonBox(height: 16),
          SizedBox(height: AppSpacing.sm),
          SkeletonBox(width: 220, height: 16),
          SizedBox(height: AppSpacing.lg),
          SkeletonBox(height: 16),
          SizedBox(height: AppSpacing.sm),
          SkeletonBox(height: 16),
          SizedBox(height: AppSpacing.sm),
          SkeletonBox(width: 260, height: 16),
        ],
      ),
    ),
  );
}
