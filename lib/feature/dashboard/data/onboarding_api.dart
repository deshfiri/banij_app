import 'dart:convert';
import 'package:dio/dio.dart';

import '../../../networks/dio/dio.dart';
import '../../../networks/endpoints.dart';
import '../../../networks/exception_handler/data_source.dart';
import '../model/onboarding_model.dart';

final class OnboardingApi {
  static final OnboardingApi _singleton = OnboardingApi._internal();
  OnboardingApi._internal();
  static OnboardingApi get instance => _singleton;

  Future<OnboardingResponseModel> getOnboardingStatus() async {
    try {
      Response response = await getHttp(EndPoints.onboradingActive());

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data is Map<String, dynamic>) {
          return OnboardingResponseModel.fromJson(response.data);
        } else if (response.data is String) {
          return OnboardingResponseModel.fromRawJson(response.data);
        } else {
          return OnboardingResponseModel.fromRawJson(json.encode(response.data));
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
