import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ibnzaidon/app/router/app_routes.dart';
import 'package:ibnzaidon/core/di/injector.dart';
import 'package:ibnzaidon/core/utils/context_extensions.dart';
import 'package:ibnzaidon/design_system/components/app_button.dart';
import 'package:ibnzaidon/design_system/components/app_card.dart';
import 'package:ibnzaidon/design_system/components/app_network_image.dart';
import 'package:ibnzaidon/design_system/components/layout_helpers.dart';
import 'package:ibnzaidon/design_system/components/price_view.dart';
import 'package:ibnzaidon/design_system/components/skeleton.dart';
import 'package:ibnzaidon/design_system/tokens/app_tokens.dart';
import 'package:ibnzaidon/features/packages/domain/entities/package.dart';
import 'package:ibnzaidon/features/packages/presentation/bloc/package_detail_bloc.dart';
import 'package:ibnzaidon/features/packages/presentation/widgets/package_activation_sheet.dart';
import 'package:ibnzaidon/shared/domain/entities/course.dart';
import 'package:ibnzaidon/shared/presentation/auth_gate.dart';
import 'package:ibnzaidon/shared/presentation/failure_view.dart';

class PackageDetailPage extends StatelessWidget {
  const PackageDetailPage({required this.packageId, super.key});

  final int packageId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<PackageDetailBloc>(param1: packageId)
            ..add(const PackageDetailRequested()),
      child: const _PackageDetailView(),
    );
  }
}

class _PackageDetailView extends StatelessWidget {
  const _PackageDetailView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PackageDetailBloc, PackageDetailState>(
      builder: (context, state) => Scaffold(
        appBar: AppBar(
          title: Text(
            state.detail?.package.title ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        body: _body(context, state),
        bottomNavigationBar: state.detail == null
            ? null
            : ContentConstraint(child: _ActionBar(state: state)),
      ),
    );
  }

  Widget _body(BuildContext context, PackageDetailState state) {
    if (state.isLoading) return const _Skeleton();
    final detail = state.detail;
    if (detail == null) {
      return FailureView(
        failure: state.failure!,
        onRetry: () => context.read<PackageDetailBloc>().add(
          const PackageDetailRequested(),
        ),
      );
    }
    final l10n = context.l10n;
    final package = detail.package;
    return ContentConstraint(
      child: ListView(
        padding: AppSpacing.pagePadding,
        children: [
          if (package.description != null) ...[
            Text(package.description!, style: context.text.bodyMedium),
            const SizedBox(height: AppSpacing.lg),
          ],
          Row(
            children: [
              Flexible(
                child: PriceView(
                  price: package.price,
                  oldPrice: package.oldPrice,
                  large: true,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              if (package.discountPercent > 0)
                DiscountBadge(percent: package.discountPercent),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            l10n.packagePickHint(package.pickCount),
            style: context.text.titleSmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final course in detail.courses)
            Padding(
              padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.sm),
              child: _CourseTile(
                course: course,
                selected: state.selectedCourseIds.contains(course.id),
                onToggle: () => context.read<PackageDetailBloc>().add(
                  PackageCourseToggled(course.id),
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.massive),
        ],
      ),
    );
  }
}

class _CourseTile extends StatelessWidget {
  const _CourseTile({
    required this.course,
    required this.selected,
    required this.onToggle,
  });

  final Course course;
  final bool selected;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsetsDirectional.all(AppSpacing.sm),
      onTap: onToggle,
      child: Row(
        children: [
          AppNetworkImage(
            url: course.thumbnail,
            width: AppSizes.avatarLg,
            height: AppSizes.avatarLg,
            borderRadius: AppRadii.fieldRadius,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.titleSmall,
                ),
                if (course.teacher != null)
                  Text(
                    course.teacher!.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          Checkbox(value: selected, onChanged: (_) => onToggle()),
        ],
      ),
    );
  }
}

class _ActionBar extends StatelessWidget {
  const _ActionBar({required this.state});

  final PackageDetailState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = context.colors;
    final detail = state.detail!;
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
          child: context.isSignedIn
              ? _SignedInAction(state: state, detail: detail)
              : AppButton(
                  label: l10n.courseActionSignIn,
                  icon: Icons.login_rounded,
                  onPressed: () {
                    final from = Uri.encodeComponent(
                      GoRouterState.of(context).uri.toString(),
                    );
                    context.push('${AppRoutes.login}?from=$from');
                  },
                ),
        ),
      ),
    );
  }
}

class _SignedInAction extends StatelessWidget {
  const _SignedInAction({required this.state, required this.detail});

  final PackageDetailState state;
  final PackageDetail detail;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l10n.packageSelectedCount(
            state.selectedCourseIds.length,
            detail.package.pickCount,
          ),
          style: context.text.labelMedium,
        ),
        const SizedBox(height: AppSpacing.md),
        AppButton(
          label: l10n.packageActionActivate,
          icon: Icons.confirmation_number_outlined,
          onPressed: state.canActivate
              ? () async {
                  final activated = await showPackageActivationSheet(
                    context,
                    packageId: detail.package.id,
                    courseIds: state.selectedCourseIds.toList(),
                  );
                  if (activated && context.mounted) {
                    Navigator.of(context).maybePop();
                  }
                }
              : null,
        ),
      ],
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
          SkeletonBox(height: 24),
          SizedBox(height: AppSpacing.md),
          SkeletonBox(height: 16),
          SizedBox(height: AppSpacing.lg),
          SkeletonBox(height: 72, radius: AppRadii.card),
          SizedBox(height: AppSpacing.md),
          SkeletonBox(height: 72, radius: AppRadii.card),
          SizedBox(height: AppSpacing.md),
          SkeletonBox(height: 72, radius: AppRadii.card),
        ],
      ),
    ),
  );
}
