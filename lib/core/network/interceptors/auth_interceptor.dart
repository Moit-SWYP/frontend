import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:moit/core/storage/token_storage.dart';

/// 인증 Interceptor
///
/// - 요청 시 액세스 토큰을 헤더에 추가
/// - 401 에러 발생 시 토큰 재발급 후 재시도
class AuthInterceptor extends Interceptor {
  final Dio dio;
  final Logger logger;
  final TokenStorage _tokenStorage = TokenStorage();

  AuthInterceptor(this.dio, this.logger);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    print('🔐 [AuthInterceptor] 요청: ${options.method} ${options.path}');

    // 로그인/회원가입/토큰 재발급 요청은 토큰 불필요
    if (_isAuthEndpoint(options.path)) {
      print('🔐 [AuthInterceptor] 인증 불필요 엔드포인트');
      return handler.next(options);
    }

    // 액세스 토큰 추가
    final accessToken = await _tokenStorage.getAccessToken();
    print('🔐 [AuthInterceptor] 저장된 AccessToken: ${accessToken != null ? "${accessToken.substring(0, 20)}..." : "null"}');

    if (accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
      print('🔐 [AuthInterceptor] Authorization 헤더 추가 완료');
    } else {
      print('❌ [AuthInterceptor] AccessToken이 없습니다!');
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // 401 Unauthorized 에러인 경우
    if (err.response?.statusCode == 401) {
      final requestOptions = err.requestOptions;

      // 토큰 재발급 요청이 실패한 경우는 재시도하지 않음
      if (requestOptions.path.contains('/api/auth/reissue')) {
        logger.e('토큰 재발급 실패');
        await _tokenStorage.clearTokens();
        return handler.reject(err);
      }

      try {
        // 토큰 재발급
        logger.i('토큰 재발급 시도');
        final newAccessToken = await _refreshToken();

        if (newAccessToken != null) {
          // 새 토큰으로 원래 요청 재시도
          requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
          final response = await dio.fetch(requestOptions);
          return handler.resolve(response);
        }
      } catch (e) {
        logger.e('토큰 재발급 중 에러: $e');
        await _tokenStorage.clearTokens();
      }
    }

    handler.next(err);
  }

  /// 인증이 필요 없는 엔드포인트인지 확인
  bool _isAuthEndpoint(String path) {
    return path.contains('/api/auth/login') ||
        path.contains('/api/auth/signup') ||
        path.contains('/api/auth/reissue');
  }

  /// 토큰 재발급
  Future<String?> _refreshToken() async {
    try {
      final refreshToken = await _tokenStorage.getRefreshToken();
      if (refreshToken == null) {
        logger.w('리프레시 토큰이 없습니다');
        return null;
      }

      final response = await dio.post(
        '/api/auth/reissue',
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200) {
        final newAccessToken = response.data['accessToken'] as String?;
        final newRefreshToken = response.data['refreshToken'] as String?;

        if (newAccessToken != null && newRefreshToken != null) {
          await _tokenStorage.saveTokens(
            accessToken: newAccessToken,
            refreshToken: newRefreshToken,
          );
          logger.i('토큰 재발급 성공');
          return newAccessToken;
        }
      }

      return null;
    } catch (e) {
      logger.e('토큰 재발급 실패: $e');
      return null;
    }
  }
}
