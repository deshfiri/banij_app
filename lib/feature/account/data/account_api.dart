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
      Response response = await getHttp(EndPoints.profile());

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data is Map<String, dynamic>) {
          return AccountModel.fromJson(response.data);
        } else if (response.data is String) {
          return AccountModel.fromRawJson(response.data);
        } else {
          return AccountModel.fromRawJson(json.encode(response.data));
        }
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<AccountModel> updateProfile(Map<String, dynamic> updateData) async {
    try {
      Response response = await patchHttp(EndPoints.profile(), updateData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data is Map<String, dynamic>) {
          return AccountModel.fromJson(response.data);
        } else if (response.data is String) {
          return AccountModel.fromRawJson(response.data);
        } else {
          return AccountModel.fromRawJson(json.encode(response.data));
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

  Future<void> logout() async {
    try {
      await postHttp(EndPoints.logout());
    } catch (_) {
      rethrow;
    }
  }

  Future<void> deleteAccount({required String currentPassword, required String reason}) async {
    try {
      Map<String, dynamic> data = {
        "current_password": currentPassword,
        "reason": reason,
      };
      Response response = await postHttp(EndPoints.accountDelete(), data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return;
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

  Future<AccountDeletionInfoModel> getAccountDeletionInfo() async {
    try {
      Response response = await getHttp(EndPoints.accountDelete());

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data is Map<String, dynamic> || response.data is List) {
          return AccountDeletionInfoModel.fromJson(response.data);
        } else if (response.data is String) {
          return AccountDeletionInfoModel.fromRawJson(response.data);
        } else {
          return AccountDeletionInfoModel.fromRawJson(json.encode(response.data));
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
