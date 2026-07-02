import 'package:get_it/get_it.dart';

/// Service locator global.
/// Di-setup sekali di bootstrap, diakses dari mana saja via `getIt<T>()`.
final GetIt getIt = GetIt.instance;
