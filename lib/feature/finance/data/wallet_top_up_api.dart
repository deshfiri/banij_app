import 'dart:convert';
import 'package:dio/dio.dart';

import '../../../networks/dio/dio.dart';
import '../../../networks/endpoints.dart';
import '../../../networks/exception_handler/data_source.dart';
import '../model/wallet_top_up_model.dart';

final class WalletTopUpApi {
  static final WalletTopUpApi _singleton = WalletTopUpApi._internal();
  WalletTopUpApi._internal();
  static WalletTopUpApi get instance => _singleton;

  Future<WalletTopUpModel> topUpWallet(Map<String, dynamic> body) async {
    try {
      Response response = await postHttp(EndPoints.topWallet(), body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data is Map<String, dynamic>) {
          return WalletTopUpModel.fromJson(response.data);
        } else if (response.data is String) {
          return WalletTopUpModel.fromRawJson(response.data);
        } else {
          return WalletTopUpModel.fromRawJson(json.encode(response.data));
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
