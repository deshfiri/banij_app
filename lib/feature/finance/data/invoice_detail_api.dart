import 'package:dio/dio.dart';

import '../../../networks/dio/dio.dart';
import '../../../networks/endpoints.dart';
import '../../../networks/exception_handler/data_source.dart';
import '../model/invoice_detail_model.dart';

final class InvoiceDetailApi {
  static final InvoiceDetailApi _singleton = InvoiceDetailApi._internal();
  InvoiceDetailApi._internal();
  static InvoiceDetailApi get instance => _singleton;

  Future<InvoiceDetailModel> getInvoiceDetail(String id) async {
    try {
      final response = await getHttp(EndPoints.invoiceDetails(id));
      if (response.statusCode == 200 || response.statusCode == 201) {
        return InvoiceDetailModel.fromJson(response.data);
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
