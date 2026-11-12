import 'package:rxdart/rxdart.dart';

import '../../../networks/rx_base.dart';
import '../model/bank_model.dart';
import 'bank_api.dart';

final class BankRx extends RxResponseInt<BankResponseModel> {
  static final BankRx _singleton = BankRx._internal();
  final BankApi _api = BankApi.instance;
  BankRx._internal()
      : super(
          empty: BankResponseModel(),
          dataFetcher: BehaviorSubject<BankResponseModel>(),
        );
  static BankRx get instance => _singleton;

  ValueStream get getBankData => dataFetcher.stream;

  Future<BankResponseModel> fetchBankList() async {
    try {
      BankResponseModel data = await _api.getBanks();
      return handleSuccessWithReturn(data);
    } catch (error) {
      return handleErrorWithReturn(error);
    }
  }
}
