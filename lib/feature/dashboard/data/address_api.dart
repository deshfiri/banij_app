import 'dart:convert';
import 'package:dio/dio.dart';

import '../../../networks/dio/dio.dart';
import '../../../networks/endpoints.dart';
import '../../../networks/exception_handler/data_source.dart';
import '../model/address_model.dart';

final class AddressApi {
  static final AddressApi _singleton = AddressApi._internal();
  AddressApi._internal();
  static AddressApi get instance => _singleton;

  Future<AddressResponseModel> getAddresses() async {
    try {
      Response response = await getHttp(EndPoints.address());

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data is Map<String, dynamic> || response.data is List) {
          return AddressResponseModel.fromJson(response.data);
        } else if (response.data is String) {
          return AddressResponseModel.fromRawJson(response.data);
        } else {
          return AddressResponseModel.fromRawJson(json.encode(response.data));
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

  Future<Response> postAddress(Map<String, dynamic> body) async {
    try {
      Response response = await postHttp(EndPoints.address(), body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response;
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } on DioException catch (dioError) {
      if (dioError.response?.data != null) {
        final data = dioError.response?.data;
        if (data is Map) {
          if (data.containsKey('errors') && data['errors'] is Map) {
            final errors = data['errors'] as Map;
            List<String> errMsgs = [];
            errors.forEach((key, value) {
              if (value is List && value.isNotEmpty) {
                errMsgs.add(value.first.toString());
              } else if (value != null) {
                errMsgs.add(value.toString());
              }
            });
            if (errMsgs.isNotEmpty) {
              throw Exception(errMsgs.join('\n'));
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
