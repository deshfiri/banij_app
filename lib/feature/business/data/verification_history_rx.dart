import 'package:rxdart/rxdart.dart';

import '../../../networks/rx_base.dart';
import '../model/verification_history_model.dart';
import 'verification_history_api.dart';

final class VerificationHistoryRx extends RxResponseInt<VerificationHistoryResponseModel> {
  final VerificationHistoryApi _api = VerificationHistoryApi.instance;

  VerificationHistoryRx()
      : super(
          empty: VerificationHistoryResponseModel(data: []),
          dataFetcher: BehaviorSubject<VerificationHistoryResponseModel>(),
        );

  ValueStream get getVerificationHistoryData => dataFetcher.stream;

  Future<VerificationHistoryResponseModel> fetchVerificationHistory() async {
    try {
      VerificationHistoryResponseModel data = await _api.getVerificationHistory();
      return handleSuccessWithReturn(data);
    } catch (error) {
      return handleErrorWithReturn(error);
    }
  }
}
