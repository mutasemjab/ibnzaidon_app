import 'package:ibnzaidon/core/usecase/usecase.dart';
import 'package:ibnzaidon/design_system/components/price_view.dart';
import 'package:ibnzaidon/features/app_settings/domain/usecases/app_settings_usecases.dart';

/// Owns the `show_price` flag. Extends [PriceVisibilityCubit] so the design
/// system's [PriceView] can consume it without knowing about features.
class AppSettingsCubit extends PriceVisibilityCubit {
  AppSettingsCubit({
    required GetAppSettingsUseCase getAppSettings,
    required ReadLastKnownAppSettingsUseCase readLastKnown,
  }) : _getAppSettings = getAppSettings,
       super(initiallyVisible: readLastKnown().showPrice);

  final GetAppSettingsUseCase _getAppSettings;

  /// Best effort: a failure keeps the last known value (startup must not
  /// depend on this endpoint).
  Future<void> load() async {
    final result = await _getAppSettings(const NoParams());
    result.fold((_) {}, (settings) {
      if (!isClosed) emit(settings.showPrice);
    });
  }
}
