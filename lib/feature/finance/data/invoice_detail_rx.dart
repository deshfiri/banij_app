import 'package:rxdart/rxdart.dart';

import '../../../networks/rx_base.dart';
import '../model/invoice_detail_model.dart';
import 'invoice_detail_api.dart';

final class InvoiceDetailRx extends RxResponseInt<InvoiceDetailModel> {
  static final InvoiceDetailRx _singleton = InvoiceDetailRx._internal();
  final InvoiceDetailApi _api = InvoiceDetailApi.instance;

  InvoiceDetailRx._internal()
    : super(
        empty: const InvoiceDetailModel(),
        dataFetcher: BehaviorSubject<InvoiceDetailModel>(),
      );

  static InvoiceDetailRx get instance => _singleton;

  ValueStream<InvoiceDetailModel> get getInvoiceDetailData =>
      dataFetcher.stream;

  Future<InvoiceDetailModel> fetchInvoiceDetail(String id) async {
    try {
      final data = await _api.getInvoiceDetail(id);
      return handleSuccessWithReturn(data);
    } catch (error) {
      return handleErrorWithReturn(error);
    }
  }
}
