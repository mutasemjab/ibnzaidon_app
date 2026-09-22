import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ibnzaidon/app/router/app_routes.dart';
import 'package:ibnzaidon/core/bloc/submission_status.dart';
import 'package:ibnzaidon/core/di/injector.dart';
import 'package:ibnzaidon/core/error/failure.dart';
import 'package:ibnzaidon/core/l10n/failure_message.dart';
import 'package:ibnzaidon/core/utils/context_extensions.dart';
import 'package:ibnzaidon/core/utils/validators.dart';
import 'package:ibnzaidon/design_system/components/app_button.dart';
import 'package:ibnzaidon/design_system/components/app_text_field.dart';
import 'package:ibnzaidon/design_system/tokens/app_tokens.dart';
import 'package:ibnzaidon/features/auth/domain/usecases/auth_usecases.dart';
import 'package:ibnzaidon/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ibnzaidon/features/auth/presentation/bloc/register_bloc.dart';
import 'package:ibnzaidon/features/auth/presentation/widgets/auth_scaffold.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({this.returnTo, super.key});

  final String? returnTo;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<RegisterBloc>(),
    child: _RegisterView(returnTo: returnTo),
  );
}

class _RegisterView extends StatefulWidget {
  const _RegisterView({this.returnTo});

  final String? returnTo;

  @override
  State<_RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<_RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void dispose() {
    for (final controller in [_name, _phone, _email, _password, _confirm]) {
      controller.dispose();
    }
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<RegisterBloc>().add(
      RegisterSubmitted(
        RegisterParams(
          name: _name.text.trim(),
          phone: Validators.normalizePhone(_phone.text),
          email: _email.text.trim(),
          password: _password.text,
          passwordConfirmation: _confirm.text,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocListener<RegisterBloc, RegisterState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == SubmissionStatus.success) {
          context.read<AuthBloc>().add(AuthSessionStarted(state.student!));
          context.go(widget.returnTo ?? AppRoutes.home);
        }
      },
      child: AuthScaffold(
        title: l10n.authRegisterTitle,
        subtitle: l10n.authRegisterSubtitle,
        child: BlocBuilder<RegisterBloc, RegisterState>(
          builder: (context, state) {
            final failure = state.failure;
            final validation = failure is ValidationFailure ? failure : null;
            return Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (failure != null && validation == null) ...[
                    AuthNotice(message: failure.localized(l10n), isError: true),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                  AppTextField(
                    controller: _name,
                    label: l10n.authFieldName,
                    prefixIcon: Icons.person_outline_rounded,
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.words,
                    autofillHints: const [AutofillHints.name],
                    errorText: validation?.firstErrorFor('name'),
                    validator: Validators.required(l10n),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppTextField(
                    controller: _phone,
                    label: l10n.authFieldPhone,
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    forceLtr: true,
                    errorText: validation?.firstErrorFor('phone'),
                    validator: Validators.phone(l10n),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppTextField(
                    controller: _email,
                    label: l10n.authFieldEmail,
                    prefixIcon: Icons.mail_outline_rounded,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    forceLtr: true,
                    errorText: validation?.firstErrorFor('email'),
                    validator: Validators.optionalEmail(l10n),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppTextField(
                    controller: _password,
                    label: l10n.authFieldPassword,
                    prefixIcon: Icons.lock_outline_rounded,
                    isPassword: true,
                    textInputAction: TextInputAction.next,
                    errorText: validation?.firstErrorFor('password'),
                    validator: Validators.password(l10n),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppTextField(
                    controller: _confirm,
                    label: l10n.authFieldPasswordConfirm,
                    prefixIcon: Icons.lock_reset_rounded,
                    isPassword: true,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _submit(),
                    validator: Validators.confirmPassword(
                      l10n,
                      () => _password.text,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  AppButton(
                    label: l10n.authRegisterAction,
                    isLoading: state.status == SubmissionStatus.submitting,
                    onPressed: _submit,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        l10n.authHaveAccount,
                        style: context.text.bodyMedium,
                      ),
                      TextButton(
                        onPressed: () =>
                            context.pushReplacement(AppRoutes.login),
                        child: Text(l10n.authLoginAction),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
