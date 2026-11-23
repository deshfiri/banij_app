import 'package:dio/dio.dart';

import '../../../networks/dio/dio.dart';
import '../../../networks/endpoints.dart';
import '../../../networks/exception_handler/data_source.dart';
import '../model/receipt_list_model.dart';

final class ReceiptApi {
  static final ReceiptApi _singleton = ReceiptApi._internal();
  ReceiptApi._internal();
  static ReceiptApi get instance => _singleton;

  Future<ReceiptListResponseModel> getReceipts() async {
    try {
      final response = await getHttp(EndPoints.receiptsList());
      if (response.statusCode == 200 || response.statusCode == 201) {
        return ReceiptListResponseModel.fromJson(response.data);
      }
      throw DataSource.DEFAULT.getFailure();
    } on DioException catch (dioError) {
      final data = dioError.response?.data;
      if (data is Map && data['message'] != null) {
        throw Exception(data['message'].toString());
      }
      if (data is Map && data['error'] != null) {
        throw Exception(data['error'].toString());
      }
      rethrow;
    }
  }
}
