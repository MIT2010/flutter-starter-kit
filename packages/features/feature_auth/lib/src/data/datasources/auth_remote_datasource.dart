import 'package:core/core.dart';
import 'package:core_network/core_network.dart';
import '../auth_endpoints.dart';
import '../models/auth_token_model.dart';
import '../models/otp_model.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthTokenModel> loginWithEmailPassword({
    required String email,
    required String password,
  });

  Future<OtpModel> requestOtp({required String destination});

  Future<AuthTokenModel> verifyOtp({
    required String destination,
    required String code,
  });

  Future<AuthTokenModel> refreshToken({required String refreshToken});

  Future<UserModel> getCurrentUser();

  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  const AuthRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<AuthTokenModel> loginWithEmailPassword({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      AuthEndpoints.login,
      data: {'email': email, 'password': password},
      fromData: (json) => json as Map<String, dynamic>,
    );

    if (!response.isSuccess || response.data == null) {
      throw ServerException(message: response.errorText);
    }

    return AuthTokenModel.fromJson(response.data!);
  }

  @override
  Future<OtpModel> requestOtp({required String destination}) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      AuthEndpoints.requestOtp,
      data: {'destination': destination},
      fromData: (json) => json as Map<String, dynamic>,
    );

    if (!response.isSuccess || response.data == null) {
      throw ServerException(message: response.errorText);
    }

    return OtpModel.fromJson(response.data!);
  }

  @override
  Future<AuthTokenModel> verifyOtp({
    required String destination,
    required String code,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      AuthEndpoints.verifyOtp,
      data: {'destination': destination, 'code': code},
      fromData: (json) => json as Map<String, dynamic>,
    );

    if (!response.isSuccess || response.data == null) {
      throw ServerException(message: response.errorText);
    }

    return AuthTokenModel.fromJson(response.data!);
  }

  @override
  Future<AuthTokenModel> refreshToken({required String refreshToken}) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      AuthEndpoints.refresh,
      data: {'refresh_token': refreshToken},
      fromData: (json) => json as Map<String, dynamic>,
    );

    if (!response.isSuccess || response.data == null) {
      throw ServerException(message: response.errorText);
    }

    return AuthTokenModel.fromJson(response.data!);
  }

  @override
  Future<UserModel> getCurrentUser() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      AuthEndpoints.me,
      fromData: (json) => json as Map<String, dynamic>,
    );

    if (!response.isSuccess || response.data == null) {
      throw ServerException(message: response.errorText);
    }

    return UserModel.fromJson(response.data!);
  }

  @override
  Future<void> logout() async {
    await _apiClient.post<void>(AuthEndpoints.logout);
  }
}
