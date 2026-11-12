import 'package:rxdart/rxdart.dart';

import '../../../networks/rx_base.dart';
import '../model/withdrawal_list_model.dart';
import 'withdrawal_list_api.dart';

final class WithdrawalListRx extends RxResponseInt<WithdrawalListResponseModel> {
  static final WithdrawalListRx _singleton = WithdrawalListRx._internal();
  final WithdrawalListApi _api = WithdrawalListApi.instance;

  WithdrawalListRx._internal()
      : super(
          empty: WithdrawalListResponseModel(),
          dataFetcher: BehaviorSubject<WithdrawalListResponseModel>(),
        );
  static WithdrawalListRx get instance => _singleton;

  ValueStream get getWithdrawalListData => dataFetcher.stream;

  Future<WithdrawalListResponseModel> fetchWithdrawalList() async {
    try {
      WithdrawalListResponseModel data = await _api.getWithdrawalList();
      return handleSuccessWithReturn(data);
    } catch (error) {
      return handleErrorWithReturn(error);
    }
  }
}
