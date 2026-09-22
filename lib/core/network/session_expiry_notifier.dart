import 'dart:async';

/// Broadcasts "the server rejected our token" so `AuthBloc` can reset the
/// session without the network layer knowing about it.
class SessionExpiryNotifier {
  final _controller = StreamController<void>.broadcast();

  Stream<void> get stream => _controller.stream;

  void notifyExpired() => _controller.add(null);

  Future<void> dispose() => _controller.close();
}
