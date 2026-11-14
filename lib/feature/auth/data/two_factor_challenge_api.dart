import 'dart:convert';
import 'package:dio/dio.dart';

import '../../../networks/dio/dio.dart';
import '../../../networks/endpoints.dart';
import '../../../networks/exception_handler/data_source.dart';
import '../model/two_factor_challenge_model.dart';

final class TwoFactorChallengeApi {
  static final TwoFactorChallengeApi _singleton = TwoFactorChallengeApi._internal();
  TwoFactorChallengeApi._internal();
  static TwoFactorChallengeApi get instance => _singleton;

  Future<TwoFactorChallengeModel> verifyTwoFactor(Map<String, dynamic> body) async {
    try {
      Response response = await postHttp(EndPoints.twoFactorChallenge(), body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data is Map<String, dynamic>) {
          return TwoFactorChallengeModel.fromJson(response.data);
        } else if (response.data is String) {
          return TwoFactorChallengeModel.fromRawJson(response.data);
        } else {
          return TwoFactorChallengeModel.fromRawJson(json.encode(response.data));
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
