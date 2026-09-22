import 'package:flutter/material.dart';
import 'package:ibnzaidon/core/error/failure.dart';
import 'package:ibnzaidon/core/l10n/failure_message.dart';
import 'package:ibnzaidon/core/utils/context_extensions.dart';
import 'package:ibnzaidon/design_system/components/overlays.dart';
import 'package:ibnzaidon/design_system/components/state_views.dart';
import 'package:ibnzaidon/shared/presentation/auth_gate.dart';

/// Maps a [Failure] to the right illustrated state (offline, gate, error).
class FailureView extends StatelessWidget {
  const FailureView({required this.failure, this.onRetry, super.key});

  final Failure failure;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return switch (failure) {
      UnauthorizedFailure() => const SignInGateView(),
      NetworkFailure() => ErrorState(
        message: failure.localized(l10n),
        icon: Icons.wifi_off_rounded,
        onRetry: onRetry,
      ),
      _ => ErrorState(message: failure.localized(l10n), onRetry: onRetry),
    };
  }
}

extension FailureSnackbar on BuildContext {
  void showFailure(Failure failure) => AppSnackbar.show(
    this,
    failure.localized(l10n),
    type: AppSnackbarType.error,
  );
}
