import 'dart:convert';
import 'package:dio/dio.dart';

import '../../../networks/dio/dio.dart';
import '../../../networks/exception_handler/data_source.dart';
import '../model/catalog_model.dart';

final class CatalogApi {
  static final CatalogApi _singleton = CatalogApi._internal();
  CatalogApi._internal();
  static CatalogApi get instance => _singleton;

  Future<CatalogResponseModel> getCatalogProducts(
      String endpoint, {Map<String, dynamic>? queryParameters}) async {
    try {
      String finalEndpoint = endpoint;
      if (queryParameters != null && queryParameters.isNotEmpty) {
        // Construct query parameters cleanly
        final queryString = queryParameters.entries
            .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value.toString())}')
            .join('&');
        finalEndpoint = '$endpoint?$queryString';
      }

      Response response = await getHttp(finalEndpoint);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data is Map<String, dynamic>) {
          return CatalogResponseModel.fromJson(response.data);
        } else if (response.data is String) {
          return CatalogResponseModel.fromRawJson(response.data);
        } else {
          return CatalogResponseModel.fromRawJson(json.encode(response.data));
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
