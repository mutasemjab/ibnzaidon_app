import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ibnzaidon/core/bloc/paged_bloc.dart';
import 'package:ibnzaidon/core/di/injector.dart';
import 'package:ibnzaidon/core/utils/context_extensions.dart';
import 'package:ibnzaidon/design_system/components/layout_helpers.dart';
import 'package:ibnzaidon/design_system/components/skeleton.dart';
import 'package:ibnzaidon/design_system/components/state_views.dart';
import 'package:ibnzaidon/design_system/tokens/app_tokens.dart';
import 'package:ibnzaidon/features/exams/domain/entities/exam_entities.dart';
import 'package:ibnzaidon/features/exams/presentation/bloc/exams_blocs.dart';
import 'package:ibnzaidon/features/exams/presentation/widgets/exam_cards.dart';
import 'package:ibnzaidon/shared/presentation/auth_gate.dart';
import 'package:ibnzaidon/shared/presentation/paged_bloc_view.dart';

/// Exam list with search and exam-type chips.
class ExamsPage extends StatelessWidget {
  const ExamsPage({this.initialQuery = const ExamQuery(), super.key});

  final ExamQuery initialQuery;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.examsTitle)),
      body: AuthGate(
        builder: (_) => BlocProvider(
          create: (_) =>
              getIt<ExamsBloc>(param1: initialQuery)
                ..add(const PagedStarted<ExamQuery>()),
          child: const _ExamsView(),
        ),
      ),
    );
  }
}

class _ExamsView extends StatelessWidget {
  const _ExamsView();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bloc = context.read<ExamsBloc>();
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
                PagedQueryChanged(
                  bloc.state.query.copyWith(search: value),
                  debounce: true,
                ),
              ),
              decoration: InputDecoration(
                hintText: l10n.examsSearchHint,
                prefixIcon: const Icon(Icons.search_rounded),
              ),
            ),
          ),
          BlocBuilder<ExamsBloc, PagedState<Exam, ExamQuery>>(
            buildWhen: (a, b) => a.items != b.items || a.query != b.query,
            builder: (context, state) {
              final types = {
                for (final exam in state.items)
                  if (exam.examType != null) exam.examType!,
              };
              if (types.isEmpty && state.query.examType == null) {
                return const SizedBox.shrink();
              }
              return SizedBox(
                height: AppSizes.touchTarget,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: AppSpacing.pagePadding,
                  children: [
                    for (final type in {...types, ?state.query.examType})
                      Padding(
                        padding: const EdgeInsetsDirectional.only(
                          end: AppSpacing.sm,
                        ),
                        child: ChoiceChip(
                          label: Text(type),
                          selected: state.query.examType == type,
                          onSelected: (selected) => bloc.add(
                            PagedQueryChanged(
                              selected
                                  ? state.query.copyWith(examType: type)
                                  : state.query.copyWith(clearType: true),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
          Expanded(
            child: PagedBlocView<ExamsBloc, Exam, ExamQuery>(
              gridColumns: context.isTablet ? 2 : null,
              gridChildAspectRatio: 2.6,
              skeletonBuilder: (_) => const SkeletonRow(),
              emptyBuilder: (_) => EmptyState(
                icon: Icons.quiz_outlined,
                title: l10n.examsEmptyTitle,
              ),
              itemBuilder: (context, exam, _) => ExamCard(exam: exam),
            ),
          ),
        ],
      ),
    );
  }
}

/// Attempt history (`GET my-exams`).
class MyExamsPage extends StatelessWidget {
  const MyExamsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.myExamsTitle)),
      body: ContentConstraint(
        child: AuthGate(
          message: l10n.myExamsGate,
          builder: (_) => BlocProvider(
            create: (_) =>
                getIt<MyExamsBloc>()..add(const PagedStarted<NoQuery>()),
            child: PagedBlocView<MyExamsBloc, AttemptHistoryItem, NoQuery>(
              skeletonBuilder: (_) => const SkeletonRow(),
              emptyBuilder: (_) => EmptyState(
                icon: Icons.history_edu_rounded,
                title: l10n.myExamsEmptyTitle,
                message: l10n.myExamsEmptyBody,
              ),
              itemBuilder: (context, attempt, _) =>
                  AttemptCard(attempt: attempt),
            ),
          ),
        ),
      ),
    );
  }
}
