import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

class ApiInterceptor extends Interceptor {
  final _logger = Logger();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _logger.i('REQUEST[${options.method}] => PATH: ${options.path}');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _logger.i('RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logger.e('ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}');
    super.onError(err, handler);
  }
}
