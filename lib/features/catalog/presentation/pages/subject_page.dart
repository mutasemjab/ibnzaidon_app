import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ibnzaidon/core/bloc/resource_bloc.dart';
import 'package:ibnzaidon/core/di/injector.dart';
import 'package:ibnzaidon/core/utils/context_extensions.dart';
import 'package:ibnzaidon/design_system/components/course_card.dart';
import 'package:ibnzaidon/design_system/components/layout_helpers.dart';
import 'package:ibnzaidon/design_system/components/skeleton.dart';
import 'package:ibnzaidon/design_system/components/state_views.dart';
import 'package:ibnzaidon/design_system/tokens/app_palette.dart';
import 'package:ibnzaidon/design_system/tokens/app_tokens.dart';
import 'package:ibnzaidon/features/catalog/domain/entities/catalog_entities.dart';
import 'package:ibnzaidon/features/catalog/presentation/bloc/catalog_blocs.dart';
import 'package:ibnzaidon/features/catalog/presentation/widgets/catalog_widgets.dart';
import 'package:ibnzaidon/shared/presentation/failure_view.dart';
import 'package:ibnzaidon/shared/presentation/widgets/course_card_view.dart';

class SubjectPage extends StatelessWidget {
  const SubjectPage({required this.subjectId, super.key});

  final int subjectId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<SubjectDetailBloc>(param1: subjectId)
            ..add(const ResourceRequested()),
      child: const _SubjectView(),
    );
  }
}

class _SubjectView extends StatelessWidget {
  const _SubjectView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<SubjectDetailBloc, ResourceState<SubjectDetail>>(
        builder: (context, state) {
          final detail = state.data;
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: AppSizes.heroExpandedHeight / 2,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(detail?.subject.name ?? ''),
                  background: detail == null
                      ? null
                      : _Header(subject: detail.subject),
                ),
              ),
              SliverToBoxAdapter(child: _content(context, state)),
            ],
          );
        },
      ),
    );
  }

  Widget _content(BuildContext context, ResourceState<SubjectDetail> state) {
    if (state.isLoading) {
      return SkeletonList(
        shrinkWrap: true,
        itemCount: 4,
        padding: const EdgeInsetsDirectional.all(AppSpacing.gutter),
        itemBuilder: (_) => const SkeletonRow(),
      );
    }
    if (state.status == ResourceStatus.failure && state.data == null) {
      return SizedBox(
        height: 360,
        child: FailureView(
          failure: state.failure!,
          onRetry: () =>
              context.read<SubjectDetailBloc>().add(const ResourceRequested()),
        ),
      );
    }
    final courses = state.data!.courses;
    if (courses.isEmpty) {
      return SizedBox(
        height: 320,
        child: EmptyState(title: context.l10n.subjectNoCourses),
      );
    }
    return ContentConstraint(
      child: Padding(
        padding: const EdgeInsetsDirectional.all(AppSpacing.gutter),
        child: Column(
          children: [
            for (var i = 0; i < courses.length; i++)
              Padding(
                padding: const EdgeInsetsDirectional.only(
                  bottom: AppSpacing.md,
                ),
                child: Staggered(
                  index: i,
                  child: CourseCardView(
                    course: courses[i],
                    variant: CourseCardVariant.horizontal,
                    enableHero: true,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.subject});

  final Subject subject;

  @override
  Widget build(BuildContext context) {
    final tint = context.palette.tintFor(subject.colorClass);
    return ColoredBox(
      color: tint.background,
      child: Align(
        alignment: const AlignmentDirectional(0.8, 0),
        child: Icon(
          CatalogIcons.resolve(subject.icon),
          size: AppSizes.avatarXl,
          color: tint.foreground.withValues(alpha: 0.35),
        ),
      ),
    );
  }
}
