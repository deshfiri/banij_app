import 'package:dio/dio.dart';

import '../../../networks/dio/dio.dart';
import '../../../networks/endpoints.dart';
import '../../../networks/exception_handler/data_source.dart';

final class RequestWithdrawalApi {
  static final RequestWithdrawalApi _singleton = RequestWithdrawalApi._internal();
  RequestWithdrawalApi._internal();
  static RequestWithdrawalApi get instance => _singleton;

  Future<dynamic> requestWithdrawal(Map<String, dynamic> body) async {
    try {
      Response response = await postHttp(EndPoints.withdrawals(), body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
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
