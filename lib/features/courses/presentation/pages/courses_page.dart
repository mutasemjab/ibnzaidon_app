import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ibnzaidon/core/bloc/paged_bloc.dart';
import 'package:ibnzaidon/core/di/injector.dart';
import 'package:ibnzaidon/core/utils/context_extensions.dart';
import 'package:ibnzaidon/design_system/components/app_icon_button.dart';
import 'package:ibnzaidon/design_system/components/course_card.dart';
import 'package:ibnzaidon/design_system/components/layout_helpers.dart';
import 'package:ibnzaidon/design_system/components/skeleton.dart';
import 'package:ibnzaidon/design_system/components/state_views.dart';
import 'package:ibnzaidon/design_system/tokens/app_tokens.dart';
import 'package:ibnzaidon/features/courses/domain/entities/course_content.dart';
import 'package:ibnzaidon/features/courses/presentation/bloc/courses_bloc.dart';
import 'package:ibnzaidon/features/courses/presentation/widgets/filters_sheet.dart';
import 'package:ibnzaidon/shared/domain/entities/course.dart';
import 'package:ibnzaidon/shared/presentation/auth_gate.dart';
import 'package:ibnzaidon/shared/presentation/paged_bloc_view.dart';
import 'package:ibnzaidon/shared/presentation/widgets/course_card_view.dart';

/// Course list with debounced search, filter sheet and infinite scroll.
class CoursesPage extends StatelessWidget {
  const CoursesPage({this.initialQuery = const CourseQuery(), super.key});

  final CourseQuery initialQuery;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.coursesTitle)),
      body: AuthGate(
        builder: (_) => BlocProvider(
          create: (_) =>
              getIt<CoursesBloc>(param1: initialQuery)
                ..add(const PagedStarted<CourseQuery>()),
          child: const _CoursesView(),
        ),
      ),
    );
  }
}

class _CoursesView extends StatelessWidget {
  const _CoursesView();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bloc = context.read<CoursesBloc>();
    return ContentConstraint(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: AppSpacing.gutter,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    textInputAction: TextInputAction.search,
                    onChanged: (value) => bloc.add(
                      PagedQueryChanged(
                        bloc.state.query.copyWith(search: value),
                        debounce: true,
                      ),
                    ),
                    decoration: InputDecoration(
                      hintText: l10n.coursesSearchHint,
                      prefixIcon: const Icon(Icons.search_rounded),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                BlocBuilder<CoursesBloc, PagedState<Course, CourseQuery>>(
                  buildWhen: (a, b) => a.query.hasFilters != b.query.hasFilters,
                  builder: (context, state) => Badge(
                    isLabelVisible: state.query.hasFilters,
                    child: AppIconButton(
                      icon: Icons.tune_rounded,
                      tooltip: l10n.commonFilters,
                      filled: true,
                      onPressed: () async {
                        final result = await showCourseFiltersSheet(
                          context,
                          current: state.query,
                        );
                        if (result != null) bloc.add(PagedQueryChanged(result));
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: PagedBlocView<CoursesBloc, Course, CourseQuery>(
              gridColumns: context.isTablet ? context.gridColumns : null,
              gridChildAspectRatio: 0.9,
              skeletonBuilder: (_) => const SkeletonRow(),
              emptyBuilder: (_) => EmptyState(
                icon: Icons.search_off_rounded,
                title: l10n.coursesEmptyTitle,
              ),
              itemBuilder: (context, course, _) => CourseCardView(
                course: course,
                variant: context.isTablet
                    ? CourseCardVariant.vertical
                    : CourseCardVariant.horizontal,
                enableHero: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
