import 'package:flutter/material.dart';
import 'package:ibnzaidon/core/utils/context_extensions.dart';
import 'package:ibnzaidon/design_system/components/app_button.dart';
import 'package:ibnzaidon/design_system/components/layout_helpers.dart';
import 'package:ibnzaidon/design_system/tokens/app_tokens.dart';

/// Infinite-scroll list/grid. Pure UI: it asks for more via [onLoadMore] and
/// renders a footer loader / retry. State lives in a `PagedBloc`.
class PagedListView<T> extends StatefulWidget {
  const PagedListView({
    required this.items,
    required this.itemBuilder,
    required this.onLoadMore,
    required this.onRefresh,
    this.hasReachedMax = false,
    this.isLoadingMore = false,
    this.hasFooterFailure = false,
    this.gridColumns,
    this.gridChildAspectRatio = 0.78,
    this.headerSlivers = const [],
    this.padding = const EdgeInsetsDirectional.symmetric(
      horizontal: AppSpacing.gutter,
      vertical: AppSpacing.lg,
    ),
    this.spacing = AppSpacing.md,
    super.key,
  });

  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final VoidCallback onLoadMore;
  final Future<void> Function() onRefresh;
  final bool hasReachedMax;
  final bool isLoadingMore;
  final bool hasFooterFailure;

  /// When set, renders a grid with this many columns instead of a list.
  final int? gridColumns;
  final double gridChildAspectRatio;
  final List<Widget> headerSlivers;
  final EdgeInsetsGeometry padding;
  final double spacing;

  @override
  State<PagedListView<T>> createState() => _PagedListViewState<T>();
}

class _PagedListViewState<T> extends State<PagedListView<T>> {
  static const _loadMoreThreshold = 400.0;
  final _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_controller.hasClients || widget.hasReachedMax) return;
    final position = _controller.position;
    if (position.maxScrollExtent - position.pixels <= _loadMoreThreshold) {
      widget.onLoadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final columns = widget.gridColumns;
    return AppRefreshIndicator(
      onRefresh: widget.onRefresh,
      child: CustomScrollView(
        controller: _controller,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          ...widget.headerSlivers,
          SliverPadding(
            padding: widget.padding,
            sliver: columns == null
                ? SliverList.separated(
                    itemCount: widget.items.length,
                    separatorBuilder: (_, _) =>
                        SizedBox(height: widget.spacing),
                    itemBuilder: _buildItem,
                  )
                : SliverGrid.builder(
                    itemCount: widget.items.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      mainAxisSpacing: widget.spacing,
                      crossAxisSpacing: widget.spacing,
                      childAspectRatio: widget.gridChildAspectRatio,
                    ),
                    itemBuilder: _buildItem,
                  ),
          ),
          SliverToBoxAdapter(child: _Footer(widget: widget)),
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context, int index) => RepaintBoundary(
    child: Staggered(
      index: index,
      child: widget.itemBuilder(context, widget.items[index], index),
    ),
  );
}

class _Footer extends StatelessWidget {
  const _Footer({required this.widget});

  final PagedListView<dynamic> widget;

  @override
  Widget build(BuildContext context) {
    if (widget.isLoadingMore) {
      return const Padding(
        padding: EdgeInsetsDirectional.all(AppSpacing.xxl),
        child: Center(
          child: SizedBox.square(
            dimension: AppSizes.icon,
            child: CircularProgressIndicator(strokeWidth: 2.4),
          ),
        ),
      );
    }
    if (widget.hasFooterFailure) {
      return Padding(
        padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
        child: Column(
          children: [
            Text(
              context.l10n.commonLoadMoreFailed,
              style: context.text.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            AppButton(
              label: context.l10n.commonRetry,
              variant: AppButtonVariant.secondary,
              expanded: false,
              onPressed: widget.onLoadMore,
            ),
          ],
        ),
      );
    }
    return const SizedBox(height: AppSpacing.xxxl);
  }
}
