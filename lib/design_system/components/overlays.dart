import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:ibnzaidon/core/utils/context_extensions.dart';
import 'package:ibnzaidon/design_system/components/app_button.dart';
import 'package:ibnzaidon/design_system/tokens/app_palette.dart';
import 'package:ibnzaidon/design_system/tokens/app_tokens.dart';

/// Frosted, rounded bottom sheet with a drag handle.
Future<T?> showAppBottomSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  String? title,
  bool isScrollControlled = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    elevation: 0,
    builder: (sheetContext) => _SheetFrame(
      title: title,
      child: builder(sheetContext),
    ),
  );
}

class _SheetFrame extends StatelessWidget {
  const _SheetFrame({required this.child, this.title});

  final Widget child;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    return ClipRRect(
      borderRadius: AppRadii.sheetRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: scheme.surface.withValues(alpha: 0.94),
            borderRadius: AppRadii.sheetRadius,
          ),
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: AppSpacing.md),
                Container(
                  width: AppSizes.dragHandleWidth,
                  height: AppSpacing.xs,
                  decoration: BoxDecoration(
                    color: scheme.outlineVariant,
                    borderRadius: AppRadii.pillRadius,
                  ),
                ),
                if (title != null)
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                      AppSpacing.xl,
                      AppSpacing.lg,
                      AppSpacing.xl,
                      0,
                    ),
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(title!, style: context.text.titleLarge),
                    ),
                  ),
                Flexible(child: SingleChildScrollView(child: child)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Confirmation dialog. Returns `true` when confirmed.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  String? cancelLabel,
  bool destructive = false,
  IconData? icon,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AppDialog(
      title: title,
      message: message,
      icon: icon,
      destructive: destructive,
      actions: [
        AppButton(
          label: confirmLabel,
          variant: destructive
              ? AppButtonVariant.destructive
              : AppButtonVariant.primary,
          onPressed: () => Navigator.of(dialogContext).pop(true),
        ),
        AppButton(
          label: cancelLabel ?? dialogContext.l10n.commonCancel,
          variant: AppButtonVariant.text,
          onPressed: () => Navigator.of(dialogContext).pop(false),
        ),
      ],
    ),
  );
  return result ?? false;
}

class AppDialog extends StatelessWidget {
  const AppDialog({
    required this.title,
    required this.actions,
    this.message,
    this.icon,
    this.destructive = false,
    this.content,
    super.key,
  });

  final String title;
  final String? message;
  final IconData? icon;
  final bool destructive;
  final Widget? content;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    return Dialog(
      insetPadding: const EdgeInsets.all(AppSpacing.xxl),
      child: Padding(
        padding: const EdgeInsetsDirectional.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              CircleAvatar(
                radius: AppSpacing.xxxl - AppSpacing.xs,
                backgroundColor: destructive
                    ? scheme.errorContainer
                    : scheme.primaryContainer,
                child: Icon(
                  icon,
                  color: destructive ? scheme.error : scheme.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
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
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
            if (content != null) ...[
              const SizedBox(height: AppSpacing.lg),
              content!,
            ],
            const SizedBox(height: AppSpacing.xl),
            for (final action in actions) ...[
              action,
              if (action != actions.last) const SizedBox(height: AppSpacing.sm),
            ],
          ],
        ),
      ),
    );
  }
}

enum AppSnackbarType { info, success, error }

abstract final class AppSnackbar {
  static void show(
    BuildContext context,
    String message, {
    AppSnackbarType type = AppSnackbarType.info,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final scheme = context.colors;
    final palette = context.palette;
    final (background, foreground, icon) = switch (type) {
      AppSnackbarType.info => (
        scheme.inverseSurface,
        scheme.onInverseSurface,
        Icons.info_outline_rounded,
      ),
      AppSnackbarType.success => (
        palette.success,
        palette.onSuccess,
        Icons.check_circle_outline_rounded,
      ),
      AppSnackbarType.error => (
        scheme.error,
        scheme.onError,
        Icons.error_outline_rounded,
      ),
    };
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          padding: EdgeInsets.zero,
          margin: const EdgeInsetsDirectional.all(AppSpacing.lg),
          duration: const Duration(seconds: 4),
          content: Semantics(
            liveRegion: true,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: background,
                borderRadius: AppRadii.buttonRadius,
                boxShadow: AppShadows.raised(context),
              ),
              child: Padding(
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                child: Row(
                  children: [
                    Icon(icon, color: foreground),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        message,
                        style: context.text.bodyMedium?.copyWith(
                          color: foreground,
                        ),
                      ),
                    ),
                    if (actionLabel != null && onAction != null)
                      TextButton(
                        onPressed: onAction,
                        child: Text(
                          actionLabel,
                          style: TextStyle(color: foreground),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
  }
}
