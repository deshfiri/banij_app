import 'dart:convert';
import 'package:dio/dio.dart';

import '../../../networks/dio/dio.dart';
import '../../../networks/endpoints.dart';
import '../../../networks/exception_handler/data_source.dart';
import '../model/subscription_model.dart';

final class SubscriptionApi {
  static final SubscriptionApi _singleton = SubscriptionApi._internal();
  SubscriptionApi._internal();
  static SubscriptionApi get instance => _singleton;

  Future<SubscriptionResponseModel> getSubscription([String? endpoint]) async {
    try {
      Response response = await getHttp(endpoint ?? EndPoints.subscription());

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data is Map<String, dynamic>) {
          return SubscriptionResponseModel.fromJson(response.data);
        } else if (response.data is String) {
          return SubscriptionResponseModel.fromRawJson(response.data);
        } else {
          return SubscriptionResponseModel.fromRawJson(json.encode(response.data));
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

  Future<bool> selectPackage(String packageSlug) async {
    try {
      Response response = await postHttp(EndPoints.selectPackage(packageSlug));
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  Future<bool> cancelSubscription() async {
    try {
      Response response = await postHttp(EndPoints.subscriptionCancel());
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  Future<bool> changeSubscription(String newPackageSlug) async {
    try {
      final body = {"package": newPackageSlug};
      Response response = await postHttp(EndPoints.subscriptionChange(), body);
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  Future<bool> renewSubscription() async {
    try {
      Response response = await postHttp(EndPoints.subscriptionRenew());
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }
}
