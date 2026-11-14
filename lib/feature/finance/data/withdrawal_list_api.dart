import 'dart:convert';
import 'package:dio/dio.dart';

import '../../../networks/dio/dio.dart';
import '../../../networks/endpoints.dart';
import '../../../networks/exception_handler/data_source.dart';
import '../model/withdrawal_list_model.dart';

final class WithdrawalListApi {
  static final WithdrawalListApi _singleton = WithdrawalListApi._internal();
  WithdrawalListApi._internal();
  static WithdrawalListApi get instance => _singleton;

  Future<WithdrawalListResponseModel> getWithdrawalList() async {
    try {
      Response response = await getHttp(EndPoints.withdrawals());

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data is Map<String, dynamic>) {
          return WithdrawalListResponseModel.fromJson(response.data);
        } else if (response.data is String) {
          return WithdrawalListResponseModel.fromRawJson(response.data);
        } else {
          return WithdrawalListResponseModel.fromRawJson(json.encode(response.data));
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
