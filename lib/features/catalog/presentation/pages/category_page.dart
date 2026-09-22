import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ibnzaidon/app/router/app_routes.dart';
import 'package:ibnzaidon/core/bloc/resource_bloc.dart';
import 'package:ibnzaidon/core/di/injector.dart';
import 'package:ibnzaidon/core/utils/context_extensions.dart';
import 'package:ibnzaidon/design_system/components/layout_helpers.dart';
import 'package:ibnzaidon/design_system/components/section_header.dart';
import 'package:ibnzaidon/design_system/components/skeleton.dart';
import 'package:ibnzaidon/design_system/components/state_views.dart';
import 'package:ibnzaidon/design_system/tokens/app_tokens.dart';
import 'package:ibnzaidon/features/catalog/domain/entities/catalog_entities.dart';
import 'package:ibnzaidon/features/catalog/presentation/bloc/catalog_blocs.dart';
import 'package:ibnzaidon/features/catalog/presentation/widgets/catalog_widgets.dart';
import 'package:ibnzaidon/shared/presentation/failure_view.dart';

/// Category drill-down: child categories + subjects, with breadcrumb.
class CategoryPage extends StatelessWidget {
  const CategoryPage({
    required this.categoryId,
    this.trail = const [],
    super.key,
  });

  final int categoryId;
  final List<String> trail;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<CategoryDetailBloc>(param1: categoryId)
            ..add(const ResourceRequested()),
      child: _CategoryView(trail: trail),
    );
  }
}

class _CategoryView extends StatelessWidget {
  const _CategoryView({required this.trail});

  final List<String> trail;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoryDetailBloc, ResourceState<CategoryDetail>>(
      builder: (context, state) {
        final detail = state.data;
        final fullTrail = [
          ...trail,
          if (detail != null) detail.category.name,
        ];
        return Scaffold(
          appBar: AppBar(
            title: Text(detail?.category.name ?? context.l10n.exploreTitle),
            bottom: fullTrail.length > 1
                ? PreferredSize(
                    preferredSize: const Size.fromHeight(AppSizes.touchTarget),
                    child: Breadcrumb(trail: fullTrail),
                  )
                : null,
          ),
          body: ContentConstraint(child: _body(context, state, fullTrail)),
        );
      },
    );
  }

  Widget _body(
    BuildContext context,
    ResourceState<CategoryDetail> state,
    List<String> fullTrail,
  ) {
    if (state.isLoading) return const _CategorySkeleton();
    if (state.status == ResourceStatus.failure && state.data == null) {
      return FailureView(
        failure: state.failure!,
        onRetry: () =>
            context.read<CategoryDetailBloc>().add(const ResourceRequested()),
      );
    }
    final detail = state.data!;
    if (detail.children.isEmpty && detail.subjects.isEmpty) {
      return EmptyState(message: context.l10n.exploreCategoryEmpty);
    }
    return AppRefreshIndicator(
      onRefresh: () async =>
          context.read<CategoryDetailBloc>().add(const ResourceRefreshed()),
      child: ListView(
        padding: const EdgeInsetsDirectional.symmetric(vertical: AppSpacing.lg),
        children: [
          if (detail.children.isNotEmpty) ...[
            SectionHeader(title: context.l10n.exploreSections),
            Padding(
              padding: const EdgeInsetsDirectional.all(AppSpacing.gutter),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: context.gridColumns + 1,
                mainAxisSpacing: AppSpacing.md,
                crossAxisSpacing: AppSpacing.md,
                childAspectRatio: 0.95,
                children: [
                  for (var i = 0; i < detail.children.length; i++)
                    Staggered(
                      index: i,
                      child: CategoryCard(
                        category: detail.children[i],
                        onTap: () => context.push(
                          AppRoutes.category(detail.children[i].id),
                          extra: fullTrail,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
          if (detail.subjects.isNotEmpty) ...[
            SectionHeader(title: context.l10n.exploreSubjects),
            for (var i = 0; i < detail.subjects.length; i++)
              Padding(
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: AppSpacing.gutter,
                  vertical: AppSpacing.xs,
                ),
                child: Staggered(
                  index: i,
                  child: SubjectTile(
                    subject: detail.subjects[i],
                    onTap: () =>
                        context.push(AppRoutes.subject(detail.subjects[i].id)),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _CategorySkeleton extends StatelessWidget {
  const _CategorySkeleton();

  @override
  Widget build(BuildContext context) {
    return const SkeletonShimmer(
      child: Padding(
        padding: EdgeInsetsDirectional.all(AppSpacing.gutter),
        child: Column(
          children: [
            SkeletonBox(height: 96, radius: AppRadii.card),
            SizedBox(height: AppSpacing.md),
            SkeletonBox(height: 96, radius: AppRadii.card),
            SizedBox(height: AppSpacing.md),
            SkeletonBox(height: 96, radius: AppRadii.card),
          ],
        ),
      ),
    );
  }
}
