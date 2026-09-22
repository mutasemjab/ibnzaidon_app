import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ibnzaidon/app/router/app_routes.dart';
import 'package:ibnzaidon/core/bloc/resource_bloc.dart';
import 'package:ibnzaidon/core/bloc/submission_status.dart';
import 'package:ibnzaidon/core/di/injector.dart';
import 'package:ibnzaidon/core/utils/context_extensions.dart';
import 'package:ibnzaidon/core/utils/formatters.dart';
import 'package:ibnzaidon/design_system/components/app_button.dart';
import 'package:ibnzaidon/design_system/components/app_card.dart';
import 'package:ibnzaidon/design_system/components/app_network_image.dart';
import 'package:ibnzaidon/design_system/components/layout_helpers.dart';
import 'package:ibnzaidon/design_system/components/overlays.dart';
import 'package:ibnzaidon/design_system/tokens/app_colors.dart';
import 'package:ibnzaidon/design_system/tokens/app_palette.dart';
import 'package:ibnzaidon/design_system/tokens/app_tokens.dart';
import 'package:ibnzaidon/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ibnzaidon/features/profile/domain/entities/profile.dart';
import 'package:ibnzaidon/features/profile/presentation/bloc/profile_blocs.dart';
import 'package:ibnzaidon/shared/presentation/auth_gate.dart';

