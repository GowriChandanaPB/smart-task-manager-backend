import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class DioClient {
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: 'https://smart-task-manager-backend-1.onrender.com/api',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  )..interceptors.addAll([
      _LoggingInterceptor(),
      _ErrorInterceptor(),
    ]);
}
class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('➡️ REQUEST');
      debugPrint('${options.method} ${options.uri}');
      debugPrint('Headers: ${options.headers}');
      debugPrint('Data: ${options.data}');
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(
      Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('✅ RESPONSE');
      debugPrint('Status: ${response.statusCode}');
      debugPrint('Data: ${response.data}');
    }
    super.onResponse(response, handler);
  }
}
class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    String message = 'Something went wrong';

    if (err.type == DioExceptionType.connectionTimeout) {
      message = 'Connection timeout';
    } else if (err.type == DioExceptionType.receiveTimeout) {
      message = 'Server not responding';
    } else if (err.type == DioExceptionType.badResponse) {
      message =
          err.response?.data['message'] ?? 'Server error occurred';
    } else if (err.type == DioExceptionType.unknown) {
      message = 'No internet connection';
    }

    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        error: message,
        type: err.type,
      ),
    );
  }
}
