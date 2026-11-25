import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../endpoints.dart';
import 'log.dart';

final class DioSingleton {
  static final DioSingleton _singleton = DioSingleton._internal();
  static CancelToken cancelToken = CancelToken();
  DioSingleton._internal();

  static DioSingleton get instance => _singleton;

  late Dio dio;

  /// Fail fast on a dead connection; allow slower responses (PDFs, lists).
  static const Duration _connectTimeout = Duration(seconds: 30);
  static const Duration _receiveTimeout = Duration(seconds: 60);

  void create() {
    BaseOptions options = BaseOptions(
      baseUrl: url,
      connectTimeout: _connectTimeout,
      receiveTimeout: _receiveTimeout,
      headers: {NetworkConstants.ACCEPT: NetworkConstants.ACCEPT_TYPE},
    );
    dio = Dio(options)..interceptors.add(Logger());
  }

  void update(String auth) {
    if (kDebugMode) {
      debugPrint("Dio update");
    }

    BaseOptions options = BaseOptions(
      baseUrl: url,
      responseType: ResponseType.json,
      headers: {
        NetworkConstants.ACCEPT: NetworkConstants.ACCEPT_TYPE,
        NetworkConstants.AUTHORIZATION: "Bearer $auth",
      },
      connectTimeout: _connectTimeout,
      receiveTimeout: _receiveTimeout,
    );
    dio = Dio(options)..interceptors.add(Logger());
  }
}

Future<Response> postHttp(String path, [dynamic data]) => DioSingleton
    .instance
    .dio
    .post(path, data: data, options: Options(followRedirects: false), cancelToken: DioSingleton.cancelToken);

Future<Response> patchHttp(String path, [dynamic data]) => DioSingleton
    .instance
    .dio
    .patch(path, data: data, options: Options(followRedirects: false), cancelToken: DioSingleton.cancelToken);

Future<Response> putHttp(String path, [dynamic data]) => DioSingleton
    .instance
    .dio
    .put(path, data: data, options: Options(followRedirects: false), cancelToken: DioSingleton.cancelToken);

Future<Response> getHttp(String path, [dynamic data]) =>
    DioSingleton.instance.dio.get(path, options: Options(followRedirects: false), cancelToken: DioSingleton.cancelToken);

Future<Response> deleteHttp(String path, [dynamic data]) => DioSingleton
    .instance
    .dio
    .delete(path, data: data, options: Options(followRedirects: false), cancelToken: DioSingleton.cancelToken);
