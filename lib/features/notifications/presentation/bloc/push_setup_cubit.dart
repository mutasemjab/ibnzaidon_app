import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ibnzaidon/core/storage/key_value_store.dart';
import 'package:ibnzaidon/features/notifications/domain/entities/app_notification.dart';
import 'package:ibnzaidon/features/notifications/domain/services/push_messaging_service.dart';
import 'package:ibnzaidon/features/notifications/domain/usecases/notifications_usecases.dart';

final class PushSetupState extends Equatable {
  const PushSetupState({
    this.permission = PushPermission.unknown,
    this.shouldExplain = false,
    this.openedMessage,
    this.foregroundCount = 0,
  });

  final PushPermission permission;

  /// Show the pre-permission explainer screen.
  final bool shouldExplain;

  /// Set when the user tapped a notification (background or launch).
  final PushMessage? openedMessage;

  /// Increments on every foreground push so listeners can refresh the badge.
  final int foregroundCount;

  PushSetupState copyWith({
    PushPermission? permission,
    bool? shouldExplain,
    PushMessage? openedMessage,
    int? foregroundCount,
    bool clearOpened = false,
  }) => PushSetupState(
    permission: permission ?? this.permission,
    shouldExplain: shouldExplain ?? this.shouldExplain,
    openedMessage: clearOpened ? null : openedMessage ?? this.openedMessage,
    foregroundCount: foregroundCount ?? this.foregroundCount,
  );

  @override
  List<Object?> get props => [
    permission,
    shouldExplain,
    openedMessage,
    foregroundCount,
  ];
}

/// Owns push setup: explainer -> permission -> FCM token registration
/// (after login and on refresh) and forwards push events to the UI.
class PushSetupCubit extends Cubit<PushSetupState> {
  PushSetupCubit({
    required PushMessagingService service,
    required RegisterDeviceTokenUseCase registerToken,
    required KeyValueStore store,
  }) : _service = service,
       _registerToken = registerToken,
       _store = store,
       super(const PushSetupState());

  static const _explainerSeenKey = 'push.explainer_seen';

  final PushMessagingService _service;
  final RegisterDeviceTokenUseCase _registerToken;
  final KeyValueStore _store;
  final List<StreamSubscription<Object?>> _subscriptions = [];
  bool _listening = false;

  bool get _explainerSeen => _store.getBool(_explainerSeenKey) ?? false;

  /// Call once a student is signed in.
  Future<void> onSignedIn() async {
    await _listen();
    final permission = await _service.permissionStatus();
    if (isClosed) return;
    emit(
      state.copyWith(
        permission: permission,
        shouldExplain: permission == PushPermission.unknown && !_explainerSeen,
      ),
    );
    if (permission == PushPermission.granted) await _syncToken();
  }

  Future<void> _listen() async {
    if (_listening) return;
    _listening = true;
    _subscriptions
      ..add(
        _service.onTokenRefresh.listen(_registerToken.call),
      )
      ..add(
        _service.onForegroundMessage.listen(
          (_) =>
              emit(state.copyWith(foregroundCount: state.foregroundCount + 1)),
        ),
      )
      ..add(
        _service.onMessageOpened.listen(
          (message) => emit(state.copyWith(openedMessage: message)),
        ),
      );
    final initial = await _service.initialMessage();
    if (initial != null && !isClosed) {
      emit(state.copyWith(openedMessage: initial));
    }
  }

  /// "Enable notifications" on the explainer screen.
  Future<void> enable() async {
    await _store.setBool(_explainerSeenKey, value: true);
    final permission = await _service.requestPermission();
    if (isClosed) return;
    emit(state.copyWith(permission: permission, shouldExplain: false));
    if (permission == PushPermission.granted) await _syncToken();
  }

  /// "Not now": never nag again automatically.
  Future<void> dismissExplainer() async {
    await _store.setBool(_explainerSeenKey, value: true);
    if (!isClosed) emit(state.copyWith(shouldExplain: false));
  }

  void openedMessageHandled() => emit(state.copyWith(clearOpened: true));

  Future<void> _syncToken() async {
    final token = await _service.getToken();
    if (token != null) await _registerToken(token);
  }

  @override
  Future<void> close() async {
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    return super.close();
  }
}