/// Profile tab: header, stats, shortcuts, logout and account deletion.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileTitle)),
      body: AuthGate(
        message: l10n.profileGate,
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) =>
                  getIt<ProfileBloc>()..add(const ResourceRequested()),
            ),
            BlocProvider(create: (_) => getIt<AccountBloc>()),
          ],
          child: const _ProfileView(),
        ),
      ),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return MultiBlocListener(
      listeners: [
        BlocListener<AccountBloc, AccountState>(
          listenWhen: (a, b) =>
              a.completed != b.completed && b.completed != AccountAction.none,
          listener: (context, state) {
            context.read<AuthBloc>().add(const AuthSessionEnded());
            context.go(AppRoutes.login);
          },
        ),
        BlocListener<AccountBloc, AccountState>(
          listenWhen: (a, b) =>
              a.status != b.status && b.status == SubmissionStatus.failure,
          listener: (context, state) => AppSnackbar.show(
            context,
            l10n.profileDeleteFailed,
            type: AppSnackbarType.error,
          ),
        ),
      ],
      child: BlocBuilder<ProfileBloc, ResourceState<Profile>>(
        builder: (context, state) {
          final student =
              state.data?.student ?? context.watch<AuthBloc>().state.student;
          return ContentConstraint(
            child: AppRefreshIndicator(
              onRefresh: () async =>
                  context.read<ProfileBloc>().add(const ResourceRefreshed()),
              child: ListView(
                padding: const EdgeInsetsDirectional.all(AppSpacing.gutter),
                children: [
                  if (student != null)
                    _Header(
                      name: student.name,
                      phone: student.phone,
                      avatar: student.avatar,
                      className: student.className,
                    ),
                  if (state.data != null && state.data!.stats.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.lg),
                    _StatsGrid(stats: state.data!.stats),
                  ],
                  const SizedBox(height: AppSpacing.xl),
                  const _Menu(),
                  const SizedBox(height: AppSpacing.xl),
                  const _DangerZone(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.name,
    required this.phone,
    this.avatar,
    this.className,
  });

  final String name;
  final String phone;
  final String? avatar;
  final String? className;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: context.palette.heroGradient,
        borderRadius: AppRadii.cardRadius,
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.all(AppSpacing.xl),
        child: Row(
          children: [
            AppNetworkImage(
              url: avatar,
              width: AppSizes.avatarLg,
              height: AppSizes.avatarLg,
              circle: true,
              placeholderIcon: Icons.person_rounded,
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: context.text.titleLarge?.copyWith(
                      color: AppColors.onHero,
                    ),
                  ),
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                      phone,
                      style: context.text.bodyMedium?.copyWith(
                        color: AppColors.onHero.withValues(alpha: 0.85),
                      ),
                    ),
                  ),
                  if (className != null)
                    Text(
                      className!,
                      style: context.text.labelMedium?.copyWith(
                        color: AppColors.onHero.withValues(alpha: 0.85),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.stats});

  final List<ProfileStat> stats;

  String _label(BuildContext context, String key) {
    final l10n = context.l10n;
    final normalized = key.toLowerCase();
    if (normalized.contains('complet')) return l10n.profileStatCompleted;
    if (normalized.contains('exam')) return l10n.profileStatExams;
    if (normalized.contains('lesson')) return l10n.profileStatLessons;
    if (normalized.contains('hour')) return l10n.profileStatHours;
    if (normalized.contains('pass')) return l10n.profileStatPassed;
    if (normalized.contains('course') || normalized.contains('enroll')) {
      return l10n.profileStatCourses;
    }
    return key.replaceAll('_', ' ');
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: [
        for (final stat in stats)
          SizedBox(
            width:
                (context.screenWidth.clamp(0, AppSizes.maxContentWidth) -
                    AppSpacing.gutter * 2 -
                    AppSpacing.md * 2) /
                3,
            child: AppCard(
              padding: const EdgeInsetsDirectional.all(AppSpacing.md),
              child: Column(
                children: [
                  Text(
                    AppFormatters.number(stat.value),
                    style: context.text.titleLarge?.copyWith(
                      color: context.colors.primary,
                    ),
                  ),
                  Text(
                    _label(context, stat.key),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.labelMedium,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _Menu extends StatelessWidget {
  const _Menu();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    Widget tile(IconData icon, String label, String route) => ListTile(
      leading: Icon(icon, color: context.colors.primary),
      title: Text(label),
      trailing: const Icon(
        Icons.arrow_forward_ios_rounded,
        size: AppSizes.iconSm,
      ),
      onTap: () => context.push(route),
    );
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          tile(Icons.edit_rounded, l10n.profileEdit, AppRoutes.editProfile),
          tile(
            Icons.lock_reset_rounded,
            l10n.profileChangePassword,
            AppRoutes.changePassword,
          ),
          tile(
            Icons.history_edu_rounded,
            l10n.profileMyExams,
            AppRoutes.myExams,
          ),
          tile(Icons.quiz_rounded, l10n.profileExamsCenter, AppRoutes.exams),
          tile(Icons.groups_rounded, l10n.profileTeachers, AppRoutes.teachers),
          tile(
            Icons.settings_rounded,
            l10n.profileSettings,
            AppRoutes.settings,
          ),
        ],
      ),
    );
  }
}

class _DangerZone extends StatelessWidget {
  const _DangerZone();

  Future<void> _logout(BuildContext context) async {
    final l10n = context.l10n;
    final bloc = context.read<AccountBloc>();
    final confirmed = await showConfirmDialog(
      context,
      title: l10n.profileLogoutConfirmTitle,
      message: l10n.profileLogoutConfirmBody,
      confirmLabel: l10n.profileLogout,
      icon: Icons.logout_rounded,
    );
    if (confirmed) bloc.add(const LogoutRequested());
  }

  /// Two-step destructive confirmation (required by the App Store).
  Future<void> _delete(BuildContext context) async {
    final l10n = context.l10n;
    final bloc = context.read<AccountBloc>();
    final first = await showConfirmDialog(
      context,
      title: l10n.profileDeleteStep1Title,
      message: l10n.profileDeleteStep1Body,
      confirmLabel: l10n.commonContinue,
      destructive: true,
      icon: Icons.warning_amber_rounded,
    );
    if (!first || !context.mounted) return;
    final second = await showConfirmDialog(
      context,
      title: l10n.profileDeleteStep2Title,
      message: l10n.profileDeleteStep2Body,
      confirmLabel: l10n.profileDeleteConfirm,
      destructive: true,
      icon: Icons.delete_forever_rounded,
    );
    if (second) bloc.add(const DeleteAccountRequested());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocBuilder<AccountBloc, AccountState>(
      builder: (context, state) => Column(
        children: [
          AppButton(
            label: l10n.profileLogout,
            icon: Icons.logout_rounded,
            variant: AppButtonVariant.secondary,
            isLoading: state.status == SubmissionStatus.submitting,
            onPressed: () => _logout(context),
          ),
          const SizedBox(height: AppSpacing.sm),
          AppButton(
            label: l10n.profileDeleteAccount,
            icon: Icons.delete_outline_rounded,
            variant: AppButtonVariant.destructive,
            onPressed: state.status == SubmissionStatus.submitting
                ? null
                : () => _delete(context),
          ),
        ],
      ),
    );
  }
}
