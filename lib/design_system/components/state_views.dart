import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:ibnzaidon/core/utils/context_extensions.dart';
import 'package:ibnzaidon/design_system/components/app_button.dart';
import 'package:ibnzaidon/design_system/tokens/app_palette.dart';
import 'package:ibnzaidon/design_system/tokens/app_tokens.dart';

enum IllustrationTone { neutral, danger, success, warning }

/// Layered gradient disc with an icon: the app's illustration language for
/// empty / error / offline / gate / success states.
class IllustrationBadge extends StatelessWidget {
  const IllustrationBadge({
    required this.icon,
    this.tone = IllustrationTone.neutral,
    super.key,
  });

  final IconData icon;
  final IllustrationTone tone;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    final palette = context.palette;
    final (soft, strong) = switch (tone) {
      IllustrationTone.neutral => (scheme.primaryContainer, scheme.primary),
      IllustrationTone.danger => (scheme.errorContainer, scheme.error),
      IllustrationTone.success => (
        palette.successContainer,
        palette.success,
      ),
      IllustrationTone.warning => (palette.warningContainer, palette.warning),
    };
    final badge = SizedBox.square(
      dimension: AppSizes.illustration,
      child: Stack(
        alignment: Alignment.center,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: soft.withValues(alpha: 0.5),
            ),
            child: const SizedBox.expand(),
          ),
          FractionallySizedBox(
            widthFactor: 0.72,
            heightFactor: 0.72,
            child: DecoratedBox(
              decoration: BoxDecoration(shape: BoxShape.circle, color: soft),
              child: Icon(icon, size: AppSizes.iconXl, color: strong),
            ),
          ),
        ],
      ),
    );
    if (context.reduceMotion) return ExcludeSemantics(child: badge);
    return ExcludeSemantics(
      child: badge
          .animate()
          .scale(
            begin: const Offset(0.85, 0.85),
            duration: AppMotion.slow,
            curve: AppMotion.emphasizedDecelerate,
          )
          .fadeIn(duration: AppMotion.medium),
    );
  }
}

class _StateLayout extends StatelessWidget {
  const _StateLayout({
    required this.illustration,
    required this.title,
    this.message,
    this.actions = const [],
  });

  final Widget illustration;
  final String title;
  final String? message;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsetsDirectional.all(AppSpacing.xxl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              illustration,
              const SizedBox(height: AppSpacing.xl),
              Text(
                title,
                textAlign: TextAlign.center,
                style: context.text.titleLarge,
              ),
              if (message != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: context.text.bodyMedium?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
              if (actions.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xl),
                ...actions,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    this.title,
    this.message,
    this.icon = Icons.inbox_rounded,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final String? title;
  final String? message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return _StateLayout(
      illustration: IllustrationBadge(icon: icon),
      title: title ?? context.l10n.emptyTitle,
      message: message ?? context.l10n.emptyMessage,
      actions: [
        if (actionLabel != null && onAction != null)
          AppButton(
            label: actionLabel!,
            onPressed: onAction,
            variant: AppButtonVariant.secondary,
            expanded: false,
          ),
      ],
    );
  }
}

class ErrorState extends StatelessWidget {
  const ErrorState({
    required this.message,
    this.onRetry,
    this.icon = Icons.cloud_off_rounded,
    this.title,
    super.key,
  });

  final String message;
  final VoidCallback? onRetry;
  final IconData icon;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return _StateLayout(
      illustration: IllustrationBadge(
        icon: icon,
        tone: IllustrationTone.danger,
      ),
      title: title ?? context.l10n.errorStateTitle,
      message: message,
      actions: [
        if (onRetry != null)
          AppButton(
            label: context.l10n.commonRetry,
            icon: Icons.refresh_rounded,
            onPressed: onRetry,
            expanded: false,
          ),
      ],
    );
  }
}

/// "Sign in to continue" gate shown instead of an error for guests.
class SignInGate extends StatelessWidget {
  const SignInGate({
    required this.onSignIn,
    required this.onCreateAccount,
    this.message,
    super.key,
  });

  final VoidCallback onSignIn;
  final VoidCallback onCreateAccount;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return _StateLayout(
      illustration: const IllustrationBadge(icon: Icons.lock_person_rounded),
      title: l10n.gateTitle,
      message: message ?? l10n.gateMessage,
      actions: [
        AppButton(label: l10n.gateSignIn, onPressed: onSignIn),
        const SizedBox(height: AppSpacing.sm),
        AppButton(
          label: l10n.gateCreateAccount,
          onPressed: onCreateAccount,
          variant: AppButtonVariant.text,
        ),
      ],
    );
  }
}

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({required this.visible, super.key});

  final bool visible;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    return AnimatedSize(
      duration: AppMotion.medium,
      curve: AppMotion.standard,
      alignment: AlignmentDirectional.topStart,
      child: visible
          ? Semantics(
              liveRegion: true,
              child: ColoredBox(
                color: scheme.inverseSurface,
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.sm,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.wifi_off_rounded,
                          size: AppSizes.iconMd,
                          color: scheme.onInverseSurface,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            context.l10n.offlineBanner,
                            style: context.text.labelMedium?.copyWith(
                              color: scheme.onInverseSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          : const SizedBox(width: double.infinity),
    );
  }
}
