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
        if (response.data is Map) {
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

  /// Cancels the current subscription. Throws with the API message on failure.
  Future<void> cancelSubscription() => _postAction(EndPoints.subscriptionCancel());

  Future<bool> changeSubscription(String newPackageSlug) async {
    try {
      final body = {"package": newPackageSlug};
      Response response = await postHttp(EndPoints.subscriptionChange(), body);
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  /// Renews the current subscription. Throws with the API message on failure.
  Future<void> renewSubscription() => _postAction(EndPoints.subscriptionRenew());

  Future<void> _postAction(String path) async {
    try {
      final response = await postHttp(path);
      if (response.statusCode != 200 && response.statusCode != 201 && response.statusCode != 204) {
        throw DataSource.DEFAULT.getFailure();
      }
    } on DioException catch (dioError) {
      final data = dioError.response?.data;
      if (data is Map && data['message'] != null) throw Exception(data['message'].toString());
      if (data is Map && data['error'] != null) throw Exception(data['error'].toString());
      rethrow;
    }
  }
}
