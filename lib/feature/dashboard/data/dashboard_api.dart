import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../networks/dio/dio.dart';
import '../../../networks/endpoints.dart';
import '../../../networks/exception_handler/data_source.dart';
import '../model/dashboard_model.dart';

final class DashboardApi {
  static final DashboardApi _singleton = DashboardApi._internal();
  DashboardApi._internal();
  static DashboardApi get instance => _singleton;

  Future<DashboardModel> getDashboardStats() async {
    try {
      Response response = await getHttp(EndPoints.profileInfo());

      if (response.statusCode == 200) {
        final data = DashboardModel.fromRawJson(json.encode(response.data));
        return data;
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (error) {
      rethrow;
    }
  }
}
