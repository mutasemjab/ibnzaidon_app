import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ibnzaidon/app/router/app_routes.dart';
import 'package:ibnzaidon/core/di/injector.dart';
import 'package:ibnzaidon/core/l10n/failure_message.dart';
import 'package:ibnzaidon/core/services/screen_security.dart';
import 'package:ibnzaidon/core/utils/context_extensions.dart';
import 'package:ibnzaidon/design_system/components/app_button.dart';
import 'package:ibnzaidon/design_system/components/exam_timer.dart';
import 'package:ibnzaidon/design_system/components/layout_helpers.dart';
import 'package:ibnzaidon/design_system/components/overlays.dart';
import 'package:ibnzaidon/design_system/components/skeleton.dart';
import 'package:ibnzaidon/design_system/components/state_views.dart';
import 'package:ibnzaidon/design_system/tokens/app_tokens.dart';
import 'package:ibnzaidon/features/exams/presentation/bloc/exam_taking_bloc.dart';
import 'package:ibnzaidon/features/exams/presentation/pages/exam_result_page.dart';
import 'package:ibnzaidon/features/exams/presentation/widgets/exam_navigator_sheet.dart';
import 'package:ibnzaidon/features/exams/presentation/widgets/exam_question_view.dart';
import 'package:ibnzaidon/shared/presentation/failure_view.dart';

class ExamTakingPage extends StatelessWidget {
  const ExamTakingPage({required this.examId, super.key});

  final int examId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<ExamTakingBloc>(param1: examId)
            ..add(const ExamAttemptStarted()),
      child: _ExamTakingView(examId: examId),
    );
  }
}

class _ExamTakingView extends StatefulWidget {
  const _ExamTakingView({required this.examId});

  final int examId;

  @override
  State<_ExamTakingView> createState() => _ExamTakingViewState();
}

class _ExamTakingViewState extends State<_ExamTakingView> {
  late final ScreenSecurity _security = getIt<ScreenSecurity>();

  @override
  void initState() {
    super.initState();
    _security.enable();
  }

  @override
  void dispose() {
    _security.disable();
    super.dispose();
  }

  Future<void> _confirmLeave() async {
    final l10n = context.l10n;
    final leave = await showConfirmDialog(
      context,
      title: l10n.examLeaveTitle,
      message: l10n.examLeaveBody,
      confirmLabel: l10n.examLeaveConfirm,
      destructive: true,
      icon: Icons.exit_to_app_rounded,
    );
    if (leave && mounted) context.pop();
  }

