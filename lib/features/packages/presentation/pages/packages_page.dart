import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ibnzaidon/core/bloc/resource_bloc.dart';
import 'package:ibnzaidon/core/di/injector.dart';
import 'package:ibnzaidon/core/utils/context_extensions.dart';
import 'package:ibnzaidon/design_system/components/layout_helpers.dart';
import 'package:ibnzaidon/design_system/components/skeleton.dart';
import 'package:ibnzaidon/design_system/components/state_views.dart';
import 'package:ibnzaidon/design_system/tokens/app_tokens.dart';
import 'package:ibnzaidon/features/packages/domain/entities/package.dart';
import 'package:ibnzaidon/features/packages/presentation/bloc/packages_bloc.dart';
import 'package:ibnzaidon/features/packages/presentation/widgets/package_card_view.dart';
import 'package:ibnzaidon/shared/presentation/failure_view.dart';

class PackagesPage extends StatelessWidget {
  const PackagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.packagesTitle)),
      body: BlocProvider(
        create: (_) => getIt<PackagesBloc>()..add(const ResourceRequested()),
        child: const _PackagesView(),
      ),
    );
  }
}

class _PackagesView extends StatelessWidget {
  const _PackagesView();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocBuilder<PackagesBloc, ResourceState<List<Package>>>(
      builder: (context, state) {
        if (state.isLoading && state.data == null) return const _Skeleton();
        final packages = state.data;
        if (packages == null) {
          return FailureView(
            failure: state.failure!,
            onRetry: () =>
                context.read<PackagesBloc>().add(const ResourceRequested()),
          );
        }
        if (packages.isEmpty) {
          return EmptyState(
            icon: Icons.inventory_2_outlined,
            title: l10n.packagesEmptyTitle,
          );
        }
        return ContentConstraint(
          child: GridView.builder(
            padding: AppSpacing.pagePadding,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: context.gridColumns,
              mainAxisSpacing: AppSpacing.md,
              crossAxisSpacing: AppSpacing.md,
              childAspectRatio: 0.78,
            ),
            itemCount: packages.length,
            itemBuilder: (context, index) => PackageCardView(
              package: packages[index],
              enableHero: true,
            ),
          ),
        );
      },
    );
  }
}

class _Skeleton extends StatelessWidget {
  const _Skeleton();

  @override
  Widget build(BuildContext context) => SkeletonShimmer(
    child: GridView.builder(
      padding: AppSpacing.pagePadding,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: context.gridColumns,
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
        childAspectRatio: 0.78,
      ),
      itemCount: 6,
      itemBuilder: (_, _) => const SkeletonBox(radius: AppRadii.card),
    ),
  );
}
