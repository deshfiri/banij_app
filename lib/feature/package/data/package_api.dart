import 'dart:convert';
import 'package:dio/dio.dart';

import '../../../networks/dio/dio.dart';
import '../../../networks/endpoints.dart';
import '../../../networks/exception_handler/data_source.dart';
import '../model/package_model.dart';

final class PackageApi {
  static final PackageApi _singleton = PackageApi._internal();
  PackageApi._internal();
  static PackageApi get instance => _singleton;

  Future<PackageResponseModel> getPackages() async {
    try {
      Response response = await getHttp(EndPoints.package());

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data is Map<String, dynamic>) {
          return PackageResponseModel.fromJson(response.data);
        } else if (response.data is String) {
          return PackageResponseModel.fromRawJson(response.data);
        } else {
          return PackageResponseModel.fromRawJson(json.encode(response.data));
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
