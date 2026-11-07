import 'package:rxdart/rxdart.dart';

import '../../../networks/rx_base.dart';
import '../model/response_model.dart';
import 'register_api.dart';

final class RegisterRx extends RxResponseInt<RegisterResponse> {
  final RegisterApi _api = RegisterApi.instance;

  RegisterRx()
      : super(
          empty: RegisterResponse(success: false, message: ''),
          dataFetcher: BehaviorSubject<RegisterResponse>(),
        );

  ValueStream get getRegisterData => dataFetcher.stream;

  Future<RegisterResponse> userRegister({
    required Map<String, dynamic> registrationData,
  }) async {
    try {
      RegisterResponse data = await _api.register(registrationData: registrationData);
      return handleSuccessWithReturn(data);
    } catch (error) {
      return handleErrorWithReturn(error);
    }
  }
}
