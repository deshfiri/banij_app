import 'dart:convert';
import 'package:dio/dio.dart';

import '../../../networks/dio/dio.dart';
import '../../../networks/endpoints.dart';
import '../../../networks/exception_handler/data_source.dart';
import '../model/referrals_model.dart';

final class ReferralsApi {
  static final ReferralsApi _singleton = ReferralsApi._internal();
  ReferralsApi._internal();
  static ReferralsApi get instance => _singleton;

  Future<ReferralsModel> getReferrals() async {
    try {
      Response response = await getHttp(EndPoints.referrals());

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data is Map<String, dynamic>) {
          return ReferralsModel.fromJson(response.data);
        } else if (response.data is String) {
          return ReferralsModel.fromRawJson(response.data);
        } else {
          return ReferralsModel.fromRawJson(json.encode(response.data));
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
