import 'package:rxdart/rxdart.dart';

import '../../../networks/rx_base.dart';
import '../model/response_model.dart';
import 'login_api.dart';

final class LoginRx extends RxResponseInt<LoginResponse> {
  final LoginApi _api = LoginApi.instance;

  LoginRx()
      : super(
          empty: LoginResponse(success: false, message: ''),
          dataFetcher: BehaviorSubject<LoginResponse>(),
        );

  ValueStream get getLoginData => dataFetcher.stream;

  Future<LoginResponse> userLogin({
    required String email,
    required String password,
  }) async {
    try {
      LoginResponse data = await _api.login(email: email, password: password);
      return handleSuccessWithReturn(data);
    } catch (error) {
      return handleErrorWithReturn(error);
    }
  }
}
