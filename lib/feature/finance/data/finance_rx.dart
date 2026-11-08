import 'package:rxdart/rxdart.dart';

import '../../../networks/rx_base.dart';
import '../model/finance_model.dart';
import 'finance_api.dart';

final class FinanceRx extends RxResponseInt<FinanceModel> {
  final FinanceApi _api = FinanceApi.instance;

  FinanceRx()
      : super(
          empty: FinanceModel(success: false, message: ''),
          dataFetcher: BehaviorSubject<FinanceModel>(),
        );

  ValueStream get getFinanceData => dataFetcher.stream;

  Future<FinanceModel> fetchInvoices() async {
    try {
      FinanceModel data = await _api.getInvoicesList();
      return handleSuccessWithReturn(data);
    } catch (error) {
      return handleErrorWithReturn(error);
    }
  }

  Future<FinanceModel> fetchReceipts() async {
    try {
      FinanceModel data = await _api.getReceiptsList();
      return handleSuccessWithReturn(data);
    } catch (error) {
      return handleErrorWithReturn(error);
    }
  }

  Future<FinanceModel> fetchInvoiceDetail(String id) async {
    try {
      FinanceModel data = await _api.getInvoiceDetail(id);
      return handleSuccessWithReturn(data);
    } catch (error) {
      return handleErrorWithReturn(error);
    }
  }

  Future<FinanceModel> fetchReceiptDetail(String id) async {
    try {
      FinanceModel data = await _api.getReceiptDetail(id);
      return handleSuccessWithReturn(data);
    } catch (error) {
      return handleErrorWithReturn(error);
    }
  }
}

final financeRxObj = FinanceRx();
