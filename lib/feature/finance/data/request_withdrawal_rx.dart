import 'package:rxdart/rxdart.dart';

import '../../../networks/rx_base.dart';
import 'request_withdrawal_api.dart';

final class RequestWithdrawalRx extends RxResponseInt<dynamic> {
  static final RequestWithdrawalRx _singleton = RequestWithdrawalRx._internal();
  final RequestWithdrawalApi _api = RequestWithdrawalApi.instance;

  RequestWithdrawalRx._internal()
      : super(
          empty: {},
          dataFetcher: BehaviorSubject<dynamic>(),
        );
  static RequestWithdrawalRx get instance => _singleton;

  Future<dynamic> requestWithdrawal(Map<String, dynamic> body) async {
    try {
      var data = await _api.requestWithdrawal(body);
      return handleSuccessWithReturn(data);
    } catch (error) {
      return handleErrorWithReturn(error);
    }
  }
}
