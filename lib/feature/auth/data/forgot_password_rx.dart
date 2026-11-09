import 'package:rxdart/rxdart.dart';

import '../../../networks/rx_base.dart';
import '../model/response_model.dart';
import 'forgot_password_api.dart';

final class ForgotPasswordRx extends RxResponseInt<ForgotPasswordResponse> {
  final ForgotPasswordApi _api = ForgotPasswordApi.instance;

  ForgotPasswordRx()
      : super(
          empty: ForgotPasswordResponse(success: false, message: ''),
          dataFetcher: BehaviorSubject<ForgotPasswordResponse>(),
        );

  ValueStream get getForgotPasswordData => dataFetcher.stream;

  Future<ForgotPasswordResponse> sendForgotPassword({required String email}) async {
    try {
      ForgotPasswordResponse data = await _api.forgotPassword(email: email);
      return handleSuccessWithReturn(data);
    } catch (error) {
      return handleErrorWithReturn(error);
    }
  }
}
