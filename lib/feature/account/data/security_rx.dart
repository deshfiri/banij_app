import 'package:rxdart/rxdart.dart';

import '../../../networks/rx_base.dart';
import '../model/security_model.dart';
import 'security_api.dart';

final class SecurityRx extends RxResponseInt<SecurityModel> {
  final SecurityApi _api = SecurityApi.instance;

  SecurityRx()
      : super(
          empty: SecurityModel(),
          dataFetcher: BehaviorSubject<SecurityModel>(),
        );

  ValueStream get getSecurityData => dataFetcher.stream;

  Future<SecurityModel> fetchSecurityRules() async {
    try {
      SecurityModel data = await _api.getSecurityRules();
      return handleSuccessWithReturn(data);
    } catch (error) {
      return handleErrorWithReturn(error);
    }
  }
}
