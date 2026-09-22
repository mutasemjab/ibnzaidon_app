import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ibnzaidon/core/bloc/paged_bloc.dart';
import 'package:ibnzaidon/core/bloc/resource_bloc.dart';
import 'package:ibnzaidon/core/di/injector.dart';
import 'package:ibnzaidon/core/utils/context_extensions.dart';
import 'package:ibnzaidon/design_system/components/app_button.dart';
import 'package:ibnzaidon/design_system/components/overlays.dart';
import 'package:ibnzaidon/design_system/tokens/app_tokens.dart';
import 'package:ibnzaidon/features/catalog/domain/entities/catalog_entities.dart';
import 'package:ibnzaidon/features/catalog/presentation/bloc/catalog_blocs.dart';
import 'package:ibnzaidon/features/courses/domain/entities/course_content.dart';
import 'package:ibnzaidon/features/teachers/presentation/bloc/teachers_bloc.dart';
import 'package:ibnzaidon/shared/domain/entities/course.dart';

/// Filter sheet (category, subject, teacher, featured/trending). Resolves to
/// the new [CourseQuery] or `null` when dismissed.
Future<CourseQuery?> showCourseFiltersSheet(
  BuildContext context, {
  required CourseQuery current,
}) {
  return showAppBottomSheet<CourseQuery>(
    context,
    title: context.l10n.coursesFiltersTitle,
    builder: (_) => MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              getIt<CategoriesBloc>()..add(const ResourceRequested()),
        ),
        BlocProvider(
          create: (_) =>
              getIt<TeachersBloc>()..add(const PagedStarted<TeachersQuery>()),
        ),
      ],
      child: _FiltersBody(initial: current),
    ),
  );
}

class _FiltersBody extends StatefulWidget {
  const _FiltersBody({required this.initial});

  final CourseQuery initial;

  @override
  State<_FiltersBody> createState() => _FiltersBodyState();
}

class _FiltersBodyState extends State<_FiltersBody> {
  late CourseQuery _draft = widget.initial;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SingleChildScrollView(
      padding: const EdgeInsetsDirectional.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: AppSpacing.sm,
            children: [
              FilterChip(
                label: Text(l10n.coursesFilterFeatured),
                selected: _draft.featured,
                onSelected: (value) =>
                    setState(() => _draft = _draft.copyWith(featured: value)),
              ),
              FilterChip(
                label: Text(l10n.coursesFilterTrending),
                selected: _draft.trending,
                onSelected: (value) =>
                    setState(() => _draft = _draft.copyWith(trending: value)),
              ),
            ],
          ),
          _Title(l10n.coursesFilterCategory),
          BlocBuilder<CategoriesBloc, ResourceState<List<Category>>>(
            builder: (context, state) => Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final category in state.data ?? const <Category>[])
                  ChoiceChip(
                    label: Text(category.name),
                    selected: _draft.categoryId == category.id,
                    onSelected: (selected) => setState(
                      () => _draft = selected
                          ? _draft.copyWith(
                              categoryId: category.id,
                              clearSubject: true,
                            )
                          : _draft.copyWith(
                              clearCategory: true,
                              clearSubject: true,
                            ),
                    ),
                  ),
              ],
            ),
          ),
          if (_draft.categoryId != null) ...[
            _Title(l10n.coursesFilterSubject),
            BlocProvider(
              key: ValueKey(_draft.categoryId),
              create: (_) =>
                  getIt<CategoryDetailBloc>(param1: _draft.categoryId)
                    ..add(const ResourceRequested()),
              child:
                  BlocBuilder<
                    CategoryDetailBloc,
                    ResourceState<CategoryDetail>
                  >(
                    builder: (context, state) => Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        for (final subject
                            in state.data?.subjects ?? const <Subject>[])
                          ChoiceChip(
                            label: Text(subject.name),
                            selected: _draft.subjectId == subject.id,
                            onSelected: (selected) => setState(
                              () => _draft = selected
                                  ? _draft.copyWith(subjectId: subject.id)
                                  : _draft.copyWith(clearSubject: true),
                            ),
                          ),
                      ],
                    ),
                  ),
            ),
          ],
          _Title(l10n.coursesFilterTeacher),
          BlocBuilder<TeachersBloc, PagedState<Teacher, TeachersQuery>>(
            builder: (context, state) => Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final teacher in state.items)
                  ChoiceChip(
                    label: Text(teacher.name),
                    selected: _draft.teacherId == teacher.id,
                    onSelected: (selected) => setState(
                      () => _draft = selected
                          ? _draft.copyWith(teacherId: teacher.id)
                          : _draft.copyWith(clearTeacher: true),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: l10n.commonReset,
                  variant: AppButtonVariant.secondary,
                  onPressed: () => Navigator.of(context).pop(
                    CourseQuery(search: widget.initial.search),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppButton(
                  label: l10n.commonApply,
                  onPressed: () => Navigator.of(context).pop(_draft),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsetsDirectional.only(
      top: AppSpacing.xl,
      bottom: AppSpacing.sm,
    ),
    child: Text(text, style: context.text.titleSmall),
  );
}
