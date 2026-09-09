import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../core/storage/hive_client.dart';

enum AuthStatus {
  /// Startup check hasn't run yet. The router MUST NOT redirect while in
  /// this state — see the cold-start bug this avoids in docs/decisions.
  unknown,
  authenticated,
  unauthenticated,
}

/// App-wide auth resolution state, used by the router's redirect guard.
///
/// This holds only resolution *status*, not login logic itself — the real
/// login/logout flow lives in `features/auth` (a normal layered feature).
/// `AuthCubit` there calls [markAuthenticated]/[markUnauthenticated] once its
/// repository call actually succeeds; this class never talks to the network.
@singleton
class AuthStatusNotifier extends ChangeNotifier {
  AuthStatusNotifier(this._hiveClient);

  final HiveClient _hiveClient;

  AuthStatus _status = AuthStatus.unknown;
  AuthStatus get status => _status;

  /// Resolves auth status from local storage. Call once at startup before
  /// the first frame, so the router never has to guess.
  Future<void> resolve() async {
    final token = _hiveClient.authToken;
    _status = (token != null && token.isNotEmpty)
        ? AuthStatus.authenticated
        : AuthStatus.unauthenticated;
    notifyListeners();
  }

  void markAuthenticated() {
    _status = AuthStatus.authenticated;
    notifyListeners();
  }

  Future<void> markUnauthenticated() async {
    await _hiveClient.clearAuthToken();
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
