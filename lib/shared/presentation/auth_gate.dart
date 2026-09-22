import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ibnzaidon/app/router/app_routes.dart';
import 'package:ibnzaidon/design_system/components/state_views.dart';
import 'package:ibnzaidon/features/auth/presentation/bloc/auth_bloc.dart';

/// Renders [builder] for signed-in students and a polished "Sign in to
/// continue" gate for guests — never an error.
class AuthGate extends StatelessWidget {
  const AuthGate({required this.builder, this.message, super.key});

  final WidgetBuilder builder;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final status = context.select<AuthBloc, AuthStatus>(
      (bloc) => bloc.state.status,
    );
    return switch (status) {
      AuthStatus.authenticated => builder(context),
      AuthStatus.unauthenticated => SignInGateView(message: message),
      AuthStatus.unknown => const Center(child: CircularProgressIndicator()),
    };
  }
}

class SignInGateView extends StatelessWidget {
  const SignInGateView({this.message, super.key});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final from = Uri.encodeComponent(GoRouterState.of(context).uri.toString());
    return SignInGate(
      message: message,
      onSignIn: () => context.push('${AppRoutes.login}?from=$from'),
      onCreateAccount: () => context.push('${AppRoutes.register}?from=$from'),
    );
  }
}

/// `true` when a student is signed in (use with `context.select`).
extension AuthContext on BuildContext {
  bool get isSignedIn => select<AuthBloc, bool>(
    (bloc) => bloc.state.isAuthenticated,
  );
}
