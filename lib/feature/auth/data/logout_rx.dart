import 'package:rxdart/rxdart.dart';

import '../../../networks/rx_base.dart';
import '../model/response_model.dart';
import 'logout_api.dart';

final class LogoutRx extends RxResponseInt<RegisterResponse> {
  final LogoutApi _api = LogoutApi.instance;

  LogoutRx()
      : super(
          empty: RegisterResponse(success: false, message: ''),
          dataFetcher: BehaviorSubject<RegisterResponse>(),
        );

  ValueStream get getLogoutData => dataFetcher.stream;

  Future<RegisterResponse> userLogout() async {
    try {
      RegisterResponse data = await _api.logout();
      return handleSuccessWithReturn(data);
    } catch (error) {
      return handleErrorWithReturn(error);
    }
  }
}
