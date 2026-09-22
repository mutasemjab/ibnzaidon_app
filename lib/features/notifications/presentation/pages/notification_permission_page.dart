import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ibnzaidon/core/utils/context_extensions.dart';
import 'package:ibnzaidon/design_system/components/app_button.dart';
import 'package:ibnzaidon/design_system/components/layout_helpers.dart';
import 'package:ibnzaidon/design_system/components/state_views.dart';
import 'package:ibnzaidon/design_system/tokens/app_tokens.dart';
import 'package:ibnzaidon/features/notifications/presentation/bloc/push_setup_cubit.dart';

/// Pre-permission explainer: asks with context before the OS dialog.
class NotificationPermissionPage extends StatelessWidget {
  const NotificationPermissionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<PushSetupCubit>();
    return Scaffold(
      body: SafeArea(
        child: ContentConstraint(
          maxWidth: 520,
          child: Padding(
            padding: const EdgeInsetsDirectional.all(AppSpacing.xxl),
            child: Column(
              children: [
                const Spacer(),
                const IllustrationBadge(
                  icon: Icons.notifications_active_rounded,
                ),
                const SizedBox(height: AppSpacing.xxxl),
                Text(
                  l10n.notificationPermissionTitle,
                  textAlign: TextAlign.center,
                  style: context.text.headlineSmall,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  l10n.notificationPermissionBody,
                  textAlign: TextAlign.center,
                  style: context.text.bodyLarge?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                AppButton(
                  label: l10n.notificationPermissionEnable,
                  icon: Icons.notifications_rounded,
                  onPressed: () async {
                    await cubit.enable();
                    if (context.mounted) context.pop();
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
                AppButton(
                  label: l10n.notificationPermissionLater,
                  variant: AppButtonVariant.text,
                  onPressed: () async {
                    await cubit.dismissExplainer();
                    if (context.mounted) context.pop();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
