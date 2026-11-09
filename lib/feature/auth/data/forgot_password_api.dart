import 'dart:convert';
import 'package:dio/dio.dart';

import '../../../networks/dio/dio.dart';
import '../../../networks/endpoints.dart';
import '../../../networks/exception_handler/data_source.dart';
import '../model/response_model.dart';

final class ForgotPasswordApi {
  static final ForgotPasswordApi _singleton = ForgotPasswordApi._internal();
  ForgotPasswordApi._internal();
  static ForgotPasswordApi get instance => _singleton;

  Future<ForgotPasswordResponse> forgotPassword({required String email}) async {
    try {
      Map<String, dynamic> data = {"email": email};
      Response response = await postHttp(EndPoints.forgetPass(), data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data is Map<String, dynamic>) {
          return ForgotPasswordResponse.fromJson(response.data);
        } else if (response.data is String) {
          return ForgotPasswordResponse.fromRawJson(response.data);
        } else {
          return ForgotPasswordResponse.fromRawJson(json.encode(response.data));
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
