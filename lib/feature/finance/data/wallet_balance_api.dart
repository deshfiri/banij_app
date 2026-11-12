import 'dart:convert';
import 'package:dio/dio.dart';

import '../../../networks/dio/dio.dart';
import '../../../networks/endpoints.dart';
import '../../../networks/exception_handler/data_source.dart';
import '../model/wallet_balance_model.dart';

final class WalletBalanceApi {
  static final WalletBalanceApi _singleton = WalletBalanceApi._internal();
  WalletBalanceApi._internal();
  static WalletBalanceApi get instance => _singleton;

  Future<WalletBalanceResponseModel> getWalletBalance() async {
    try {
      Response response = await getHttp(EndPoints.walletBalnce());

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data is Map<String, dynamic>) {
          return WalletBalanceResponseModel.fromJson(response.data);
        } else if (response.data is String) {
          return WalletBalanceResponseModel.fromRawJson(response.data);
        } else {
          return WalletBalanceResponseModel.fromRawJson(json.encode(response.data));
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
