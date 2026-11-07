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
        final resData = RegisterResponse.fromRawJson(json.encode(response.data));
        return resData;
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (error) {
      rethrow;
    }
  }
}
