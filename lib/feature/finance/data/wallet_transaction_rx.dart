import 'package:rxdart/rxdart.dart';

import '../../../networks/rx_base.dart';
import '../model/wallet_transaction_model.dart';
import 'wallet_transaction_api.dart';

final class WalletTransactionRx extends RxResponseInt<WalletTransactionListModel> {
  static final WalletTransactionRx _singleton = WalletTransactionRx._internal();
  final WalletTransactionApi _api = WalletTransactionApi.instance;

  WalletTransactionRx._internal()
      : super(
          empty: WalletTransactionListModel(),
          dataFetcher: BehaviorSubject<WalletTransactionListModel>(),
        );
  static WalletTransactionRx get instance => _singleton;

  ValueStream get getWalletTransactionData => dataFetcher.stream;

  Future<WalletTransactionListModel> fetchWalletTransactions() async {
    try {
      WalletTransactionListModel data = await _api.getWalletTransactions();
      return handleSuccessWithReturn(data);
    } catch (error) {
      return handleErrorWithReturn(error);
    }
  }
}
