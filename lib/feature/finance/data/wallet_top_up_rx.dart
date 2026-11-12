import 'package:rxdart/rxdart.dart';

import '../../../networks/rx_base.dart';
import '../model/wallet_top_up_model.dart';
import 'wallet_top_up_api.dart';

final class WalletTopUpRx extends RxResponseInt<WalletTopUpModel> {
  static final WalletTopUpRx _singleton = WalletTopUpRx._internal();
  final WalletTopUpApi _api = WalletTopUpApi.instance;

  WalletTopUpRx._internal()
      : super(
          empty: WalletTopUpModel(),
          dataFetcher: BehaviorSubject<WalletTopUpModel>(),
        );
  static WalletTopUpRx get instance => _singleton;

  ValueStream get getWalletTopUpData => dataFetcher.stream;

  Future<WalletTopUpModel> topUpWallet(Map<String, dynamic> body) async {
    try {
      WalletTopUpModel data = await _api.topUpWallet(body);
      return handleSuccessWithReturn(data);
    } catch (error) {
      return handleErrorWithReturn(error);
    }
  }
}
