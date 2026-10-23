import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ibnzaidon/core/bloc/submission_status.dart';
import 'package:ibnzaidon/core/di/injector.dart';
import 'package:ibnzaidon/core/error/failure.dart';
import 'package:ibnzaidon/core/l10n/failure_message.dart';
import 'package:ibnzaidon/core/utils/card_code_formatter.dart';
import 'package:ibnzaidon/core/utils/context_extensions.dart';
import 'package:ibnzaidon/design_system/components/app_button.dart';
import 'package:ibnzaidon/design_system/components/app_text_field.dart';
import 'package:ibnzaidon/design_system/components/overlays.dart';
import 'package:ibnzaidon/design_system/components/state_views.dart';
import 'package:ibnzaidon/design_system/tokens/app_tokens.dart';
import 'package:ibnzaidon/features/packages/presentation/bloc/package_activation_bloc.dart';

/// Shows the card-activation sheet for a package. [courseIds] is the
/// already-confirmed pick from the detail page (exactly `pick_count` items)
/// — this sheet only takes the card code. Resolves to `true` when the
/// package was activated so the caller can refresh.
Future<bool> showPackageActivationSheet(
  BuildContext context, {
  required int packageId,
  required List<int> courseIds,
}) async {
  final result = await showAppBottomSheet<bool>(
    context,
    builder: (_) => BlocProvider(
      create: (_) =>
          getIt<PackageActivationBloc>(param1: packageId, param2: courseIds),
      child: const _PackageActivationForm(),
    ),
  );
  return result ?? false;
}

class _PackageActivationForm extends StatefulWidget {
  const _PackageActivationForm();

  @override
  State<_PackageActivationForm> createState() => _PackageActivationFormState();
}

class _PackageActivationFormState extends State<_PackageActivationForm> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final code = CardCodeFormatter.normalize(_controller.text);
    if (code.isEmpty) return;
    context.read<PackageActivationBloc>().add(
      PackageActivationSubmitted(code),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PackageActivationBloc, PackageActivationState>(
      builder: (context, state) => Padding(
        padding: const EdgeInsetsDirectional.all(AppSpacing.xxl),
        child: AnimatedSwitcher(
          duration: AppMotion.medium,
          child: state.status == SubmissionStatus.success
              ? const _Success()
              : _Entry(
                  controller: _controller,
                  state: state,
                  onSubmit: _submit,
                ),
        ),
      ),
    );
  }
}

class _Entry extends StatelessWidget {
  const _Entry({
    required this.controller,
    required this.state,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final PackageActivationState state;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final failure = state.failure;
    final error = failure == null
        ? null
        : failure is ValidationFailure || failure is ForbiddenFailure
        ? failure.localized(l10n)
        : failure is NetworkFailure
        ? failure.localized(l10n)
        : l10n.activationFailed;
    return Column(
      key: const ValueKey('entry'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.packageActivationTitle, style: context.text.headlineSmall),
        const SizedBox(height: AppSpacing.xs),
        Text(
          l10n.activationSubtitle,
          style: context.text.bodyMedium?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        AppTextField(
          controller: controller,
          label: l10n.activationCodeLabel,
          prefixIcon: Icons.confirmation_number_outlined,
          forceLtr: true,
          errorText: error,
          textCapitalization: TextCapitalization.characters,
          textInputAction: TextInputAction.done,
          inputFormatters: const [CardCodeFormatter()],
          onSubmitted: (_) => onSubmit(),
        ),
        const SizedBox(height: AppSpacing.xl),
        AppButton(
          label: l10n.activationAction,
          isLoading: state.status == SubmissionStatus.submitting,
          onPressed: onSubmit,
        ),
        const SizedBox(height: AppSpacing.md),
      ],
    );
  }
}

class _Success extends StatelessWidget {
  const _Success();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      key: const ValueKey('success'),
      mainAxisSize: MainAxisSize.min,
      children: [
        const IllustrationBadge(
          icon: Icons.check_rounded,
          tone: IllustrationTone.success,
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          l10n.packageActivationSuccessTitle,
          style: context.text.headlineSmall,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          l10n.packageActivationSuccessBody,
          textAlign: TextAlign.center,
          style: context.text.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.xl),
        AppButton(
          label: l10n.activationStart,
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    );
  }
}
