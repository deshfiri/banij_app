import 'dart:convert';
import 'package:dio/dio.dart';

import '../../../networks/dio/dio.dart';
import '../../../networks/endpoints.dart';
import '../../../networks/exception_handler/data_source.dart';
import '../model/wholesale_checkout_model.dart';

final class WholesaleCheckoutApi {
  static final WholesaleCheckoutApi _singleton = WholesaleCheckoutApi._internal();
  WholesaleCheckoutApi._internal();
  static WholesaleCheckoutApi get instance => _singleton;

  Future<WholesaleCheckoutResponseModel> getCheckout() async {
    try {
      Response response = await getHttp(EndPoints.wholesaleCheckout());

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data is Map<String, dynamic>) {
          return WholesaleCheckoutResponseModel.fromJson(response.data);
        } else if (response.data is String) {
          return WholesaleCheckoutResponseModel.fromRawJson(response.data);
        } else {
          return WholesaleCheckoutResponseModel.fromRawJson(json.encode(response.data));
        }
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } on DioException catch (dioError) {
      _handleDioError(dioError);
      rethrow;
    } catch (error) {
      rethrow;
    }
  }

  Future<WholesaleCheckoutResponseModel> applyCoupon(String couponCode) async {
    try {
      final body = {"coupon": couponCode};
      Response response = await putHttp(EndPoints.wholesaleCheckoutCoupon(), body);
      return _parseResponse(response);
    } on DioException catch (dioError) {
      _handleDioError(dioError);
      rethrow;
    } catch (error) {
      rethrow;
    }
  }

  Future<WholesaleCheckoutResponseModel> removeCoupon() async {
    try {
      Response response = await deleteHttp(EndPoints.wholesaleCheckoutCoupon());
      return _parseResponse(response);
    } on DioException catch (dioError) {
      _handleDioError(dioError);
      rethrow;
    } catch (error) {
      rethrow;
    }
  }

  Future<WholesaleCheckoutResponseModel> selectAddress(String addressId) async {
    try {
      final body = {"address": addressId};
      Response response = await putHttp(EndPoints.wholesaleCheckoutAddress(), body);
      return _parseResponse(response);
    } on DioException catch (dioError) {
      _handleDioError(dioError);
      rethrow;
    } catch (error) {
      rethrow;
    }
  }

  Future<WholesaleCheckoutResponseModel> saveTypeAddress(String type, Map<String, dynamic> body) async {
    try {
      Response response = await putHttp(EndPoints.wholesaleCheckoutAddresses(type), body);
      return _parseResponse(response);
    } on DioException catch (dioError) {
      _handleDioError(dioError);
      rethrow;
    } catch (error) {
      rethrow;
    }
  }

  /// `POST /wholesale/checkout/confirmation` with the chosen
  /// [paymentMethod] and the quote [fingerprint] (both required).
  Future<WholesaleCheckoutResponseModel> confirmOrder({
    required String paymentMethod,
    required String fingerprint,
  }) async {
    try {
      Response response = await postHttp(EndPoints.wholesaleCheckoutConfirmation(), {
        'payment_method': paymentMethod,
        'fingerprint': fingerprint,
      });
      return _parseResponse(response);
    } on DioException catch (dioError) {
      _handleDioError(dioError);
      rethrow;
    } catch (error) {
      rethrow;
    }
  }

  Future<WholesaleCheckoutResponseModel> withdrawConfirmation() async {
    try {
      Response response = await deleteHttp(EndPoints.wholesaleCheckoutConfirmation());
      return _parseResponse(response);
    } on DioException catch (dioError) {
      _handleDioError(dioError);
      rethrow;
    } catch (error) {
      rethrow;
    }
  }

  WholesaleCheckoutResponseModel _parseResponse(Response response) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      if (response.data is Map<String, dynamic>) {
        return WholesaleCheckoutResponseModel.fromJson(response.data);
      } else if (response.data is String) {
        return WholesaleCheckoutResponseModel.fromRawJson(response.data);
      } else {
        return WholesaleCheckoutResponseModel.fromRawJson(json.encode(response.data));
      }
    } else {
      throw DataSource.DEFAULT.getFailure();
    }
  }

  void _handleDioError(DioException dioError) {
    if (dioError.response?.data != null) {
      final data = dioError.response?.data;
      if (data is Map) {
        final errors = data['errors'];
        if (errors is Map && errors.isNotEmpty) {
          final first = errors.values.first;
          final text = first is List && first.isNotEmpty ? first.first.toString() : first?.toString();
          if (text != null && text.isNotEmpty) throw Exception(text);
        }
        if (data.containsKey('message')) {
          throw Exception(data['message'].toString());
        } else if (data.containsKey('error')) {
          throw Exception(data['error'].toString());
        }
      }
    }
  }
}
