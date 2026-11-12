import 'dart:convert';
import 'package:dio/dio.dart';

import '../../../networks/dio/dio.dart';
import '../../../networks/endpoints.dart';
import '../../../networks/exception_handler/data_source.dart';
import '../model/location_division_model.dart';

final class LocationChildApi {
  static final LocationChildApi _singleton = LocationChildApi._internal();
  LocationChildApi._internal();
  static LocationChildApi get instance => _singleton;

  Future<LocationDivisionModel> getLocationChildren(String type, String sourceId) async {
    try {
      Response response = await getHttp(EndPoints.locationChild(type, sourceId));

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data is Map<String, dynamic>) {
          return LocationDivisionModel.fromJson(response.data);
        } else if (response.data is String) {
          return LocationDivisionModel.fromRawJson(response.data);
        } else {
          return LocationDivisionModel.fromRawJson(json.encode(response.data));
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
