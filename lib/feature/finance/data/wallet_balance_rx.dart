import 'package:rxdart/rxdart.dart';

import '../../../networks/rx_base.dart';
import '../model/wallet_balance_model.dart';
import 'wallet_balance_api.dart';

final class WalletBalanceRx extends RxResponseInt<WalletBalanceResponseModel> {
  static final WalletBalanceRx _singleton = WalletBalanceRx._internal();
  final WalletBalanceApi _api = WalletBalanceApi.instance;

  WalletBalanceRx._internal()
      : super(
          empty: WalletBalanceResponseModel(),
          dataFetcher: BehaviorSubject<WalletBalanceResponseModel>(),
        );
  static WalletBalanceRx get instance => _singleton;

  ValueStream get getWalletBalanceData => dataFetcher.stream;

  Future<WalletBalanceResponseModel> fetchWalletBalance() async {
    try {
      WalletBalanceResponseModel data = await _api.getWalletBalance();
      return handleSuccessWithReturn(data);
    } catch (error) {
      return handleErrorWithReturn(error);
    }
  }
}
