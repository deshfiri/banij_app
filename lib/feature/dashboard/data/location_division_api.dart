import 'dart:convert';
import 'package:dio/dio.dart';

import '../../../networks/dio/dio.dart';
import '../../../networks/endpoints.dart';
import '../../../networks/exception_handler/data_source.dart';
import '../model/location_division_model.dart';

final class LocationDivisionApi {
  static final LocationDivisionApi _singleton = LocationDivisionApi._internal();
  LocationDivisionApi._internal();
  static LocationDivisionApi get instance => _singleton;

  Future<LocationDivisionModel> getDivisions() async {
    try {
      Response response = await getHttp(EndPoints.locationDivisions());

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
