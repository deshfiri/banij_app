import 'package:rxdart/rxdart.dart';

import '../../../networks/rx_base.dart';
import '../model/referrals_model.dart';
import 'referrals_api.dart';

final class ReferralsRx extends RxResponseInt<ReferralsModel> {
  static final ReferralsRx _singleton = ReferralsRx._internal();
  final ReferralsApi _api = ReferralsApi.instance;

  ReferralsRx._internal()
      : super(
          empty: ReferralsModel(),
          dataFetcher: BehaviorSubject<ReferralsModel>(),
        );
  static ReferralsRx get instance => _singleton;

  ValueStream get getReferralsData => dataFetcher.stream;

  Future<ReferralsModel> fetchReferrals() async {
    try {
      ReferralsModel data = await _api.getReferrals();
      return handleSuccessWithReturn(data);
    } catch (error) {
      return handleErrorWithReturn(error);
    }
  }
}
