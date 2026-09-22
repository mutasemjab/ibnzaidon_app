import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ibnzaidon/app/router/app_routes.dart';
import 'package:ibnzaidon/core/utils/context_extensions.dart';
import 'package:ibnzaidon/design_system/components/app_card.dart';
import 'package:ibnzaidon/design_system/components/app_tabs.dart';
import 'package:ibnzaidon/design_system/components/layout_helpers.dart';
import 'package:ibnzaidon/design_system/tokens/app_tokens.dart';
import 'package:ibnzaidon/features/settings/presentation/bloc/settings_cubit.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ContentConstraint(
        child: ListView(
          padding: const EdgeInsetsDirectional.all(AppSpacing.gutter),
          children: const [
            _LanguageCard(),
            SizedBox(height: AppSpacing.lg),
            _ThemeCard(),
            SizedBox(height: AppSpacing.lg),
            _AboutCard(),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.md),
    child: Text(text, style: context.text.titleMedium),
  );
}

class _LanguageCard extends StatelessWidget {
  const _LanguageCard();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final code = context.select<SettingsCubit, String>(
      (cubit) => cubit.state.locale.languageCode,
    );
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(l10n.settingsLanguage),
          AppSegmentedControl<String>(
            segments: {
              'ar': l10n.settingsLanguageArabic,
              'en': l10n.settingsLanguageEnglish,
            },
            selected: code,
            onChanged: context.read<SettingsCubit>().setLanguage,
          ),
        ],
      ),
    );
  }
}

class _ThemeCard extends StatelessWidget {
  const _ThemeCard();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final mode = context.select<SettingsCubit, ThemeMode>(
      (cubit) => cubit.state.themeMode,
    );
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(l10n.settingsTheme),
          AppSegmentedControl<ThemeMode>(
            segments: {
              ThemeMode.system: l10n.settingsThemeSystem,
              ThemeMode.light: l10n.settingsThemeLight,
              ThemeMode.dark: l10n.settingsThemeDark,
            },
            selected: mode,
            onChanged: context.read<SettingsCubit>().setThemeMode,
          ),
        ],
      ),
    );
  }
}

class _AboutCard extends StatelessWidget {
  const _AboutCard();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppCard(
      onTap: null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(l10n.settingsAbout),
          Text(l10n.appName, style: context.text.titleSmall),
          const SizedBox(height: AppSpacing.xs),
          GestureDetector(
            // Hidden entry to the design gallery (debug builds only).
            onLongPress: kDebugMode
                ? () => context.push(AppRoutes.designGallery)
                : null,
            child: FutureBuilder<PackageInfo>(
              future: PackageInfo.fromPlatform(),
              builder: (context, snapshot) {
                final info = snapshot.data;
                final label = info == null
                    ? ''
                    : l10n.settingsVersion(
                        '${info.version}+${info.buildNumber}',
                      );
                return Text(
                  label,
                  style: context.text.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
