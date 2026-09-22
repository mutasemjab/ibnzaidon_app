import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ibnzaidon/app/router/app_routes.dart';
import 'package:ibnzaidon/core/utils/context_extensions.dart';
import 'package:ibnzaidon/design_system/components/app_icon_button.dart';
import 'package:ibnzaidon/features/notifications/presentation/bloc/notifications_bloc.dart';

/// Bell with unread badge (driven by the global [NotificationsBadgeCubit]).
class NotificationBell extends StatelessWidget {
  const NotificationBell({super.key});

  @override
  Widget build(BuildContext context) {
    final count = context.select<NotificationsBadgeCubit, int>(
      (cubit) => cubit.state,
    );
    final l10n = context.l10n;
    return Semantics(
      label: count > 0
          ? l10n.notificationsBadgeLabel(count)
          : l10n.notificationsTooltip,
      excludeSemantics: true,
      child: Badge(
        isLabelVisible: count > 0,
        label: Text(count > 99 ? '99+' : '$count'),
        child: AppIconButton(
          icon: Icons.notifications_none_rounded,
          tooltip: l10n.notificationsTooltip,
          filled: true,
          onPressed: () => context.push(AppRoutes.notifications),
        ),
      ),
    );
  }
}
