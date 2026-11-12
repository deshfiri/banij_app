import 'dart:convert';
import 'package:dio/dio.dart';

import '../../../networks/dio/dio.dart';
import '../../../networks/endpoints.dart';
import '../../../networks/exception_handler/data_source.dart';
import '../model/bank_model.dart';

final class BankApi {
  static final BankApi _singleton = BankApi._internal();
  BankApi._internal();
  static BankApi get instance => _singleton;

  Future<BankResponseModel> getBanks() async {
    try {
      Response response = await getHttp(EndPoints.bankList());

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data is Map<String, dynamic>) {
          return BankResponseModel.fromJson(response.data);
        } else if (response.data is String) {
          return BankResponseModel.fromRawJson(response.data);
        } else {
          return BankResponseModel.fromRawJson(json.encode(response.data));
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
