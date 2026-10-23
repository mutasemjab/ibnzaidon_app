import 'package:ibnzaidon/core/usecase/usecase.dart';
import 'package:ibnzaidon/design_system/components/price_view.dart';
import 'package:ibnzaidon/features/app_settings/domain/entities/app_settings.dart';
import 'package:ibnzaidon/features/app_settings/domain/usecases/app_settings_usecases.dart';

/// Owns the `show_price` flag. Extends [PriceVisibilityCubit] so the design
/// system's [PriceView] can consume it without knowing about features.
///
/// Also holds the rest of `AppSettings` (currently just [whatsappNumber])
/// as a plain field rather than a second cubit — it's app-wide config read
/// once via `getIt`, not something screens need to rebuild on.
class AppSettingsCubit extends PriceVisibilityCubit {
  AppSettingsCubit({
    required GetAppSettingsUseCase getAppSettings,
    required ReadLastKnownAppSettingsUseCase readLastKnown,
  }) : _getAppSettings = getAppSettings,
       _settings = readLastKnown(),
       super(initiallyVisible: readLastKnown().showPrice);

  final GetAppSettingsUseCase _getAppSettings;
  AppSettings _settings;

  String? get whatsappNumber => _settings.whatsappNumber;

  /// Best effort: a failure keeps the last known value (startup must not
  /// depend on this endpoint).
  Future<void> load() async {
    final result = await _getAppSettings(const NoParams());
    result.fold((_) {}, (settings) {
      _settings = settings;
      if (!isClosed) emit(settings.showPrice);
    });
  }
}
