import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ibnzaidon/core/bloc/submission_status.dart';
import 'package:ibnzaidon/core/di/injector.dart';
import 'package:ibnzaidon/core/error/failure.dart';
import 'package:ibnzaidon/core/utils/context_extensions.dart';
import 'package:ibnzaidon/core/utils/validators.dart';
import 'package:ibnzaidon/design_system/components/app_button.dart';
import 'package:ibnzaidon/design_system/components/app_text_field.dart';
import 'package:ibnzaidon/design_system/components/layout_helpers.dart';
import 'package:ibnzaidon/design_system/components/overlays.dart';
import 'package:ibnzaidon/design_system/tokens/app_tokens.dart';
import 'package:ibnzaidon/features/profile/domain/usecases/profile_usecases.dart';
import 'package:ibnzaidon/features/profile/presentation/bloc/profile_blocs.dart';
import 'package:ibnzaidon/shared/presentation/auth_gate.dart';
import 'package:ibnzaidon/shared/presentation/failure_view.dart';

class ChangePasswordPage extends StatelessWidget {
  const ChangePasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.passwordChangeTitle)),
      body: AuthGate(
        builder: (_) => BlocProvider(
          create: (_) => getIt<PasswordChangeBloc>(),
          child: const _PasswordForm(),
        ),
      ),
    );
  }
}

class _PasswordForm extends StatefulWidget {
  const _PasswordForm();

  @override
  State<_PasswordForm> createState() => _PasswordFormState();
}

class _PasswordFormState extends State<_PasswordForm> {
  final _formKey = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _new = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void dispose() {
    _current.dispose();
    _new.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<PasswordChangeBloc>().add(
      PasswordChangeRequested(
        ChangePasswordParams(
          currentPassword: _current.text,
          newPassword: _new.text,
          confirmation: _confirm.text,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocConsumer<PasswordChangeBloc, PasswordChangeState>(
      listenWhen: (a, b) => a.status != b.status,
      listener: (context, state) {
        if (state.status == SubmissionStatus.success) {
          AppSnackbar.show(
            context,
            l10n.passwordChangeSaved,
            type: AppSnackbarType.success,
          );
          context.pop();
        } else if (state.status == SubmissionStatus.failure &&
            state.failure is! ValidationFailure) {
          context.showFailure(state.failure!);
        }
      },
      builder: (context, state) {
        final validation = state.failure is ValidationFailure
            ? state.failure! as ValidationFailure
            : null;
        return ContentConstraint(
          maxWidth: 560,
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsetsDirectional.all(AppSpacing.gutter),
              children: [
                AppTextField(
                  controller: _current,
                  label: l10n.authFieldCurrentPassword,
                  prefixIcon: Icons.lock_outline_rounded,
                  isPassword: true,
                  textInputAction: TextInputAction.next,
                  errorText: validation?.firstErrorFor('current_password'),
                  validator: Validators.required(l10n),
                ),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  controller: _new,
                  label: l10n.authFieldNewPassword,
                  prefixIcon: Icons.lock_reset_rounded,
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
                  validator: Validators.confirmPassword(l10n, () => _new.text),
                ),
                const SizedBox(height: AppSpacing.xxl),
                AppButton(
                  label: l10n.passwordChangeAction,
                  isLoading: state.status == SubmissionStatus.submitting,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
