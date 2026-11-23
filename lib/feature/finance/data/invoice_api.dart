import 'package:dio/dio.dart';

import '../../../networks/dio/dio.dart';
import '../../../networks/endpoints.dart';
import '../../../networks/exception_handler/data_source.dart';
import '../model/invoice_list_model.dart';

final class InvoiceApi {
  static final InvoiceApi _singleton = InvoiceApi._internal();
  InvoiceApi._internal();
  static InvoiceApi get instance => _singleton;

  Future<InvoiceListResponseModel> getInvoices() async {
    try {
      final response = await getHttp(EndPoints.invoice());
      if (response.statusCode == 200 || response.statusCode == 201) {
        return InvoiceListResponseModel.fromJson(response.data);
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
