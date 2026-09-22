import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ibnzaidon/core/bloc/paged_bloc.dart';
import 'package:ibnzaidon/design_system/components/paged_list_view.dart';
import 'package:ibnzaidon/design_system/components/skeleton.dart';
import 'package:ibnzaidon/design_system/components/state_views.dart';
import 'package:ibnzaidon/design_system/tokens/app_tokens.dart';
import 'package:ibnzaidon/shared/presentation/failure_view.dart';

/// Binds a [PagedBloc] to [PagedListView] and handles every state:
/// skeleton, empty, error, list, footer loader/retry, pull-to-refresh.
class PagedBlocView<B extends PagedBloc<T, Q>, T, Q extends Equatable>
    extends StatelessWidget {
  const PagedBlocView({
    required this.itemBuilder,
    required this.skeletonBuilder,
    this.emptyBuilder,
    this.gridColumns,
    this.gridChildAspectRatio = 0.78,
    this.skeletonCount = 6,
    this.padding = const EdgeInsetsDirectional.symmetric(
      horizontal: AppSpacing.gutter,
      vertical: AppSpacing.lg,
    ),
    this.spacing = AppSpacing.md,
    super.key,
  });

  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final WidgetBuilder skeletonBuilder;
  final WidgetBuilder? emptyBuilder;
  final int? gridColumns;
  final double gridChildAspectRatio;
  final int skeletonCount;
  final EdgeInsetsGeometry padding;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<B>();
    return BlocBuilder<B, PagedState<T, Q>>(
      builder: (context, state) {
        if (state.isInitialLoading) {
          return _Skeleton(view: this);
        }
        if (state.hasFullScreenFailure) {
          return FailureView(
            failure: state.failure!,
            onRetry: () => bloc.add(PagedStarted<Q>()),
          );
        }
        if (state.isEmpty) {
          return emptyBuilder?.call(context) ?? const EmptyState();
        }
        return PagedListView<T>(
          items: state.items,
          itemBuilder: itemBuilder,
          gridColumns: gridColumns,
          gridChildAspectRatio: gridChildAspectRatio,
          padding: padding,
          spacing: spacing,
          hasReachedMax: state.hasReachedMax,
          isLoadingMore: state.status == PagedStatus.loadingMore,
          hasFooterFailure: state.hasFooterFailure,
          onLoadMore: () => bloc.add(PagedNextPageRequested<Q>()),
          onRefresh: () async {
            bloc.add(PagedRefreshed<Q>());
            await bloc.stream.firstWhere(
              (s) =>
                  s.status == PagedStatus.success ||
                  s.status == PagedStatus.failure,
            );
          },
        );
      },
    );
  }
}

class _Skeleton extends StatelessWidget {
  const _Skeleton({required this.view});

  final PagedBlocView<dynamic, dynamic, dynamic> view;

  @override
  Widget build(BuildContext context) {
    final columns = view.gridColumns;
    if (columns == null) {
      return SkeletonList(
        itemBuilder: view.skeletonBuilder,
        itemCount: view.skeletonCount,
        padding: view.padding,
        spacing: view.spacing,
      );
    }
    return SkeletonShimmer(
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: view.padding,
        itemCount: view.skeletonCount,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          mainAxisSpacing: view.spacing,
          crossAxisSpacing: view.spacing,
          childAspectRatio: view.gridChildAspectRatio,
        ),
        itemBuilder: (context, _) => view.skeletonBuilder(context),
      ),
    );
  }
}
