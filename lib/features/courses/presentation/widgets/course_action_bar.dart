import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ibnzaidon/app/router/app_routes.dart';
import 'package:ibnzaidon/core/utils/context_extensions.dart';
import 'package:ibnzaidon/core/utils/formatters.dart';
import 'package:ibnzaidon/design_system/components/app_button.dart';
import 'package:ibnzaidon/design_system/components/price_view.dart';
import 'package:ibnzaidon/design_system/components/skeleton.dart';
import 'package:ibnzaidon/design_system/tokens/app_tokens.dart';
import 'package:ibnzaidon/features/courses/domain/entities/course_content.dart';
import 'package:ibnzaidon/features/courses/presentation/bloc/course_detail_bloc.dart';
import 'package:ibnzaidon/features/courses/presentation/bloc/purchase_bloc.dart';
import 'package:ibnzaidon/features/courses/presentation/widgets/activation_sheet.dart';
import 'package:ibnzaidon/shared/domain/entities/course.dart';
import 'package:ibnzaidon/shared/presentation/auth_gate.dart';

/// Sticky bottom bar: Continue / Start / Buy / Activate / Sign in.
class CourseActionBar extends StatelessWidget {
  const CourseActionBar({required this.state, super.key});

  final CourseDetailState state;

  @override
  Widget build(BuildContext context) {
    final detail = state.detail;
    if (detail == null) return const SizedBox.shrink();
    final scheme = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        border: Border(top: BorderSide(color: scheme.outlineVariant)),
        boxShadow: AppShadows.raised(context),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
          child: _Actions(state: state, detail: detail),
        ),
      ),
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({required this.state, required this.detail});

  final CourseDetailState state;
  final CourseDetail detail;

  int? _firstLessonId() {
    for (final unit in detail.units) {
      if (unit.lessons.isNotEmpty) return unit.lessons.first.id;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final signedIn = context.isSignedIn;
    final course = detail.course;

    if (!signedIn) {
      final from = Uri.encodeComponent(
        GoRouterState.of(context).uri.toString(),
      );
      return AppButton(
        label: l10n.courseActionSignIn,
        icon: Icons.login_rounded,
        onPressed: () => context.push('${AppRoutes.login}?from=$from'),
      );
    }

    if (course.isFree) {
      final firstLesson = _firstLessonId();
      return AppButton(
        label: l10n.courseActionStartFree,
        icon: Icons.play_arrow_rounded,
        onPressed: firstLesson == null
            ? null
            : () => context.push(AppRoutes.lesson(course.id, firstLesson)),
      );
    }

    // Real enrollment is only known once the lock-aware `units` call
    // resolves (the public `courses/{id}` response doesn't reliably carry
    // `is_enrolled`). Showing "Activate" before that would flash the wrong
    // button for a split second on a course the student already owns.
    if (!state.unitsResolved) {
      return const _ResolvingActionBar();
    }

    if (state.isEnrolled) {
      return _ContinueAction(state: state, courseId: course.id);
    }

    return _PurchaseActions(course: course);
  }
}

class _ResolvingActionBar extends StatelessWidget {
  const _ResolvingActionBar();

  @override
  Widget build(BuildContext context) => const SkeletonShimmer(
    child: SkeletonBox(height: AppSizes.buttonHeight, radius: AppRadii.button),
  );
}

class _ContinueAction extends StatelessWidget {
  const _ContinueAction({required this.state, required this.courseId});

  final CourseDetailState state;
  final int courseId;

  int? _fallbackLessonId() {
    for (final unit in state.units?.units ?? const <CourseUnit>[]) {
      if (unit.lessons.isNotEmpty) return unit.lessons.first.id;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final target = state.nextLesson?.id ?? _fallbackLessonId();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: AppRadii.pillRadius,
                child: LinearProgressIndicator(
                  value: state.progressFraction,
                  minHeight: AppSpacing.sm,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              l10n.courseProgressLabel(
                AppFormatters.percent(state.progressFraction),
              ),
              style: context.text.labelMedium,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        AppButton(
          label: l10n.courseActionContinue,
          icon: Icons.play_arrow_rounded,
          onPressed: target == null
              ? null
              : () => context.push(AppRoutes.lesson(courseId, target)),
        ),
      ],
    );
  }
}

class _PurchaseActions extends StatelessWidget {
  const _PurchaseActions({required this.course});

  final Course course;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final purchase = context.read<PurchaseBloc>();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (purchase.isSupported && course.canPurchaseViaStore)
          PriceGate(
            child: BlocBuilder<PurchaseBloc, PurchaseState>(
              builder: (context, purchaseState) => Column(
                children: [
                  AppButton(
                    label: l10n.courseActionBuy(
                      AppFormatters.currency(
                        course.price,
                        context.languageCode,
                      ),
                    ),
                    icon: Icons.shopping_bag_outlined,
                    isLoading: purchaseState.isBusy,
                    onPressed: () => purchase.add(PurchaseRequested(course.id)),
                  ),
                  AppButton(
                    label: l10n.purchaseRestore,
                    variant: AppButtonVariant.text,
                    expanded: false,
                    onPressed: purchaseState.isBusy
                        ? null
                        : () => purchase.add(const PurchaseRestoreRequested()),
                  ),
                ],
              ),
            ),
          ),
        AppButton(
          label: l10n.courseActionActivate,
          icon: Icons.confirmation_number_outlined,
          variant: AppButtonVariant.secondary,
          onPressed: () async {
            final bloc = context.read<CourseDetailBloc>();
            final activated = await showActivationSheet(
              context,
              courseId: course.id,
            );
            if (activated) bloc.add(const CourseDetailRefreshed());
          },
        ),
      ],
    );
  }
}
