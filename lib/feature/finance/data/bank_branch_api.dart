import 'dart:convert';
import 'package:dio/dio.dart';

import '../../../networks/dio/dio.dart';
import '../../../networks/endpoints.dart';
import '../../../networks/exception_handler/data_source.dart';
import '../model/bank_branch_model.dart';

final class BankBranchApi {
  static final BankBranchApi _singleton = BankBranchApi._internal();
  BankBranchApi._internal();
  static BankBranchApi get instance => _singleton;

  Future<BankBranchResponseModel> getBranches(String bankCode, {String? districtId}) async {
    try {
      String url = EndPoints.bankBranches(bankCode);
      if (districtId != null && districtId.isNotEmpty) {
        url += "?district_id=$districtId";
      }
      Response response = await getHttp(url);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data is Map<String, dynamic>) {
          return BankBranchResponseModel.fromJson(response.data);
        } else if (response.data is String) {
          return BankBranchResponseModel.fromRawJson(response.data);
        } else {
          return BankBranchResponseModel.fromRawJson(json.encode(response.data));
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
