import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

/// 로깅 Interceptor
class LoggingInterceptor extends Interceptor {
  final Logger logger;

  LoggingInterceptor(this.logger);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    logger.d('''
┌─────────────────────────────────────────────────────────────────────
│ 📤 REQUEST
├─────────────────────────────────────────────────────────────────────
│ Method: ${options.method}
│ URL: ${options.uri}
│ Headers: ${options.headers}
│ Query Parameters: ${options.queryParameters}
│ Data: ${options.data}
└─────────────────────────────────────────────────────────────────────
''');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    logger.d('''
┌─────────────────────────────────────────────────────────────────────
│ 📥 RESPONSE
├─────────────────────────────────────────────────────────────────────
│ Status Code: ${response.statusCode}
│ URL: ${response.requestOptions.uri}
│ Headers: ${response.headers}
│ Data: ${response.data}
└─────────────────────────────────────────────────────────────────────
''');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    logger.e('''
┌─────────────────────────────────────────────────────────────────────
│ ❌ ERROR
├─────────────────────────────────────────────────────────────────────
│ Type: ${err.type}
│ URL: ${err.requestOptions.uri}
│ Status Code: ${err.response?.statusCode}
│ Message: ${err.message}
│ Error: ${err.error}
│ Response Data: ${err.response?.data}
└─────────────────────────────────────────────────────────────────────
''');
    super.onError(err, handler);
  }
}
