import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ibnzaidon/app/router/app_routes.dart';
import 'package:ibnzaidon/core/bloc/resource_bloc.dart';
import 'package:ibnzaidon/core/di/injector.dart';
import 'package:ibnzaidon/core/l10n/failure_message.dart';
import 'package:ibnzaidon/core/utils/context_extensions.dart';
import 'package:ibnzaidon/design_system/components/app_network_image.dart';
import 'package:ibnzaidon/design_system/components/layout_helpers.dart';
import 'package:ibnzaidon/design_system/components/skeleton.dart';
import 'package:ibnzaidon/design_system/tokens/app_tokens.dart';
import 'package:ibnzaidon/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ibnzaidon/features/catalog/domain/entities/catalog_entities.dart';
import 'package:ibnzaidon/features/catalog/presentation/bloc/catalog_blocs.dart';
import 'package:ibnzaidon/features/home/domain/entities/home_data.dart';
import 'package:ibnzaidon/features/home/presentation/bloc/home_bloc.dart';
import 'package:ibnzaidon/features/home/presentation/widgets/banner_carousel.dart';
import 'package:ibnzaidon/features/home/presentation/widgets/home_sections.dart';
import 'package:ibnzaidon/features/notifications/presentation/widgets/notification_bell.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final signedIn = context.isSignedInForHome;
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => getIt<BannersBloc>()..add(const ResourceRequested()),
        ),
        BlocProvider(
          create: (_) =>
              getIt<CategoriesBloc>()..add(const ResourceRequested()),
        ),
        BlocProvider(
          create: (_) {
            final bloc = getIt<HomeBloc>();
            if (signedIn) bloc.add(const ResourceRequested());
            return bloc;
          },
        ),
      ],
      child: const _HomeView(),
    );
  }
}

extension on BuildContext {
  bool get isSignedInForHome => read<AuthBloc>().state.isAuthenticated;
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  Future<void> _refresh(BuildContext context, {required bool signedIn}) async {
    context.read<BannersBloc>().add(const ResourceRefreshed());
    context.read<CategoriesBloc>().add(const ResourceRefreshed());
    if (signedIn) {
      final home = context.read<HomeBloc>()..add(const ResourceRefreshed());
      await home.stream.firstWhere((s) => s.status != ResourceStatus.loading);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;
    final signedIn = auth.isAuthenticated;
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (a, b) => a.isAuthenticated != b.isAuthenticated,
      listener: (context, state) {
        if (state.isAuthenticated) {
          context.read<HomeBloc>().add(const ResourceRequested());
        }
      },
      child: Scaffold(
        body: AppRefreshIndicator(
          onRefresh: () => _refresh(context, signedIn: signedIn),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _Header(auth: auth)),
              SliverToBoxAdapter(
                child: ContentConstraint(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppSpacing.sm),
                      const BannerCarousel(),
                      const SizedBox(height: AppSpacing.lg),
                      const QuickActions(),
                      const SizedBox(height: AppSpacing.lg),
                      const _CategoriesSection(),
                      if (signedIn)
                        const _HomeContent()
                      else
                        const GuestPrompt(),
                      const SizedBox(height: AppSpacing.massive),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.auth});

  final AuthState auth;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final student = auth.student;
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? l10n.homeGreetingMorning
        : l10n.homeGreetingEvening;
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(
          AppSpacing.gutter,
          AppSpacing.md,
          AppSpacing.gutter,
          AppSpacing.sm,
        ),
        child: Row(
          children: [
            InkWell(
              customBorder: const CircleBorder(),
              onTap: () => context.go(AppRoutes.profile),
              child: AppNetworkImage(
                url: student?.avatar,
                width: AppSizes.avatarMd + AppSpacing.xs,
                height: AppSizes.avatarMd + AppSpacing.xs,
                circle: true,
                placeholderIcon: Icons.person_rounded,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student == null
                        ? l10n.authWelcomeGuest
                        : l10n.homeGreetingWithName(
                            greeting,
                            student.name.split(' ').first,
                          ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.titleMedium,
                  ),
                  Text(
                    l10n.homeGreetingSubtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (auth.isAuthenticated) const NotificationBell(),
          ],
        ),
      ),
    );
  }
}

class _CategoriesSection extends StatelessWidget {
  const _CategoriesSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoriesBloc, ResourceState<List<Category>>>(
      builder: (context, state) {
        if (state.isLoading) {
          return const SkeletonShimmer(
            child: Padding(
              padding: AppSpacing.pagePadding,
              child: SkeletonBox(height: 112, radius: AppRadii.card),
            ),
          );
        }
        return CategoriesStrip(categories: state.data ?? const []);
      },
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocBuilder<HomeBloc, ResourceState<HomeData>>(
      builder: (context, state) {
        if (state.isLoading && state.data == null) {
          return const Column(
            children: [
              SizedBox(height: AppSpacing.lg),
              CarouselSkeleton(),
            ],
          );
        }
        final data = state.data;
        if (data == null) {
          return Padding(
            padding: const EdgeInsetsDirectional.only(top: AppSpacing.lg),
            child: SectionError(
              message: state.failure?.localized(l10n) ?? l10n.homeSectionFailed,
              onRetry: () =>
                  context.read<HomeBloc>().add(const ResourceRequested()),
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.lg),
            CourseCarousel(
              title: l10n.homeFeatured,
              courses: data.featuredCourses,
              onSeeAll: () => context.push('${AppRoutes.courses}?featured=1'),
            ),
            const SizedBox(height: AppSpacing.lg),
            CourseCarousel(
              title: l10n.homeTrending,
              courses: data.trendingCourses,
              onSeeAll: () => context.push('${AppRoutes.courses}?trending=1'),
            ),
            const SizedBox(height: AppSpacing.lg),
            TeachersCarousel(teachers: data.topTeachers),
            const SizedBox(height: AppSpacing.lg),
            StatsStrip(stats: data.stats),
          ],
        );
      },
    );
  }
}
