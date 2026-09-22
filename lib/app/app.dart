import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:ibnzaidon/app/router/app_router.dart';
import 'package:ibnzaidon/app/router/app_routes.dart';
import 'package:ibnzaidon/core/config/app_config.dart';
import 'package:ibnzaidon/core/di/injector.dart';
import 'package:ibnzaidon/core/l10n/generated/app_localizations.dart';
import 'package:ibnzaidon/core/network/connectivity_cubit.dart';
import 'package:ibnzaidon/design_system/components/price_view.dart';
import 'package:ibnzaidon/design_system/components/state_views.dart';
import 'package:ibnzaidon/design_system/theme/app_theme.dart';
import 'package:ibnzaidon/features/app_settings/presentation/bloc/app_settings_cubit.dart';
import 'package:ibnzaidon/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ibnzaidon/features/courses/presentation/bloc/purchase_bloc.dart';
import 'package:ibnzaidon/features/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:ibnzaidon/features/notifications/presentation/bloc/push_setup_cubit.dart';
import 'package:ibnzaidon/features/notifications/presentation/notification_link_resolver.dart';
import 'package:ibnzaidon/features/settings/presentation/bloc/settings_cubit.dart';

class IbnZaidonApp extends StatefulWidget {
  const IbnZaidonApp({super.key});

  @override
  State<IbnZaidonApp> createState() => _IbnZaidonAppState();
}

class _IbnZaidonAppState extends State<IbnZaidonApp> {
  static const _maxTextScale = 1.3;

  late final GoRouter _router = AppRouter.create(
    authBloc: getIt<AuthBloc>(),
    flags: getIt<AppConfig>().featureFlags,
    showDesignGallery: getIt<AppConfig>().isDev,
  );

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SettingsCubit>.value(value: getIt<SettingsCubit>()),
        BlocProvider<AuthBloc>.value(value: getIt<AuthBloc>()),
        BlocProvider<PriceVisibilityCubit>.value(
          value: getIt<AppSettingsCubit>(),
        ),
        BlocProvider<ConnectivityCubit>.value(
          value: getIt<ConnectivityCubit>(),
        ),
        BlocProvider<NotificationsBadgeCubit>.value(
          value: getIt<NotificationsBadgeCubit>(),
        ),
        BlocProvider<PurchaseBloc>.value(value: getIt<PurchaseBloc>()),
        BlocProvider<PushSetupCubit>.value(value: getIt<PushSetupCubit>()),
      ],
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, settings) {
          final language = settings.locale.languageCode;
          return MaterialApp.router(
            title: getIt<AppConfig>().appName,
            debugShowCheckedModeBanner: false,
            routerConfig: _router,
            locale: settings.locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            theme: AppTheme.light(language),
            darkTheme: AppTheme.dark(language),
            themeMode: settings.themeMode,
            builder: (context, child) => _AppFrame(
              router: _router,
              maxTextScale: _maxTextScale,
              // Screen blocs refetch on language change (`LocaleChanges`).
              child: child!,
            ),
          );
        },
      ),
    );
  }
}

/// Global concerns: text-scale cap, offline banner, session expiry, push.
class _AppFrame extends StatelessWidget {
  const _AppFrame({
    required this.router,
    required this.maxTextScale,
    required this.child,
  });

  final GoRouter router;
  final double maxTextScale;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AuthBloc, AuthState>(
          listenWhen: (a, b) => !a.sessionExpired && b.sessionExpired,
          listener: (context, state) => router.go(AppRoutes.login),
        ),
        BlocListener<AuthBloc, AuthState>(
          listenWhen: (a, b) => !a.isAuthenticated && b.isAuthenticated,
          listener: (context, state) {
            context.read<NotificationsBadgeCubit>().refresh();
            context.read<PushSetupCubit>().onSignedIn();
          },
        ),
        BlocListener<AuthBloc, AuthState>(
          listenWhen: (a, b) => a.isAuthenticated && !b.isAuthenticated,
          listener: (context, state) =>
              context.read<NotificationsBadgeCubit>().clear(),
        ),
        BlocListener<PushSetupCubit, PushSetupState>(
          listenWhen: (a, b) => !a.shouldExplain && b.shouldExplain,
          listener: (context, state) =>
              router.push(AppRoutes.notificationPermission),
        ),
        BlocListener<PushSetupCubit, PushSetupState>(
          listenWhen: (a, b) => a.foregroundCount != b.foregroundCount,
          listener: (context, state) =>
              context.read<NotificationsBadgeCubit>().refresh(),
        ),
        BlocListener<PushSetupCubit, PushSetupState>(
          listenWhen: (a, b) =>
              b.openedMessage != null && a.openedMessage != b.openedMessage,
          listener: (context, state) {
            final message = state.openedMessage!;
            router.push(
              NotificationLinkResolver.resolve(message.type, message.data),
            );
            context.read<PushSetupCubit>().openedMessageHandled();
          },
        ),
      ],
      child: MediaQuery.withClampedTextScaling(
        maxScaleFactor: maxTextScale,
        child: BlocBuilder<ConnectivityCubit, bool>(
          builder: (context, offline) => Column(
            children: [
              OfflineBanner(visible: offline),
              Expanded(
                child: MediaQuery.removePadding(
                  context: context,
                  removeTop: offline,
                  child: child,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
