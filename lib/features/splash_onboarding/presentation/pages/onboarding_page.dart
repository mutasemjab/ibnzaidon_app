import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ibnzaidon/app/router/app_routes.dart';
import 'package:ibnzaidon/core/di/injector.dart';
import 'package:ibnzaidon/core/utils/context_extensions.dart';
import 'package:ibnzaidon/design_system/components/app_button.dart';
import 'package:ibnzaidon/design_system/components/layout_helpers.dart';
import 'package:ibnzaidon/design_system/components/state_views.dart';
import 'package:ibnzaidon/design_system/tokens/app_tokens.dart';
import 'package:ibnzaidon/features/splash_onboarding/presentation/bloc/onboarding_cubit.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<OnboardingCubit>(),
    child: BlocListener<OnboardingCubit, bool>(
      listenWhen: (previous, current) => current,
      listener: (context, _) => context.go(AppRoutes.login),
      child: const _OnboardingView(),
    ),
  );
}

class _OnboardingView extends StatefulWidget {
  const _OnboardingView();

  @override
  State<_OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<_OnboardingView> {
  static const _slideCount = 3;
  final _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _finish() => context.read<OnboardingCubit>().complete();

  void _next() {
    if (_index == _slideCount - 1) {
      _finish();
    } else {
      _controller.nextPage(
        duration: AppMotion.medium,
        curve: AppMotion.emphasizedDecelerate,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final slides = [
      (Icons.play_circle_rounded, l10n.onboardingTitle1, l10n.onboardingBody1),
      (Icons.insights_rounded, l10n.onboardingTitle2, l10n.onboardingBody2),
      (Icons.folder_copy_rounded, l10n.onboardingTitle3, l10n.onboardingBody3),
    ];
    final isLast = _index == _slideCount - 1;
    return Scaffold(
      body: SafeArea(
        child: ContentConstraint(
          maxWidth: 520,
          child: Column(
            children: [
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: Padding(
                  padding: const EdgeInsetsDirectional.all(AppSpacing.sm),
                  child: AnimatedOpacity(
                    opacity: isLast ? 0 : 1,
                    duration: AppMotion.fast,
                    child: TextButton(
                      onPressed: isLast ? null : _finish,
                      child: Text(l10n.commonSkip),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _slideCount,
                  onPageChanged: (value) => setState(() => _index = value),
                  itemBuilder: (context, i) => _Slide(
                    icon: slides[i].$1,
                    title: slides[i].$2,
                    body: slides[i].$3,
                  ),
                ),
              ),
              SmoothPageIndicator(
                controller: _controller,
                count: _slideCount,
                effect: ExpandingDotsEffect(
                  activeDotColor: context.colors.primary,
                  dotColor: context.colors.outlineVariant,
                  dotHeight: AppSpacing.sm,
                  dotWidth: AppSpacing.sm,
                  expansionFactor: 3.5,
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.all(AppSpacing.xxl),
                child: AppButton(
                  label: isLast ? l10n.onboardingGetStarted : l10n.commonNext,
                  onPressed: _next,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Slide extends StatelessWidget {
  const _Slide({required this.icon, required this.title, required this.body});

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: AppSpacing.xxl,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IllustrationBadge(icon: icon),
          const SizedBox(height: AppSpacing.xxxl),
          Text(
            title,
            textAlign: TextAlign.center,
            style: context.text.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            body,
            textAlign: TextAlign.center,
            style: context.text.bodyLarge?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
