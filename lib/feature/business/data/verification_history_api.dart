import 'dart:convert';
import 'package:dio/dio.dart';

import '../../../networks/dio/dio.dart';
import '../../../networks/endpoints.dart';
import '../../../networks/exception_handler/data_source.dart';
import '../model/verification_history_model.dart';

final class VerificationHistoryApi {
  static final VerificationHistoryApi _singleton = VerificationHistoryApi._internal();
  VerificationHistoryApi._internal();
  static VerificationHistoryApi get instance => _singleton;

  Future<VerificationHistoryResponseModel> getVerificationHistory() async {
    try {
      Response response = await getHttp(EndPoints.verificationHistory());

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data is Map<String, dynamic> || response.data is List) {
          return VerificationHistoryResponseModel.fromJson(response.data);
        } else if (response.data is String) {
          return VerificationHistoryResponseModel.fromRawJson(response.data);
        } else {
          return VerificationHistoryResponseModel.fromRawJson(json.encode(response.data));
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
