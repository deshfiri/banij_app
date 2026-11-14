import 'dart:convert';
import 'package:dio/dio.dart';

import '../../../networks/dio/dio.dart';
import '../../../networks/endpoints.dart';
import '../../../networks/exception_handler/data_source.dart';
import '../model/payment_model.dart';

final class PaymentApi {
  static final PaymentApi _singleton = PaymentApi._internal();
  PaymentApi._internal();
  static PaymentApi get instance => _singleton;

  Future<PaymentMethodResponseModel> getPaymentMethods() async {
    try {
      Response response = await getHttp(EndPoints.payments());

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data is Map<String, dynamic> || response.data is List) {
          return PaymentMethodResponseModel.fromJson(response.data);
        } else if (response.data is String) {
          return PaymentMethodResponseModel.fromRawJson(response.data);
        } else {
          return PaymentMethodResponseModel.fromRawJson(json.encode(response.data));
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

  Future<dynamic> addPayoutMethod(Map<String, dynamic> body) async {
    try {
      Response response = await postHttp(EndPoints.payments(), body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } on DioException catch (dioError) {
      if (dioError.response?.data != null) {
        final data = dioError.response?.data;
        if (data is Map) {
          if (data.containsKey('errors') && data['errors'] is Map) {
            final errs = data['errors'] as Map;
            if (errs.isNotEmpty) {
              final firstVal = errs.values.first;
              if (firstVal is List && firstVal.isNotEmpty) {
                throw Exception(firstVal.first.toString());
              } else if (firstVal is String) {
                throw Exception(firstVal);
              }
            }
          }
          if (data.containsKey('message')) {
            throw Exception(data['message'].toString());
          } else if (data.containsKey('error')) {
            throw Exception(data['error'].toString());
          }
        }
      }
      rethrow;
    } catch (error) {
      rethrow;
    }
  }
}
