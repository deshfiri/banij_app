import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../helpers/helpers_method.dart';
import '../../../networks/dio/dio.dart';
import '../../../networks/endpoints.dart';
import '../../../networks/exception_handler/data_source.dart';
import '../model/response_model.dart';

final class LoginApi {
  static final LoginApi _singleton = LoginApi._internal();
  LoginApi._internal();
  static LoginApi get instance => _singleton;

  Future<LoginResponse> login({
    required String email,
    required String password,
    bool isSupplier = false,
  }) async {
    try {
      // Exactly the LoginRequest fields of the API.
      final data = <String, dynamic>{
        "email": email,
        "password": password,
        "device_name": await deviceLabel(),
      };

      final endpoint = isSupplier ? EndPoints.suplierLogin() : EndPoints.login();
      Response response = await postHttp(endpoint, data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data is Map<String, dynamic>) {
          return LoginResponse.fromJson(response.data);
        } else if (response.data is String) {
          return LoginResponse.fromRawJson(response.data);
        } else {
          return LoginResponse.fromRawJson(json.encode(response.data));
        }
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } on DioException catch (dioError) {
      final status = dioError.response?.statusCode;
      final data = dioError.response?.data;
      if (data is Map && data.containsKey('message')) {
        throw LoginFailure(data['message'].toString(), statusCode: status);
      } else if (data is Map && data.containsKey('error')) {
        throw LoginFailure(data['error'].toString(), statusCode: status);
      }
      if (status != null) throw LoginFailure('Login failed ($status).', statusCode: status);
      // No answer from the server: a readable reason instead of Dio's text.
      throw LoginFailure(switch (dioError.type) {
        DioExceptionType.connectionTimeout ||
        DioExceptionType.receiveTimeout ||
        DioExceptionType.sendTimeout =>
          'The server took too long to answer. Please try again.',
        DioExceptionType.connectionError => 'No internet connection. Please check your network and try again.',
        _ => 'Could not reach the server. Please try again.',
      });
    } catch (error) {
      rethrow;
    }
  }
}
