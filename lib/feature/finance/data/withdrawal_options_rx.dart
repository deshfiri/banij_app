import 'package:rxdart/rxdart.dart';

import '../../../networks/rx_base.dart';
import '../model/withdrawal_options_model.dart';
import 'withdrawal_options_api.dart';

final class WithdrawalOptionsRx extends RxResponseInt<WithdrawalOptionsModel> {
  static final WithdrawalOptionsRx _singleton = WithdrawalOptionsRx._internal();
  final WithdrawalOptionsApi _api = WithdrawalOptionsApi.instance;

  WithdrawalOptionsRx._internal()
      : super(
          empty: WithdrawalOptionsModel(),
          dataFetcher: BehaviorSubject<WithdrawalOptionsModel>(),
        );
  static WithdrawalOptionsRx get instance => _singleton;

  ValueStream get getWithdrawalOptionsData => dataFetcher.stream;

  Future<WithdrawalOptionsModel> fetchWithdrawalOptions() async {
    try {
      WithdrawalOptionsModel data = await _api.getWithdrawalOptions();
      return handleSuccessWithReturn(data);
    } catch (error) {
      return handleErrorWithReturn(error);
    }
  }
}
