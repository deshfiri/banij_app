import 'package:rxdart/rxdart.dart';

import '../../../networks/rx_base.dart';
import '../model/two_factor_challenge_model.dart';
import 'two_factor_challenge_api.dart';

final class TwoFactorChallengeRx extends RxResponseInt<TwoFactorChallengeModel> {
  static final TwoFactorChallengeRx _singleton = TwoFactorChallengeRx._internal();
  final TwoFactorChallengeApi _api = TwoFactorChallengeApi.instance;

  TwoFactorChallengeRx._internal()
      : super(
          empty: TwoFactorChallengeModel(),
          dataFetcher: BehaviorSubject<TwoFactorChallengeModel>(),
        );
  static TwoFactorChallengeRx get instance => _singleton;

  ValueStream get getTwoFactorData => dataFetcher.stream;

  Future<TwoFactorChallengeModel> verifyTwoFactor(Map<String, dynamic> body) async {
    try {
      TwoFactorChallengeModel data = await _api.verifyTwoFactor(body);
      return handleSuccessWithReturn(data);
    } catch (error) {
      return handleErrorWithReturn(error);
    }
  }
}
