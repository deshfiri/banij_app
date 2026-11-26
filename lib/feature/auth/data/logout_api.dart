import 'package:dio/dio.dart';

import '../../../constants/app_constants.dart';
import '../../../helpers/di.dart';
import '../../../networks/dio/dio.dart';
import '../../../networks/endpoints.dart';
import '../../../networks/exception_handler/data_source.dart';
import '../model/response_model.dart';

final class LogoutApi {
  static final LogoutApi _singleton = LogoutApi._internal();
  LogoutApi._internal();
  static LogoutApi get instance => _singleton;

  Future<RegisterResponse> logout() async {
    try {
      // A supplier session is revoked on the supplier endpoint.
      final isSupplier = appData.read(kKeyIsSupplier) == true;
      Response response = await postHttp(isSupplier ? EndPoints.supplierLogout() : EndPoints.logout());

      if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204) {
        if (response.data != null && response.data is Map<String, dynamic>) {
          return RegisterResponse.fromJson(response.data);
        } else {
          return RegisterResponse(success: true, message: 'Logged out successfully');
        }
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (error) {
      rethrow;
    }
  }
}
