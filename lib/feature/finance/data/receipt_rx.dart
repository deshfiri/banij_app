import 'package:rxdart/rxdart.dart';

import '../../../networks/rx_base.dart';
import '../model/receipt_list_model.dart';
import 'receipt_api.dart';

final class ReceiptRx extends RxResponseInt<ReceiptListResponseModel> {
  static final ReceiptRx _singleton = ReceiptRx._internal();
  final ReceiptApi _api = ReceiptApi.instance;

  ReceiptRx._internal()
    : super(
        empty: const ReceiptListResponseModel(),
        dataFetcher: BehaviorSubject<ReceiptListResponseModel>(),
      );

  static ReceiptRx get instance => _singleton;

  ValueStream<ReceiptListResponseModel> get getReceiptData =>
      dataFetcher.stream;

  Future<ReceiptListResponseModel> fetchReceipts() async {
    try {
      final data = await _api.getReceipts();
      return handleSuccessWithReturn(data);
    } catch (error) {
      return handleErrorWithReturn(error);
    }
  }
}
