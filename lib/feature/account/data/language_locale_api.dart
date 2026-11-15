import 'dart:convert';
import 'package:dio/dio.dart';

import '../../../networks/dio/dio.dart';
import '../../../networks/endpoints.dart';
import '../../../networks/exception_handler/data_source.dart';
import '../model/language_locale_model.dart';

final class LanguageLocaleApi {
  static final LanguageLocaleApi _singleton = LanguageLocaleApi._internal();
  LanguageLocaleApi._internal();
  static LanguageLocaleApi get instance => _singleton;

  Future<LanguageLocaleResponseModel> getLanguageLocale() async {
    try {
      Response response = await getHttp(EndPoints.language());

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data is Map<String, dynamic>) {
          return LanguageLocaleResponseModel.fromJson(response.data);
        } else if (response.data is String) {
          return LanguageLocaleResponseModel.fromRawJson(response.data);
        } else {
          return LanguageLocaleResponseModel.fromRawJson(json.encode(response.data));
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

  Future<LanguageLocaleResponseModel> updateLanguageLocale(Map<String, dynamic> body) async {
    try {
      Response response = await putHttp(EndPoints.language(), body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data is Map<String, dynamic>) {
          return LanguageLocaleResponseModel.fromJson(response.data);
        } else if (response.data is String) {
          return LanguageLocaleResponseModel.fromRawJson(response.data);
        } else {
          return LanguageLocaleResponseModel.fromRawJson(json.encode(response.data));
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
