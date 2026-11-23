import 'package:rxdart/rxdart.dart';

import '../../../networks/rx_base.dart';
import '../model/invoice_list_model.dart';
import 'invoice_api.dart';

final class InvoiceRx extends RxResponseInt<InvoiceListResponseModel> {
  static final InvoiceRx _singleton = InvoiceRx._internal();
  final InvoiceApi _api = InvoiceApi.instance;

  InvoiceRx._internal()
    : super(
        empty: const InvoiceListResponseModel(),
        dataFetcher: BehaviorSubject<InvoiceListResponseModel>(),
      );

  static InvoiceRx get instance => _singleton;

  ValueStream<InvoiceListResponseModel> get getInvoiceData =>
      dataFetcher.stream;

  Future<InvoiceListResponseModel> fetchInvoices() async {
    try {
      final data = await _api.getInvoices();
      return handleSuccessWithReturn(data);
    } catch (error) {
      return handleErrorWithReturn(error);
    }
  }
}
