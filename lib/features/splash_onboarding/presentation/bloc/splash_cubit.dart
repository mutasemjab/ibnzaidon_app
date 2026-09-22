import 'package:bloc/bloc.dart';
import 'package:ibnzaidon/app/router/app_routes.dart';
import 'package:ibnzaidon/core/storage/app_flow_store.dart';
import 'package:ibnzaidon/features/auth/presentation/bloc/auth_bloc.dart';

/// Decides where the app goes after the animated splash. Waits for both the
/// minimum brand-animation time and the session check, so startup never
/// depends on a single endpoint.
class SplashCubit extends Cubit<String?> {
  SplashCubit({
    required AuthBloc authBloc,
    required AppFlowStore flowStore,
    this.minimumDuration = const Duration(milliseconds: 1400),
  }) : _authBloc = authBloc,
       _flowStore = flowStore,
       super(null);

  final AuthBloc _authBloc;
  final AppFlowStore _flowStore;
  final Duration minimumDuration;

  Future<void> start() async {
    final minimumDelay = Future<void>.delayed(minimumDuration);
    final authState = _authBloc.state.status != AuthStatus.unknown
        ? _authBloc.state
        : await _authBloc.stream.firstWhere(
            (state) => state.status != AuthStatus.unknown,
          );
    await minimumDelay;
    if (isClosed) return;
    emit(_destinationFor(authState));
  }

  String _destinationFor(AuthState authState) {
    if (authState.isAuthenticated) return AppRoutes.home;
    if (!_flowStore.onboardingSeen) return AppRoutes.onboarding;
    return _flowStore.guestChosen ? AppRoutes.home : AppRoutes.login;
  }
}
