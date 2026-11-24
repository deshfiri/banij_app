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

  /// `GET /checkout` — the quote for the chosen package. Pass [coupon] to
  /// preview the total with that code (nothing is stored).
  Future<CheckoutResponseModel> getCheckout({String? coupon}) async {
    try {
      final path = coupon == null || coupon.trim().isEmpty
          ? EndPoints.checkout()
          : '${EndPoints.checkout()}?coupon=${Uri.encodeQueryComponent(coupon.trim())}';
      Response response = await getHttp(path);

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
    } on DioException catch (dioError) {
      _handleDioError(dioError);
      rethrow;
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
    } on DioException catch (dioError) {
      _handleDioError(dioError);
      rethrow;
    } catch (error) {
      rethrow;
    }
  }

  /// `POST /checkout/payment/verify` — no body; asks the gateway about the
  /// open payment by our own reference. Answers like `GET /checkout/payment`.
  Future<CheckoutModel> verifyPayment() async {
    try {
      Response response = await postHttp(EndPoints.checkoutPaymentVerify());
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

  /// Turns an API error into an `Exception(message)`. Prefers the first
  /// field error (e.g. 422 on `gateway` / `coupon`), then `message`/`error`.
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
