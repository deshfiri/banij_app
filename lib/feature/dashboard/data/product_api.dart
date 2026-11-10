import 'dart:convert';
import 'package:dio/dio.dart';

import '../../../networks/dio/dio.dart';
import '../../../networks/endpoints.dart';
import '../../../networks/exception_handler/data_source.dart';
import '../model/my_product_model.dart';

final class MyProductApi {
  static final MyProductApi _singleton = MyProductApi._internal();
  MyProductApi._internal();
  static MyProductApi get instance => _singleton;

  Future<MyProductResponseModel> getMyProducts() async {
    try {
      Response response = await getHttp(EndPoints.myProduct());

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data is Map<String, dynamic> || response.data is List) {
          return MyProductResponseModel.fromJson(response.data);
        } else if (response.data is String) {
          return MyProductResponseModel.fromRawJson(response.data);
        } else {
          return MyProductResponseModel.fromRawJson(json.encode(response.data));
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