  Future<void> _confirmSubmit(ExamTakingState state) async {
    final l10n = context.l10n;
    final bloc = context.read<ExamTakingBloc>();
    final unanswered = state.unansweredCount;
    final confirmed = await showConfirmDialog(
      context,
      title: l10n.examSubmitConfirmTitle,
      message: unanswered > 0
          ? l10n.examSubmitConfirmUnanswered(unanswered)
          : l10n.examSubmitConfirmAll,
      confirmLabel: l10n.examSubmit,
      icon: Icons.send_rounded,
    );
    if (confirmed) bloc.add(const ExamSubmitRequested());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return MultiBlocListener(
      listeners: [
        BlocListener<ExamTakingBloc, ExamTakingState>(
          listenWhen: (a, b) =>
              a.status != b.status && b.status == ExamTakingStatus.submitted,
          listener: (context, state) => context.pushReplacement(
            AppRoutes.examResult(widget.examId),
            extra: ExamResultArgs(
              result: state.result!,
              exam: state.session!.detail.exam,
            ),
          ),
        ),
        BlocListener<ExamTakingBloc, ExamTakingState>(
          listenWhen: (a, b) => !a.submitFailed && b.submitFailed,
          listener: (context, state) => AppSnackbar.show(
            context,
            state.failure?.localized(l10n) ?? l10n.examSubmitFailed,
            type: AppSnackbarType.error,
            actionLabel: l10n.commonRetry,
            onAction: () => context.read<ExamTakingBloc>().add(
              ExamSubmitRequested(auto: state.autoSubmitted),
            ),
          ),
        ),
      ],
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _confirmLeave();
        },
        child: BlocBuilder<ExamTakingBloc, ExamTakingState>(
          builder: (context, state) => Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              leading: state.status == ExamTakingStatus.failure
                  ? BackButton(onPressed: () => context.pop())
                  : null,
              title: Text(
                state.session?.detail.exam.title ?? l10n.examsTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              actions: [
                if (state.session != null)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(
                      end: AppSpacing.md,
                    ),
                    child: ExamTimer(
                      remaining: state.remaining,
                      total: state.totalDuration,
                    ),
                  ),
              ],
            ),
            body: _body(context, state),
            bottomNavigationBar:
                state.session == null || state.questions.isEmpty
                ? null
                : _BottomBar(
                    state: state,
                    onSubmit: () => _confirmSubmit(state),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _body(BuildContext context, ExamTakingState state) {
    final l10n = context.l10n;
    if (state.status == ExamTakingStatus.loading) {
      return const SkeletonShimmer(
        child: Padding(
          padding: EdgeInsetsDirectional.all(AppSpacing.gutter),
          child: Column(
            children: [
              SkeletonBox(height: 28),
              SizedBox(height: AppSpacing.xl),
              SkeletonBox(height: 56, radius: AppRadii.field),
              SizedBox(height: AppSpacing.md),
              SkeletonBox(height: 56, radius: AppRadii.field),
              SizedBox(height: AppSpacing.md),
              SkeletonBox(height: 56, radius: AppRadii.field),
            ],
          ),
        ),
      );
    }
    if (state.status == ExamTakingStatus.failure) {
      return FailureView(
        failure: state.failure!,
        onRetry: () =>
            context.read<ExamTakingBloc>().add(const ExamAttemptStarted()),
      );
    }
    final question = state.currentQuestion;
    if (question == null) {
      return EmptyState(icon: Icons.quiz_outlined, title: l10n.examNoQuestions);
    }
    final bloc = context.read<ExamTakingBloc>();
    return Stack(
      children: [
        ContentConstraint(
          child: Column(
            children: [
              LinearProgressIndicator(
                value: (state.currentIndex + 1) / state.questions.length,
                minHeight: AppSpacing.xs,
              ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: AppMotion.medium,
                  child: ExamQuestionView(
                    key: ValueKey(question.id),
                    question: question,
                    index: state.currentIndex,
                    total: state.questions.length,
                    selectedOptionId: state.answers[question.id],
                    isFlagged: state.flagged.contains(question.id),
                    onSelect: (optionId) => bloc.add(
                      ExamOptionSelected(
                        questionId: question.id,
                        optionId: optionId,
                      ),
                    ),
                    onClear: () => bloc.add(ExamAnswerCleared(question.id)),
                    onToggleFlag: () =>
                        bloc.add(ExamQuestionFlagToggled(question.id)),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (state.isSubmitting) _SubmittingOverlay(auto: state.autoSubmitted),
      ],
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.state, required this.onSubmit});

  final ExamTakingState state;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bloc = context.read<ExamTakingBloc>();
    final isLast = state.currentIndex == state.questions.length - 1;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerLowest,
        border: Border(top: BorderSide(color: context.colors.outlineVariant)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsetsDirectional.all(AppSpacing.md),
          child: Row(
            children: [
              IconButton.filledTonal(
                tooltip: l10n.commonPrevious,
                onPressed: state.currentIndex == 0 || state.isSubmitting
                    ? null
                    : () => bloc.add(
                        ExamQuestionSelected(state.currentIndex - 1),
                      ),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              const SizedBox(width: AppSpacing.sm),
              IconButton.filledTonal(
                tooltip: l10n.examNavigator,
                onPressed: state.isSubmitting
                    ? null
                    : () async {
                        final index = await showExamNavigatorSheet(
                          context,
                          state: state,
                        );
                        if (index != null) {
                          bloc.add(ExamQuestionSelected(index));
                        }
                      },
                icon: const Icon(Icons.grid_view_rounded),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: isLast
                    ? AppButton(
                        label: l10n.examSubmit,
                        icon: Icons.send_rounded,
                        isLoading: state.isSubmitting,
                        onPressed: onSubmit,
                      )
                    : AppButton(
                        label: l10n.commonNext,
                        onPressed: state.isSubmitting
                            ? null
                            : () => bloc.add(
                                ExamQuestionSelected(state.currentIndex + 1),
                              ),
                      ),
              ),
              if (!isLast) ...[
                const SizedBox(width: AppSpacing.sm),
                IconButton(
                  tooltip: l10n.examSubmit,
                  onPressed: state.isSubmitting ? null : onSubmit,
                  icon: const Icon(Icons.send_rounded),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SubmittingOverlay extends StatelessWidget {
  const _SubmittingOverlay({required this.auto});

  final bool auto;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Positioned.fill(
      child: ColoredBox(
        color: context.colors.scrim.withValues(alpha: 0.5),
        child: Center(
          child: Card(
            child: Padding(
              padding: const EdgeInsetsDirectional.all(AppSpacing.xxl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    auto ? l10n.examTimeUpTitle : l10n.examSubmitting,
                    style: context.text.titleMedium,
                  ),
                  if (auto)
                    Text(l10n.examTimeUpBody, style: context.text.bodyMedium),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
