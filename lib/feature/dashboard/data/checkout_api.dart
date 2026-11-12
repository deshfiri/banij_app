import 'dart:convert';
import 'package:dio/dio.dart';

import '../../../networks/dio/dio.dart';
import '../../../networks/endpoints.dart';
import '../../../networks/exception_handler/data_source.dart';
import '../model/checkout_model.dart';
import '../model/checkout_response_model.dart';

final class CheckoutApi {
  static final CheckoutApi _singleton = CheckoutApi._internal();
  CheckoutApi._internal();
  static CheckoutApi get instance => _singleton;

  Future<CheckoutResponseModel> getCheckout() async {
    try {
      Response response = await getHttp(EndPoints.checkout());

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data is Map<String, dynamic>) {
          return CheckoutResponseModel.fromJson(response.data);
        } else if (response.data is String) {
          return CheckoutResponseModel.fromRawJson(response.data);
        } else {
          return CheckoutResponseModel.fromRawJson(json.encode(response.data));
        }
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<CheckoutModel> payCheckout(Map<String, dynamic> body) async {
    try {
      Response response = await postHttp(EndPoints.checkout(), body);
      return _parseResponse(response);
    } on DioException catch (dioError) {
      _handleDioError(dioError);
      rethrow;
    } catch (error) {
      rethrow;
    }
  }

  Future<CheckoutModel> applyCoupon(Map<String, dynamic> body) async {
    try {
      Response response = await postHttp(EndPoints.checkoutCoupon(), body);
      return _parseResponse(response);
    } on DioException catch (dioError) {
      _handleDioError(dioError);
      rethrow;
    } catch (error) {
      rethrow;
    }
  }

  Future<CheckoutModel> getPaymentStatus() async {
    try {
      Response response = await getHttp(EndPoints.checkoutPayment());
      return _parseResponse(response);
    } catch (error) {
      rethrow;
    }
  }

  Future<CheckoutModel> verifyPayment(Map<String, dynamic> body) async {
    try {
      Response response = await postHttp(EndPoints.checkoutPaymentVerify(), body);
      return _parseResponse(response);
    } on DioException catch (dioError) {
      _handleDioError(dioError);
      rethrow;
    } catch (error) {
      rethrow;
    }
  }

  CheckoutModel _parseResponse(Response response) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      if (response.data is Map<String, dynamic>) {
        return CheckoutModel.fromJson(response.data);
      } else if (response.data is String) {
        return CheckoutModel.fromRawJson(response.data);
      } else {
        return CheckoutModel.fromRawJson(json.encode(response.data));
      }
    } else {
      throw DataSource.DEFAULT.getFailure();
    }
  }

  void _handleDioError(DioException dioError) {
    if (dioError.response?.data != null) {
      final data = dioError.response?.data;
      if (data is Map) {
        if (data.containsKey('message')) {
          throw Exception(data['message'].toString());
        } else if (data.containsKey('error')) {
          throw Exception(data['error'].toString());
        }
      }
    }
  }
}
