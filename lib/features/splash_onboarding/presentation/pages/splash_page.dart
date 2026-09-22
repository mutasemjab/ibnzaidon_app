import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ibnzaidon/core/di/injector.dart';
import 'package:ibnzaidon/core/utils/context_extensions.dart';
import 'package:ibnzaidon/design_system/tokens/app_colors.dart';
import 'package:ibnzaidon/design_system/tokens/app_palette.dart';
import 'package:ibnzaidon/design_system/tokens/app_tokens.dart';
import 'package:ibnzaidon/features/splash_onboarding/presentation/bloc/splash_cubit.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<SplashCubit>()..start(),
      child: BlocListener<SplashCubit, String?>(
        listenWhen: (previous, current) => current != null,
        listener: (context, destination) => context.go(destination!),
        child: const _SplashView(),
      ),
    );
  }
}

class _SplashView extends StatelessWidget {
  const _SplashView();

  @override
  Widget build(BuildContext context) {
    final logo = Container(
      width: AppSizes.logo,
      height: AppSizes.logo,
      decoration: BoxDecoration(
        color: AppColors.onHero.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(AppRadii.sheet),
      ),
      child: const Icon(
        Icons.school_rounded,
        size: AppSizes.iconXl + AppSpacing.md,
        color: AppColors.onHero,
      ),
    );
    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(gradient: context.palette.heroGradient),
        child: SizedBox.expand(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (context.reduceMotion)
                logo
              else
                logo
                    .animate()
                    .scale(
                      begin: const Offset(0.6, 0.6),
                      duration: AppMotion.slow,
                      curve: Curves.easeOutBack,
                    )
                    .fadeIn(duration: AppMotion.medium),
              const SizedBox(height: AppSpacing.xxl),
              Text(
                context.l10n.appName,
                style: context.text.headlineMedium?.copyWith(
                  color: AppColors.onHero,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                context.l10n.appTagline,
                style: context.text.bodyMedium?.copyWith(
                  color: AppColors.onHero.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
