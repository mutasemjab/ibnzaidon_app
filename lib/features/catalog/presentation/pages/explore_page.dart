import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ibnzaidon/app/router/app_routes.dart';
import 'package:ibnzaidon/core/bloc/paged_bloc.dart';
import 'package:ibnzaidon/core/bloc/resource_bloc.dart';
import 'package:ibnzaidon/core/di/injector.dart';
import 'package:ibnzaidon/core/utils/context_extensions.dart';
import 'package:ibnzaidon/design_system/components/app_icon_button.dart';
import 'package:ibnzaidon/design_system/components/course_card.dart';
import 'package:ibnzaidon/design_system/components/layout_helpers.dart';
import 'package:ibnzaidon/design_system/components/skeleton.dart';
import 'package:ibnzaidon/design_system/tokens/app_tokens.dart';
import 'package:ibnzaidon/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ibnzaidon/features/catalog/domain/entities/catalog_entities.dart';
import 'package:ibnzaidon/features/catalog/presentation/bloc/catalog_blocs.dart';
import 'package:ibnzaidon/features/catalog/presentation/widgets/catalog_widgets.dart';
import 'package:ibnzaidon/features/courses/domain/entities/course_content.dart';
import 'package:ibnzaidon/features/courses/presentation/bloc/courses_bloc.dart';
import 'package:ibnzaidon/shared/domain/entities/course.dart';
import 'package:ibnzaidon/shared/presentation/auth_gate.dart';
import 'package:ibnzaidon/shared/presentation/failure_view.dart';
import 'package:ibnzaidon/shared/presentation/paged_bloc_view.dart';
import 'package:ibnzaidon/shared/presentation/widgets/course_card_view.dart';

/// Explore tab: debounced course search + category tree drill-down.
class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              getIt<CategoriesBloc>()..add(const ResourceRequested()),
        ),
        BlocProvider(create: (_) => getIt<CoursesBloc>()),
      ],
      child: const _ExploreView(),
    );
  }
}

class _ExploreView extends StatefulWidget {
  const _ExploreView();

  @override
  State<_ExploreView> createState() => _ExploreViewState();
}

class _ExploreViewState extends State<_ExploreView> {
  final _controller = TextEditingController();
  bool _isGrid = true;

  bool get _isSearching => _controller.text.trim().isNotEmpty;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() {});
    final text = value.trim();
    if (text.isEmpty || !context.read<AuthBloc>().state.isAuthenticated) return;
    context.read<CoursesBloc>().add(
      PagedQueryChanged(CourseQuery(search: text), debounce: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.exploreTitle),
        actions: [
          if (!_isSearching)
            AppIconButton(
              icon: _isGrid ? Icons.view_list_rounded : Icons.grid_view_rounded,
              tooltip: _isGrid ? l10n.exploreViewList : l10n.exploreViewGrid,
              onPressed: () => setState(() => _isGrid = !_isGrid),
            ),
        ],
      ),
      body: ContentConstraint(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: AppSpacing.gutter,
                vertical: AppSpacing.sm,
              ),
              child: TextField(
                controller: _controller,
                textInputAction: TextInputAction.search,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: l10n.exploreSearchHint,
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _isSearching
                      ? IconButton(
                          tooltip: l10n.commonClose,
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () {
                            _controller.clear();
                            _onSearchChanged('');
                          },
                        )
                      : null,
                ),
              ),
            ),
            Expanded(
              child: _isSearching
                  ? AuthGate(
                      message: l10n.exploreSearchSignIn,
                      builder: (_) =>
                          PagedBlocView<CoursesBloc, Course, CourseQuery>(
                            gridColumns: context.isTablet
                                ? context.gridColumns
                                : null,
                            gridChildAspectRatio: 0.9,
                            skeletonBuilder: (_) => const SkeletonRow(),
                            itemBuilder: (context, course, _) => CourseCardView(
                              course: course,
                              variant: CourseCardVariant.horizontal,
                              enableHero: true,
                            ),
                          ),
                    )
                  : _Categories(isGrid: _isGrid),
            ),
          ],
        ),
      ),
    );
  }
}

class _Categories extends StatelessWidget {
  const _Categories({required this.isGrid});

  final bool isGrid;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoriesBloc, ResourceState<List<Category>>>(
      builder: (context, state) {
        if (state.isLoading) {
          return SkeletonShimmer(
            child: GridView.count(
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsetsDirectional.all(AppSpacing.gutter),
              crossAxisCount: context.gridColumns,
              mainAxisSpacing: AppSpacing.md,
              crossAxisSpacing: AppSpacing.md,
              children: List.generate(
                6,
                (_) => const SkeletonBox(
                  height: double.infinity,
                  radius: AppRadii.card,
                ),
              ),
            ),
          );
        }
        if (state.data == null) {
          return FailureView(
            failure: state.failure!,
            onRetry: () =>
                context.read<CategoriesBloc>().add(const ResourceRequested()),
          );
        }
        final categories = state.data!;
        void open(Category category) => context.push(
          AppRoutes.category(category.id),
          extra: const <String>[],
        );
        return AppRefreshIndicator(
          onRefresh: () async =>
              context.read<CategoriesBloc>().add(const ResourceRefreshed()),
          child: isGrid
              ? GridView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsetsDirectional.all(AppSpacing.gutter),
                  itemCount: categories.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: context.gridColumns,
                    mainAxisSpacing: AppSpacing.md,
                    crossAxisSpacing: AppSpacing.md,
                    childAspectRatio: 1.05,
                  ),
                  itemBuilder: (context, i) => Staggered(
                    index: i,
                    child: CategoryCard(
                      category: categories[i],
                      onTap: () => open(categories[i]),
                    ),
                  ),
                )
              : ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsetsDirectional.all(AppSpacing.gutter),
                  itemCount: categories.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, i) => Staggered(
                    index: i,
                    child: CategoryCard(
                      category: categories[i],
                      horizontal: true,
                      onTap: () => open(categories[i]),
                    ),
                  ),
                ),
        );
      },
    );
  }
}
