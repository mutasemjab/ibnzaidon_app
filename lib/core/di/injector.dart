import 'package:get_it/get_it.dart';

/// Global service locator. Only composition roots and route-level
/// `BlocProvider`s resolve from it; widgets never touch repositories.
final GetIt getIt = GetIt.instance;
