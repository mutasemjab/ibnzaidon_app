import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ibnzaidon/app/router/app_routes.dart';
import 'package:ibnzaidon/core/bloc/submission_status.dart';
import 'package:ibnzaidon/core/di/injector.dart';
import 'package:ibnzaidon/core/error/failure.dart';
import 'package:ibnzaidon/core/l10n/failure_message.dart';
import 'package:ibnzaidon/core/l10n/generated/app_localizations.dart';
import 'package:ibnzaidon/core/utils/context_extensions.dart';
import 'package:ibnzaidon/core/utils/validators.dart';
import 'package:ibnzaidon/design_system/components/app_button.dart';
import 'package:ibnzaidon/design_system/components/app_text_field.dart';
import 'package:ibnzaidon/design_system/tokens/app_tokens.dart';
import 'package:ibnzaidon/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ibnzaidon/features/auth/presentation/bloc/login_bloc.dart';
import 'package:ibnzaidon/features/auth/presentation/widgets/auth_scaffold.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({this.returnTo, super.key});

  /// Where to go after signing in (from the auth redirect guard).
  final String? returnTo;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<LoginBloc>(),
      child: _LoginView(returnTo: returnTo),
    );
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView({this.returnTo});

  final String? returnTo;

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _phone = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<LoginBloc>().add(
      LoginSubmitted(
        phone: Validators.normalizePhone(_phone.text),
        password: _password.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final sessionExpired = context.select<AuthBloc, bool>(
      (bloc) => bloc.state.sessionExpired,
    );
    return BlocListener<LoginBloc, LoginState>(
      listenWhen: (previous, current) =>
          previous.status != current.status ||
          previous.guestChosen != current.guestChosen,
      listener: (context, state) {
        if (state.guestChosen) context.go(AppRoutes.home);
        if (state.status == SubmissionStatus.success) {
          context.read<AuthBloc>().add(AuthSessionStarted(state.student!));
          context.go(widget.returnTo ?? AppRoutes.home);
        }
      },
      child: AuthScaffold(
        title: l10n.authLoginTitle,
        subtitle: l10n.authLoginSubtitle,
        banner: sessionExpired
            ? AuthNotice(message: l10n.errorSessionExpired)
            : null,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              BlocBuilder<LoginBloc, LoginState>(
                buildWhen: (previous, current) =>
                    previous.failure != current.failure,
                builder: (context, state) => _FailureNotice(
                  failure: state.failure,
                  l10n: l10n,
                ),
              ),
              AppTextField(
                controller: _phone,
                label: l10n.authFieldPhone,
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.telephoneNumber],
                forceLtr: true,
                validator: Validators.phone(l10n),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                controller: _password,
                label: l10n.authFieldPassword,
                prefixIcon: Icons.lock_outline_rounded,
                isPassword: true,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
                onSubmitted: (_) => _submit(),
                validator: Validators.required(l10n),
              ),
              const SizedBox(height: AppSpacing.xxl),
              BlocBuilder<LoginBloc, LoginState>(
                buildWhen: (previous, current) =>
                    previous.status != current.status,
                builder: (context, state) => AppButton(
                  label: l10n.authLoginAction,
                  isLoading: state.status == SubmissionStatus.submitting,
                  onPressed: _submit,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              AppButton(
                label: l10n.authContinueAsGuest,
                variant: AppButtonVariant.text,
                onPressed: () =>
                    context.read<LoginBloc>().add(const LoginGuestChosen()),
              ),
              const SizedBox(height: AppSpacing.lg),
              _SwitchPrompt(
                prompt: l10n.authNoAccount,
                action: l10n.authRegisterAction,
                onTap: () => context.pushReplacement(AppRoutes.register),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FailureNotice extends StatelessWidget {
  const _FailureNotice({required this.failure, required this.l10n});

  final Failure? failure;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final current = failure;
    if (current == null) return const SizedBox.shrink();
    final message = switch (current) {
      UnauthorizedFailure() => l10n.authInvalidCredentials,
      ForbiddenFailure() => l10n.authAccountSuspended,
      _ => current.localized(l10n),
    };
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.lg),
      child: AuthNotice(message: message, isError: true),
    );
  }
}

class _SwitchPrompt extends StatelessWidget {
  const _SwitchPrompt({
    required this.prompt,
    required this.action,
    required this.onTap,
  });

  final String prompt;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(prompt, style: context.text.bodyMedium),
        TextButton(onPressed: onTap, child: Text(action)),
      ],
    );
  }
}
