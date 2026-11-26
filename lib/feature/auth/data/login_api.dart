import 'dart:convert';

import 'package:dio/dio.dart';

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
      Map<String, dynamic> data = {
        "email": email,
        "userId": email,
        "password": password,
        "device_name": "mobile",
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
      if (dioError.response?.data != null) {
        final data = dioError.response?.data;
        if (data is Map && data.containsKey('message')) {
          throw Exception(data['message'].toString());
        } else if (data is Map && data.containsKey('error')) {
          throw Exception(data['error'].toString());
        }
      }
      rethrow;
    } catch (error) {
      rethrow;
    }
  }
}
