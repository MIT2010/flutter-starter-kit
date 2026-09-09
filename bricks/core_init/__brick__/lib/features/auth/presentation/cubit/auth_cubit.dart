import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../app/auth_status_notifier.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_state.dart';

@injectable
class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repository, this._authStatusNotifier)
    : super(const AuthState.initial());

  final AuthRepository _repository;
  final AuthStatusNotifier _authStatusNotifier;

  Future<void> login({required String email, required String password}) async {
    emit(const AuthState.loading());
    final result = await _repository.login(email: email, password: password);
    result.fold(
      onFailure: (failure) => emit(AuthState.error(failure)),
      onSuccess: (user) {
        _authStatusNotifier.markAuthenticated();
        emit(AuthState.success(user));
      },
    );
  }

  /// Deliberately doesn't fold on `_repository.logout()`'s Result — the
  /// local session is cleared either way. If you wire a real backend and
  /// its revoke-token call can fail in a way that matters, decide there
  /// whether that should block clearing local state; don't assume this
  /// silently-ignored Result was an oversight.
  Future<void> logout() async {
    await _repository.logout();
    await _authStatusNotifier.markUnauthenticated();
    emit(const AuthState.initial());
  }
}
