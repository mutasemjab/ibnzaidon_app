import 'package:ibnzaidon/core/storage/key_value_store.dart';

/// First-run flags: onboarding seen, guest browsing chosen.
class AppFlowStore {
  AppFlowStore(this._store);

  static const _onboardingKey = 'flow.onboarding_seen';
  static const _guestKey = 'flow.guest_chosen';

  final KeyValueStore _store;

  bool get onboardingSeen => _store.getBool(_onboardingKey) ?? false;
  bool get guestChosen => _store.getBool(_guestKey) ?? false;

  Future<void> markOnboardingSeen() =>
      _store.setBool(_onboardingKey, value: true);

  Future<void> setGuestChosen({required bool value}) =>
      _store.setBool(_guestKey, value: value);
}
