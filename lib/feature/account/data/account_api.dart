import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../networks/dio/dio.dart';
import '../../../networks/endpoints.dart';
import '../../../networks/exception_handler/data_source.dart';
import '../model/account_model.dart';

final class AccountApi {
  static final AccountApi _singleton = AccountApi._internal();
  AccountApi._internal();
  static AccountApi get instance => _singleton;

  Future<AccountModel> getProfile() async {
    try {
      Response response = await getHttp(EndPoints.userProfile());

      if (response.statusCode == 200) {
        final data = AccountModel.fromRawJson(json.encode(response.data));
        return data;
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<AccountModel> updateProfile(Map<String, dynamic> updateData) async {
    try {
      Response response = await postHttp(EndPoints.updateProfile(), updateData);

      if (response.statusCode == 200) {
        final data = AccountModel.fromRawJson(json.encode(response.data));
        return data;
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (error) {
      rethrow;
    }
  }
}
