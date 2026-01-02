import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:moit/core/config/api_config.dart';
import 'package:moit/core/network/interceptors/auth_interceptor.dart';
import 'package:moit/core/network/interceptors/logging_interceptor.dart';

/// Dio HTTP 클라이언트
class DioClient {
  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;

  late final Dio _dio;
  final Logger _logger = Logger();

  DioClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: Duration(seconds: ApiConfig.connectTimeout),
        receiveTimeout: Duration(seconds: ApiConfig.receiveTimeout),
        sendTimeout: Duration(seconds: ApiConfig.sendTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Interceptor 추가
    _dio.interceptors.addAll([
      LoggingInterceptor(_logger),
      AuthInterceptor(_dio, _logger),
    ]);
  }

  /// Dio 인스턴스 반환
  Dio get dio => _dio;

  /// GET 요청
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  /// POST 요청
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  /// PUT 요청
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  /// PATCH 요청
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  /// DELETE 요청
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  /// 에러 처리
  void _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        _logger.e('타임아웃 에러: ${error.message}');
        break;
      case DioExceptionType.badResponse:
        _logger.e('응답 에러 [${error.response?.statusCode}]: ${error.response?.data}');
        break;
      case DioExceptionType.cancel:
        _logger.w('요청 취소됨');
        break;
      case DioExceptionType.connectionError:
        _logger.e('연결 에러: ${error.message}');
        break;
      case DioExceptionType.badCertificate:
        _logger.e('인증서 에러: ${error.message}');
        break;
      case DioExceptionType.unknown:
        _logger.e('알 수 없는 에러: ${error.message}');
        break;
    }
  }
}
