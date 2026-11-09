import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../networks/dio/dio.dart';
import '../../../networks/endpoints.dart';
import '../../../networks/exception_handler/data_source.dart';
import '../model/response_model.dart';

final class RegisterApi {
  static final RegisterApi _singleton = RegisterApi._internal();
  RegisterApi._internal();
  static RegisterApi get instance => _singleton;

  Future<RegisterResponse> register({
    required Map<String, dynamic> registrationData,
  }) async {
    try {
      Response response = await postHttp(EndPoints.signup(), registrationData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data is Map<String, dynamic>) {
          return RegisterResponse.fromJson(response.data);
        } else if (response.data is String) {
          return RegisterResponse.fromRawJson(response.data);
        } else {
          return RegisterResponse.fromRawJson(json.encode(response.data));
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
