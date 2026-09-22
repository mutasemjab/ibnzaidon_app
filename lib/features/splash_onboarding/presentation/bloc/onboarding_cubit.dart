import 'package:bloc/bloc.dart';
import 'package:ibnzaidon/core/storage/app_flow_store.dart';

/// State = "onboarding finished" (persisted so it only shows once).
class OnboardingCubit extends Cubit<bool> {
  OnboardingCubit(this._flowStore) : super(false);

  final AppFlowStore _flowStore;

  Future<void> complete() async {
    await _flowStore.markOnboardingSeen();
    emit(true);
  }
}
