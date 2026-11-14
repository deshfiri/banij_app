import 'dart:convert';
import 'package:dio/dio.dart';

import '../../../networks/dio/dio.dart';
import '../../../networks/endpoints.dart';
import '../../../networks/exception_handler/data_source.dart';
import '../model/withdrawal_options_model.dart';

final class WithdrawalOptionsApi {
  static final WithdrawalOptionsApi _singleton = WithdrawalOptionsApi._internal();
  WithdrawalOptionsApi._internal();
  static WithdrawalOptionsApi get instance => _singleton;

  Future<WithdrawalOptionsModel> getWithdrawalOptions() async {
    try {
      Response response = await getHttp(EndPoints.withdrawaloption());

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data is Map<String, dynamic>) {
          return WithdrawalOptionsModel.fromJson(response.data);
        } else if (response.data is String) {
          return WithdrawalOptionsModel.fromRawJson(response.data);
        } else {
          return WithdrawalOptionsModel.fromRawJson(json.encode(response.data));
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
