import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ibnzaidon/app/router/app_routes.dart';
import 'package:ibnzaidon/core/bloc/resource_bloc.dart';
import 'package:ibnzaidon/core/di/injector.dart';
import 'package:ibnzaidon/core/utils/context_extensions.dart';
import 'package:ibnzaidon/design_system/components/app_button.dart';
import 'package:ibnzaidon/design_system/components/app_card.dart';
import 'package:ibnzaidon/design_system/components/chips.dart';
import 'package:ibnzaidon/design_system/components/layout_helpers.dart';
import 'package:ibnzaidon/design_system/components/overlays.dart';
import 'package:ibnzaidon/design_system/components/skeleton.dart';
import 'package:ibnzaidon/design_system/tokens/app_tokens.dart';
import 'package:ibnzaidon/features/exams/domain/entities/exam_entities.dart';
import 'package:ibnzaidon/features/exams/presentation/bloc/exams_blocs.dart';
import 'package:ibnzaidon/features/exams/presentation/widgets/exam_cards.dart';
import 'package:ibnzaidon/shared/presentation/auth_gate.dart';
import 'package:ibnzaidon/shared/presentation/failure_view.dart';

class ExamDetailPage extends StatelessWidget {
  const ExamDetailPage({required this.examId, super.key});

  final int examId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<ExamDetailBloc>(param1: examId)..add(const ResourceRequested()),
      child: Scaffold(
        appBar: AppBar(title: Text(context.l10n.examDetailTitle)),
        body: BlocBuilder<ExamDetailBloc, ResourceState<ExamDetail>>(
          builder: (context, state) {
            if (state.isLoading) return const _Skeleton();
            final detail = state.data;
            if (detail == null) {
              return FailureView(
                failure: state.failure!,
                onRetry: () => context.read<ExamDetailBloc>().add(
                  const ResourceRequested(),
                ),
              );
            }
            return ContentConstraint(
              child: Column(
                children: [
                  Expanded(
                    child: _Body(
                      exam: detail.exam,
                      questionCount: detail.questions.length,
                    ),
                  ),
                  _StartBar(exam: detail.exam),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.exam, required this.questionCount});

  final Exam exam;
  final int questionCount;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final total = exam.totalQuestions > 0 ? exam.totalQuestions : questionCount;
    return ListView(
      padding: const EdgeInsetsDirectional.all(AppSpacing.gutter),
      children: [
        Text(exam.title, style: context.text.headlineSmall),
        if (exam.course != null || exam.subject != null)
          Padding(
            padding: const EdgeInsetsDirectional.only(top: AppSpacing.xs),
            child: Text(
              [
                exam.course?.name,
                exam.subject?.name,
              ].whereType<String>().join(' · '),
              style: context.text.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ),
        const SizedBox(height: AppSpacing.lg),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            StatChip(
              icon: Icons.help_outline_rounded,
              label: l10n.commonQuestionsCount(total),
            ),
            if (exam.durationMinutes > 0)
              StatChip(
                icon: Icons.timer_outlined,
                label: l10n.examDurationMinutes(exam.durationMinutes),
              ),
            if (exam.totalMarks > 0)
              StatChip(
                icon: Icons.stars_rounded,
                label: l10n.examTotalMarks(formatMarks(exam.totalMarks)),
              ),
            if (exam.passingMarks != null)
              StatChip(
                icon: Icons.flag_rounded,
                label: l10n.examPassMarks(formatMarks(exam.passingMarks!)),
              ),
            if (exam.difficulty != null)
              StatChip(
                icon: Icons.signal_cellular_alt_rounded,
                label: exam.difficulty!,
              ),
          ],
        ),
        if (exam.description != null) ...[
          const SizedBox(height: AppSpacing.lg),
          Text(exam.description!, style: context.text.bodyMedium),
        ],
        const SizedBox(height: AppSpacing.xl),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.examRulesTitle, style: context.text.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              _Rule(text: l10n.examRuleTimer, icon: Icons.timer_outlined),
              _Rule(text: l10n.examRuleAutosave, icon: Icons.save_outlined),
              _Rule(text: l10n.examRuleAutoSubmit, icon: Icons.send_rounded),
              if (exam.instructions != null) ...[
                const Divider(height: AppSpacing.xl),
                Text(l10n.examInstructions, style: context.text.titleSmall),
                const SizedBox(height: AppSpacing.xs),
                Text(exam.instructions!, style: context.text.bodyMedium),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _Rule extends StatelessWidget {
  const _Rule({required this.text, required this.icon});

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsetsDirectional.only(top: AppSpacing.sm),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: AppSizes.iconMd, color: context.colors.primary),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: Text(text, style: context.text.bodyMedium)),
      ],
    ),
  );
}

class _StartBar extends StatelessWidget {
  const _StartBar({required this.exam});

  final Exam exam;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final signedIn = context.isSignedIn;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
        child: AppButton(
          label: signedIn ? l10n.examStart : l10n.examSignInToStart,
          icon: signedIn ? Icons.play_arrow_rounded : Icons.login_rounded,
          onPressed: () async {
            if (!signedIn) {
              final from = Uri.encodeComponent(AppRoutes.exam(exam.id));
              await context.push('${AppRoutes.login}?from=$from');
              return;
            }
            final confirmed = await showConfirmDialog(
              context,
              title: l10n.examStartConfirmTitle,
              message: l10n.examStartConfirmBody(exam.durationMinutes),
              confirmLabel: l10n.examStart,
              icon: Icons.timer_outlined,
            );
            if (confirmed && context.mounted) {
              await context.push(AppRoutes.examTake(exam.id));
            }
          },
        ),
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
          SkeletonBox(height: 28),
          SizedBox(height: AppSpacing.lg),
          SkeletonBox(height: 36, radius: AppRadii.pill),
          SizedBox(height: AppSpacing.xl),
          SkeletonBox(height: 160, radius: AppRadii.card),
        ],
      ),
    ),
  );
}
