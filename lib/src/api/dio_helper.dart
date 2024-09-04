import 'package:dio/dio.dart';
import 'package:flutter/services.dart';

class DioHelper {
  static const String base_url = '';

  static Dio getDio(String? baseURL) {
    final Dio dio = Dio();
    dio.options.baseUrl = baseURL ?? base_url;
    dio.options.connectTimeout = 30000;
    dio.options.receiveTimeout = 60000;
    dio.options.sendTimeout = 30000;
    return dio;
  }

  static void addInterceptors(Dio dio) {
    dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
  }

  static Exception? parseError(DioError error) {
    switch (error.type) {
      case DioErrorType.connectTimeout:
      case DioErrorType.sendTimeout:
      case DioErrorType.receiveTimeout:
        return _getException(Errors.code_timeout, Errors.message_timeout);

      case DioErrorType.response:
        String message;
        try {
          message = error.response?.data['message'];
        } catch (e) {
          message = error.message;
        }
        if (message.isEmpty) {
          message = error.message;
        }
        return _getException(Errors.code_response, message);
      case DioErrorType.cancel:
        return _getException(error.type.toString(), error.message);
      case DioErrorType.other:
      default:
        return _getException(error.type.toString(), error.message);
    }
  }

  static _getException(String code, String message) {
    return PlatformException(code: code, message: message);
  }
}

class Errors {
  static const code_timeout = 'TIMEOUT';
  static const message_timeout =
      'Looks like the server is taking too long to respond, this can be caused by either poor connectivity or an error with our servers. Please try again in a while.';

  static const code_response = 'RESPONSE';

  static const code_no_internet = 'NO_INTERNET';
  static const message_no_internet =
      'Sorry, no internet connection detected. Please reconnect and try again.';
}

