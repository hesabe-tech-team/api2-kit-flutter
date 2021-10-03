// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_interface.dart';

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

class _ApiInterface implements ApiInterface {
  _ApiInterface(this._dio, {this.baseUrl});

  final Dio _dio;

  String? baseUrl;

  @override
  Future<String> hesabePay(accessToken, data) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'data': data};
    final _data = <String, dynamic>{};
    final _result = await _dio.fetch<String>(_setStreamType<String>(Options(
            method: 'POST',
            headers: <String, dynamic>{r'accessCode': accessToken},
            extra: _extra)
        .compose(_dio.options, '/checkout',
            queryParameters: queryParameters, data: _data)
        .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data!;
    return value;
  }

  RequestOptions _setStreamType<T>(RequestOptions requestOptions) {
    if (T != dynamic &&
        !(requestOptions.responseType == ResponseType.bytes ||
            requestOptions.responseType == ResponseType.stream)) {
      if (T == String) {
        requestOptions.responseType = ResponseType.plain;
      } else {
        requestOptions.responseType = ResponseType.json;
      }
    }
    return requestOptions;
  }
}
