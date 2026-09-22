import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ibnzaidon/core/di/injector.dart';
import 'package:ibnzaidon/core/l10n/failure_message.dart';
import 'package:ibnzaidon/core/utils/context_extensions.dart';
import 'package:ibnzaidon/design_system/components/app_tabs.dart';
import 'package:ibnzaidon/design_system/components/layout_helpers.dart';
import 'package:ibnzaidon/design_system/components/overlays.dart';
import 'package:ibnzaidon/design_system/components/skeleton.dart';
import 'package:ibnzaidon/design_system/tokens/app_tokens.dart';
import 'package:ibnzaidon/features/courses/presentation/bloc/course_detail_bloc.dart';
import 'package:ibnzaidon/features/courses/presentation/bloc/purchase_bloc.dart';
import 'package:ibnzaidon/features/courses/presentation/widgets/course_action_bar.dart';
import 'package:ibnzaidon/features/courses/presentation/widgets/course_content_tab.dart';
import 'package:ibnzaidon/features/courses/presentation/widgets/course_detail_sections.dart';
import 'package:ibnzaidon/shared/presentation/failure_view.dart';

class CourseDetailPage extends StatelessWidget {
  const CourseDetailPage({required this.courseId, super.key});

  final int courseId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<CourseDetailBloc>(param1: courseId)
            ..add(const CourseDetailRequested()),
      child: BlocListener<PurchaseBloc, PurchaseState>(
        listenWhen: (previous, current) =>
            previous.status != current.status && current.courseId == courseId,
        listener: _onPurchaseChanged,
        child: const _CourseDetailView(),
      ),
    );
  }

  void _onPurchaseChanged(BuildContext context, PurchaseState state) {
    final l10n = context.l10n;
    switch (state.status) {
      case PurchaseStatus.success:
        AppSnackbar.show(
          context,
          l10n.purchaseSuccess,
          type: AppSnackbarType.success,
        );
        context.read<CourseDetailBloc>().add(const CourseDetailRefreshed());
      case PurchaseStatus.pending:
        AppSnackbar.show(context, l10n.purchasePending);
      case PurchaseStatus.cancelled:
        AppSnackbar.show(context, l10n.purchaseCancelled);
      case PurchaseStatus.verifying:
        AppSnackbar.show(context, l10n.purchaseVerifying);
      case PurchaseStatus.failure when state.canRetryVerification:
        AppSnackbar.show(
          context,
          l10n.purchaseVerifyFailed,
          type: AppSnackbarType.error,
          actionLabel: l10n.commonRetry,
          onAction: () => context.read<PurchaseBloc>().add(
            const PurchaseVerificationRetried(),
          ),
        );
      case PurchaseStatus.failure:
        AppSnackbar.show(
          context,
          state.failure?.localized(l10n) ?? l10n.purchaseFailed,
          type: AppSnackbarType.error,
        );
      case PurchaseStatus.idle || PurchaseStatus.purchasing:
        break;
    }
  }
}

class _CourseDetailView extends StatefulWidget {
  const _CourseDetailView();

  @override
  State<_CourseDetailView> createState() => _CourseDetailViewState();
}

class _CourseDetailViewState extends State<_CourseDetailView> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocBuilder<CourseDetailBloc, CourseDetailState>(
      builder: (context, state) {
        final detail = state.detail;
        final bloc = context.read<CourseDetailBloc>();
        return Scaffold(
          body: AppRefreshIndicator(
            onRefresh: () async => bloc.add(const CourseDetailRefreshed()),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                CourseHero(detail: detail),
                if (state.isLoading)
                  const SliverToBoxAdapter(child: _DetailSkeleton())
                else if (detail == null)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: FailureView(
                      failure: state.failure!,
                      onRetry: () => bloc.add(const CourseDetailRequested()),
                    ),
                  )
                else ...[
                  SliverToBoxAdapter(child: CourseSummary(detail: detail)),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: AppSpacing.pagePadding,
                      child: AppSegmentedControl<int>(
                        segments: {
                          0: l10n.courseTabContent,
                          1: l10n.courseTabAbout,
                          2: l10n.courseTabReviews,
                        },
                        selected: _tab,
                        onChanged: (value) => setState(() => _tab = value),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: AppSpacing.lg),
                  ),
                  SliverToBoxAdapter(
                    child: AnimatedSwitcher(
                      duration: AppMotion.medium,
                      child: KeyedSubtree(
                        key: ValueKey(_tab),
                        child: switch (_tab) {
                          0 => CourseContentTab(state: state),
                          1 => CourseAboutTab(detail: detail),
                          _ => const CourseReviewsTab(),
                        },
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: AppSpacing.massive),
                  ),
                ],
              ],
            ),
          ),
          bottomNavigationBar: state.detail == null
              ? null
              : ContentConstraint(child: CourseActionBar(state: state)),
        );
      },
    );
  }
}

class _DetailSkeleton extends StatelessWidget {
  const _DetailSkeleton();

  @override
  Widget build(BuildContext context) {
    return const SkeletonShimmer(
      child: Padding(
        padding: EdgeInsetsDirectional.all(AppSpacing.gutter),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonBox(height: 28),
            SizedBox(height: AppSpacing.md),
            SkeletonBox(width: 160, height: 20),
            SizedBox(height: AppSpacing.lg),
            SkeletonBox(height: 44, radius: AppRadii.pill),
            SizedBox(height: AppSpacing.lg),
            SkeletonBox(height: 72, radius: AppRadii.card),
            SizedBox(height: AppSpacing.md),
            SkeletonBox(height: 72, radius: AppRadii.card),
          ],
        ),
      ),
    );
  }
}
