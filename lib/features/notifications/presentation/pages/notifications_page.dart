import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ibnzaidon/core/bloc/paged_bloc.dart';
import 'package:ibnzaidon/core/di/injector.dart';
import 'package:ibnzaidon/core/utils/context_extensions.dart';
import 'package:ibnzaidon/core/utils/formatters.dart';
import 'package:ibnzaidon/design_system/components/app_card.dart';
import 'package:ibnzaidon/design_system/components/layout_helpers.dart';
import 'package:ibnzaidon/design_system/components/skeleton.dart';
import 'package:ibnzaidon/design_system/components/state_views.dart';
import 'package:ibnzaidon/design_system/tokens/app_tokens.dart';
import 'package:ibnzaidon/features/notifications/domain/entities/app_notification.dart';
import 'package:ibnzaidon/features/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:ibnzaidon/features/notifications/presentation/notification_link_resolver.dart';
import 'package:ibnzaidon/shared/presentation/auth_gate.dart';
import 'package:ibnzaidon/shared/presentation/paged_bloc_view.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AuthGate(
      message: l10n.notificationsGate,
      builder: (_) => BlocProvider(
        create: (_) =>
            getIt<NotificationsBloc>()..add(const PagedStarted<NoQuery>()),
        child: const _NotificationsView(),
      ),
    );
  }
}

class _NotificationsView extends StatelessWidget {
  const _NotificationsView();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocListener<
      NotificationsBloc,
      PagedState<AppNotification, NoQuery>
    >(
      listenWhen: (a, b) => a.extra['unread_count'] != b.extra['unread_count'],
      listener: (context, state) => context.read<NotificationsBadgeCubit>().set(
        context.read<NotificationsBloc>().unreadCount,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.notificationsTitle),
          actions: [
            TextButton(
              onPressed: () => context.read<NotificationsBloc>().add(
                const NotificationsReadAllRequested(),
              ),
              child: Text(l10n.notificationsMarkAllRead),
            ),
          ],
        ),
        body: ContentConstraint(
          child: PagedBlocView<NotificationsBloc, AppNotification, NoQuery>(
            skeletonBuilder: (_) => const SkeletonRow(),
            emptyBuilder: (_) => EmptyState(
              icon: Icons.notifications_none_rounded,
              title: l10n.notificationsEmptyTitle,
              message: l10n.notificationsEmptyBody,
            ),
            itemBuilder: (context, notification, _) =>
                _NotificationTile(notification: notification),
          ),
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification});

  final AppNotification notification;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    final unread = !notification.isRead;
    final date = notification.createdAt;
    return AppCard(
      color: unread ? scheme.primaryContainer.withValues(alpha: 0.45) : null,
      semanticLabel: notification.title,
      padding: const EdgeInsetsDirectional.all(AppSpacing.md),
      onTap: () {
        context.read<NotificationsBloc>().add(
          NotificationReadRequested(notification.id),
        );
        context.push(
          NotificationLinkResolver.resolve(
            notification.type,
            notification.data,
          ),
        );
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            unread
                ? Icons.notifications_active_rounded
                : Icons.notifications_none_rounded,
            color: unread ? scheme.primary : scheme.outline,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  style: context.text.titleSmall?.copyWith(
                    fontWeight: unread ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
                if (notification.body.isNotEmpty)
                  Text(notification.body, style: context.text.bodyMedium),
                if (date != null)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(
                      top: AppSpacing.xs,
                    ),
                    child: Text(
                      AppFormatters.dateTime(date, context.languageCode),
                      style: context.text.labelSmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (unread)
            Container(
              width: AppSpacing.sm,
              height: AppSpacing.sm,
              margin: const EdgeInsetsDirectional.only(start: AppSpacing.sm),
              decoration: BoxDecoration(
                color: scheme.primary,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}
