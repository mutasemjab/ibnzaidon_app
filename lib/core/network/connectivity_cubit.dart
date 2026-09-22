import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// `true` when the device has no network. Drives the global offline banner.
class ConnectivityCubit extends Cubit<bool> {
  ConnectivityCubit(this._connectivity) : super(false) {
    _subscription = _connectivity.onConnectivityChanged.listen(_onChanged);
    unawaited(_connectivity.checkConnectivity().then(_onChanged));
  }

  final Connectivity _connectivity;
  late final StreamSubscription<List<ConnectivityResult>> _subscription;

  void _onChanged(List<ConnectivityResult> results) {
    final offline =
        results.isEmpty || results.every((r) => r == ConnectivityResult.none);
    if (!isClosed) emit(offline);
  }

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
