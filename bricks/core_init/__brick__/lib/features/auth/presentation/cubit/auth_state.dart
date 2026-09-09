import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/failure.dart';
import '../../data/models/auth_user_model.dart';

part 'auth_state.freezed.dart';

@freezed
sealed class AuthState with _$AuthState {
  const factory AuthState.initial() = AuthInitial;
  const factory AuthState.loading() = AuthLoading;
  const factory AuthState.success(AuthUser user) = AuthSuccess;
  const factory AuthState.error(Failure failure) = AuthError;
}
