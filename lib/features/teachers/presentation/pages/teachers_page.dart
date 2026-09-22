import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ibnzaidon/core/bloc/paged_bloc.dart';
import 'package:ibnzaidon/core/di/injector.dart';
import 'package:ibnzaidon/core/utils/context_extensions.dart';
import 'package:ibnzaidon/design_system/components/layout_helpers.dart';
import 'package:ibnzaidon/design_system/components/skeleton.dart';
import 'package:ibnzaidon/design_system/components/state_views.dart';
import 'package:ibnzaidon/design_system/tokens/app_tokens.dart';
import 'package:ibnzaidon/features/teachers/presentation/bloc/teachers_bloc.dart';
import 'package:ibnzaidon/shared/domain/entities/course.dart';
import 'package:ibnzaidon/shared/presentation/auth_gate.dart';
import 'package:ibnzaidon/shared/presentation/paged_bloc_view.dart';
import 'package:ibnzaidon/shared/presentation/widgets/course_card_view.dart';

class TeachersPage extends StatelessWidget {
  const TeachersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.teachersTitle)),
      body: AuthGate(
        builder: (_) => BlocProvider(
          create: (_) =>
              getIt<TeachersBloc>()..add(const PagedStarted<TeachersQuery>()),
          child: const _TeachersView(),
        ),
      ),
    );
  }
}

class _TeachersView extends StatelessWidget {
  const _TeachersView();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bloc = context.read<TeachersBloc>();
    return ContentConstraint(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: AppSpacing.gutter,
              vertical: AppSpacing.sm,
            ),
            child: TextField(
              textInputAction: TextInputAction.search,
              onChanged: (value) => bloc.add(
                PagedQueryChanged(TeachersQuery(search: value), debounce: true),
              ),
              decoration: InputDecoration(
                hintText: l10n.teachersSearchHint,
                prefixIcon: const Icon(Icons.search_rounded),
              ),
            ),
          ),
          Expanded(
            child: PagedBlocView<TeachersBloc, Teacher, TeachersQuery>(
              gridColumns: context.gridColumns + 1,
              // A verified teacher's real card content (avatar + up to a
              // two-line name + specialization + rating chip) needs close
              // to 180dp of height at a 3-column phone width; 0.72 only
              // gave it ~140dp, which is what was overflowing.
              gridChildAspectRatio: 0.56,
              skeletonBuilder: (_) => const Column(
                children: [
                  SkeletonBox(
                    width: AppSizes.avatarLg,
                    height: AppSizes.avatarLg,
                    circle: true,
                  ),
                  SizedBox(height: AppSpacing.sm),
                  SkeletonBox(height: AppSpacing.md),
                ],
              ),
              emptyBuilder: (_) => EmptyState(
                icon: Icons.person_search_rounded,
                title: l10n.teachersEmpty,
              ),
              itemBuilder: (context, teacher, _) =>
                  TeacherCardView(teacher: teacher, enableHero: true),
            ),
          ),
        ],
      ),
    );
  }
}
