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

  /// Switches the account to [slug] (`POST /packages/{slug}/select`).
  /// Throws with the API's message on failure.
  Future<PackageSelectResultModel> selectPackage(String slug) async {
    try {
      final response = await postHttp(EndPoints.selectPackage(slug));
      if (response.statusCode != 200 && response.statusCode != 201 && response.statusCode != 204) {
        throw DataSource.DEFAULT.getFailure();
      }
      final data = response.data is String && (response.data as String).isNotEmpty
          ? json.decode(response.data)
          : response.data;
      return PackageSelectResultModel.fromJson(data);
    } on DioException catch (dioError) {
      final data = dioError.response?.data;
      if (data is Map && data['message'] != null) throw Exception(data['message'].toString());
      if (data is Map && data['error'] != null) throw Exception(data['error'].toString());
      rethrow;
    }
  }
}
