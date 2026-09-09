import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'di.config.dart';

final getIt = GetIt.instance;

/// Generated registration entrypoint. Never hand-edit `di.config.dart` —
/// re-run `dart run build_runner build --delete-conflicting-outputs` after
/// adding any `@injectable`/`@lazySingleton`/`@singleton`/`@module` class.
@InjectableInit()
Future<void> configureDependencies() => getIt.init();
