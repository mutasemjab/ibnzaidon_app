import 'package:flutter/material.dart';
import 'package:ibnzaidon/core/utils/context_extensions.dart';
import 'package:ibnzaidon/design_system/tokens/app_colors.dart';
import 'package:ibnzaidon/design_system/tokens/app_palette.dart';
import 'package:ibnzaidon/design_system/tokens/app_tokens.dart';

/// Shared frame for login/register: gradient hero, rounded form sheet,
/// keyboard-aware scrolling.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    required this.title,
    required this.subtitle,
    required this.child,
    this.banner,
    super.key,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final Widget? banner;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    // Scaffold shrinks the body when the keyboard opens (default), so the
    // card only needs to clear the bottom safe area (home indicator / nav
    // bar) once the keyboard is gone.
    final bottomSafeArea = MediaQuery.paddingOf(context).bottom;
    return Scaffold(
      backgroundColor: scheme.primary,
      body: DecoratedBox(
        decoration: BoxDecoration(gradient: context.palette.heroGradient),
        // The hero sits at its natural height and the card fills every
        // remaining pixel down to the screen edge, so there is never a
        // strip of bare gradient showing below a short form (login) — the
        // card grows/scrolls instead of floating over empty space.
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _Hero(title: title, subtitle: subtitle),
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: SizedBox.expand(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: scheme.surface,
                          borderRadius: AppRadii.sheetRadius,
                        ),
                        child: SingleChildScrollView(
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          padding: EdgeInsetsDirectional.fromSTEB(
                            AppSpacing.xxl,
                            AppSpacing.xxxl,
                            AppSpacing.xxl,
                            AppSpacing.xxl + bottomSafeArea,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (banner != null) ...[
                                banner!,
                                const SizedBox(height: AppSpacing.lg),
                              ],
                              child,
                            ],
                          ),
                        ),
                      ),
                    ),
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

class _Hero extends StatelessWidget {
  const _Hero({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        AppSpacing.xxl,
        AppSpacing.giant,
        AppSpacing.xxl,
        AppSpacing.xxxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: AppSizes.avatarLg,
            height: AppSizes.avatarLg,
            decoration: BoxDecoration(
              color: AppColors.onHero.withValues(alpha: 0.16),
              borderRadius: AppRadii.cardRadius,
            ),
            child: const Icon(
              Icons.school_rounded,
              size: AppSizes.iconXl,
              color: AppColors.onHero,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Semantics(
            header: true,
            child: Text(
              title,
              style: context.text.headlineMedium?.copyWith(
                color: AppColors.onHero,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            subtitle,
            style: context.text.bodyLarge?.copyWith(
              color: AppColors.onHero.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}

/// Inline notice (session expired, server error) shown above the form.
class AuthNotice extends StatelessWidget {
  const AuthNotice({required this.message, this.isError = false, super.key});

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    final palette = context.palette;
    final background = isError
        ? scheme.errorContainer
        : palette.warningContainer;
    final foreground = isError
        ? scheme.onErrorContainer
        : palette.onWarningContainer;
    return Semantics(
      liveRegion: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: background,
          borderRadius: AppRadii.fieldRadius,
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.all(AppSpacing.md),
          child: Row(
            children: [
              Icon(
                isError
                    ? Icons.error_outline_rounded
                    : Icons.info_outline_rounded,
                color: foreground,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  message,
                  style: context.text.bodyMedium?.copyWith(color: foreground),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
