import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/error/app_exception.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/token_storage.dart';
import '../domain/user.dart';

class AuthRepository {
  AuthRepository({
    required ApiClient apiClient,
    required TokenStorage tokenStorage,
  }) : _dio = apiClient.dio,
       _tokenStorage = tokenStorage;

  final Dio _dio;
  final TokenStorage _tokenStorage;

  Future<User> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.login,
        data: {'username': username, 'password': password, 'expiresInMins': 30},
      );
      final data = response.data as Map<String, dynamic>;
      final accessToken = data['accessToken'] as String?;
      final refreshToken = data['refreshToken'] as String?;
      if (accessToken == null || refreshToken == null) {
        throw const AppException('Login failed. Please try again.');
      }
      await _tokenStorage.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
      return _toUser(data);
    } on DioException catch (_) {
      throw const AppException('Invalid credentials. Please check and retry.');
    }
  }

  Future<User> getCurrentUser() async {
    try {
      final response = await _dio.get(ApiConstants.me);
      return _toUser(response.data as Map<String, dynamic>);
    } on DioException catch (_) {
      throw const AppException('Session expired. Please log in again.');
    }
  }

  Future<bool> hasSession() async {
    final token = await _tokenStorage.readAccessToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> logout() => _tokenStorage.clear();

  User _toUser(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int? ?? 0,
      username: json['username'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
    );
  }
}
