import 'dart:convert';
import 'package:dio/dio.dart';

import '../../../networks/dio/dio.dart';
import '../../../networks/endpoints.dart';
import '../../../networks/exception_handler/data_source.dart';
import '../model/security_model.dart';

final class SecurityApi {
  static final SecurityApi _singleton = SecurityApi._internal();
  SecurityApi._internal();
  static SecurityApi get instance => _singleton;

  Future<SecurityModel> getSecurityRules() async {
    try {
      Response response = await getHttp(EndPoints.securityRules());

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data is Map<String, dynamic>) {
          return SecurityModel.fromJson(response.data);
        } else if (response.data is String) {
          return SecurityModel.fromRawJson(response.data);
        } else {
          return SecurityModel.fromRawJson(json.encode(response.data));
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
