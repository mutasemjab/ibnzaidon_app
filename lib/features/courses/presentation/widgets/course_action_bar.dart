import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ibnzaidon/app/router/app_routes.dart';
import 'package:ibnzaidon/core/utils/context_extensions.dart';
import 'package:ibnzaidon/core/utils/formatters.dart';
import 'package:ibnzaidon/design_system/components/app_button.dart';
import 'package:ibnzaidon/design_system/components/price_view.dart';
import 'package:ibnzaidon/design_system/tokens/app_tokens.dart';
import 'package:ibnzaidon/features/courses/domain/entities/course_content.dart';
import 'package:ibnzaidon/features/courses/presentation/bloc/course_detail_bloc.dart';
import 'package:ibnzaidon/features/courses/presentation/bloc/purchase_bloc.dart';
import 'package:ibnzaidon/features/courses/presentation/widgets/activation_sheet.dart';
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
          child: _buildActions(context, detail),
        ),
      ),
    );
  }

  int? _firstLessonId(CourseDetail detail) {
    for (final unit in detail.units) {
      if (unit.lessons.isNotEmpty) return unit.lessons.first.id;
    }
    return null;
  }

  Widget _buildActions(BuildContext context, CourseDetail detail) {
    final l10n = context.l10n;
    final signedIn = context.isSignedIn;
    final courseId = detail.course.id;
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

    if (state.isEnrolled) {
      final next = state.nextLesson;
      final target = next?.id ?? _firstLessonId(detail);
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

    if (course.isFree) {
      final firstLesson = _firstLessonId(detail);
      return AppButton(
        label: l10n.courseActionStartFree,
        icon: Icons.play_arrow_rounded,
        onPressed: firstLesson == null
            ? null
            : () => context.push(AppRoutes.lesson(courseId, firstLesson)),
      );
    }

    final purchase = context.read<PurchaseBloc>();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (purchase.isSupported && (course.canPurchaseViaStore))
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
                    onPressed: () => purchase.add(PurchaseRequested(courseId)),
                  ),
                  TextButton(
                    onPressed: purchaseState.isBusy
                        ? null
                        : () => purchase.add(const PurchaseRestoreRequested()),
                    child: Text(l10n.purchaseRestore),
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
              courseId: courseId,
            );
            if (activated) bloc.add(const CourseDetailRefreshed());
          },
        ),
      ],
    );
  }
}
