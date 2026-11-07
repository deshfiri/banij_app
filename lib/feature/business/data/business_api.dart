import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../networks/dio/dio.dart';
import '../../../networks/endpoints.dart';
import '../../../networks/exception_handler/data_source.dart';
import '../model/business_model.dart';

final class BusinessApi {
  static final BusinessApi _singleton = BusinessApi._internal();
  BusinessApi._internal();
  static BusinessApi get instance => _singleton;

  Future<BusinessModel> submitKyc(Map<String, dynamic> kycData) async {
    try {
      Response response = await postHttp(EndPoints.storePartner(), kycData);

      if (response.statusCode == 200) {
        final data = BusinessModel.fromRawJson(json.encode(response.data));
        return data;
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<BusinessModel> getKycStatus() async {
    try {
      Response response = await getHttp(EndPoints.partnerInformation());

      if (response.statusCode == 200) {
        final data = BusinessModel.fromRawJson(json.encode(response.data));
        return data;
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (error) {
      rethrow;
    }
  }
}
