import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import '../constants/api_constants.dart';
import '../storage/token_storage.dart';

typedef LogoutCallback = Future<void> Function();

class ApiClient {
  ApiClient({
    required TokenStorage tokenStorage,
    required Logger logger,
    required LogoutCallback onForceLogout,
  }) : _tokenStorage = tokenStorage,
       _logger = logger,
       _onForceLogout = onForceLogout {
    dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _tokenStorage.readAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          _logger.i('REQ ${options.method} ${options.uri}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          _logger.i(
            'RES ${response.statusCode} ${response.requestOptions.path}',
          );
          handler.next(response);
        },
        onError: (error, handler) async {
          _logger.e('ERR ${error.requestOptions.path}: ${error.message}');
          final shouldRefresh =
              error.response?.statusCode == 401 &&
              error.requestOptions.path != ApiConstants.login &&
              error.requestOptions.path != ApiConstants.refresh;
          if (!shouldRefresh) {
            handler.next(error);
            return;
          }

          try {
            final refreshToken = await _tokenStorage.readRefreshToken();
            if (refreshToken == null || refreshToken.isEmpty) {
              await _onForceLogout();
              handler.next(error);
              return;
            }
            final refreshResponse = await dio.post(
              ApiConstants.refresh,
              data: {'refreshToken': refreshToken, 'expiresInMins': 30},
              options: Options(headers: {'Authorization': null}),
            );
            final newAccessToken =
                refreshResponse.data['accessToken'] as String?;
            final newRefreshToken =
                (refreshResponse.data['refreshToken'] as String?) ??
                refreshToken;
            if (newAccessToken == null || newAccessToken.isEmpty) {
              await _onForceLogout();
              handler.next(error);
              return;
            }
            await _tokenStorage.saveTokens(
              accessToken: newAccessToken,
              refreshToken: newRefreshToken,
            );
            final request = error.requestOptions;
            request.headers['Authorization'] = 'Bearer $newAccessToken';
            final retryResponse = await dio.fetch(request);
            handler.resolve(retryResponse);
          } catch (_) {
            await _onForceLogout();
            handler.next(error);
          }
        },
      ),
    );
  }

  final TokenStorage _tokenStorage;
  final Logger _logger;
  final LogoutCallback _onForceLogout;
  late final Dio dio;
}
