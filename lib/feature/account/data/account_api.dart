import 'dart:convert';

import 'package:bbnij/constants/app_constants.dart';
import 'package:bbnij/helpers/di.dart';
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

  Future<void> changePasswordApi({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final token = appData.read(kKeyAccessToken) ?? '';
      Map<String, dynamic> data = {
        "current_password": currentPassword,
        "password": password,
        "password_confirmation": passwordConfirmation,
      };
      Response response = await putHttp(EndPoints.changepassword(), data);

      if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode==204) {
        return;
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } on DioException catch (dioError) {
      if (dioError.response?.data != null) {
        final resData = dioError.response?.data;
        if (resData is Map && resData.containsKey('message')) {
          throw Exception(resData['message'].toString());
        } else if (resData is Map && resData.containsKey('error')) {
          throw Exception(resData['error'].toString());
        }
      }
      rethrow;
    } catch (error) {
      rethrow;
    }
  }
}
