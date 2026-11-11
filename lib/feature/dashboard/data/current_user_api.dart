import 'dart:convert';
import 'package:dio/dio.dart';

import '../../../networks/dio/dio.dart';
import '../../../networks/endpoints.dart';
import '../../../networks/exception_handler/data_source.dart';
import '../model/current_user_model.dart';

final class CurrentUserApi {
  static final CurrentUserApi _singleton = CurrentUserApi._internal();
  CurrentUserApi._internal();
  static CurrentUserApi get instance => _singleton;

  Future<CurrentUserModel> getCurrentUser() async {
    try {
      Response response = await getHttp(EndPoints.currentUser());

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data is Map<String, dynamic>) {
          return CurrentUserModel.fromJson(response.data);
        } else if (response.data is String) {
          return CurrentUserModel.fromRawJson(response.data);
        } else {
          return CurrentUserModel.fromRawJson(json.encode(response.data));
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
