import 'dart:convert';
import 'package:dio/dio.dart';

import '../../../networks/dio/dio.dart';
import '../../../networks/endpoints.dart';
import '../../../networks/exception_handler/data_source.dart';
import '../model/website_model.dart';

final class WebsiteApi {
  static final WebsiteApi _singleton = WebsiteApi._internal();
  WebsiteApi._internal();
  static WebsiteApi get instance => _singleton;

  Future<MyWebsitesResponseModel> getWebsites() async {
    try {
      Response response = await getHttp(EndPoints.websites());

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data is Map<String, dynamic> || response.data is List) {
          return MyWebsitesResponseModel.fromJson(response.data);
        } else if (response.data is String) {
          return MyWebsitesResponseModel.fromRawJson(response.data);
        } else {
          return MyWebsitesResponseModel.fromRawJson(json.encode(response.data));
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

  Future<Response> postWebsite(Map<String, dynamic> body) async {
    try {
      Response response = await postHttp(EndPoints.websites(), body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response;
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
