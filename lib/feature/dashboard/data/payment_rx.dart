import 'package:rxdart/rxdart.dart';

import '../../../networks/rx_base.dart';
import '../model/payment_model.dart';
import 'payment_api.dart';

final class PaymentRx extends RxResponseInt<PaymentMethodResponseModel> {
  final PaymentApi _api = PaymentApi.instance;

  PaymentRx()
      : super(
          empty: PaymentMethodResponseModel(data: []),
          dataFetcher: BehaviorSubject<PaymentMethodResponseModel>(),
        );

  ValueStream get getPaymentData => dataFetcher.stream;

  Future<PaymentMethodResponseModel> fetchPaymentMethods() async {
    try {
      PaymentMethodResponseModel data = await _api.getPaymentMethods();
      return handleSuccessWithReturn(data);
    } catch (error) {
      return handleErrorWithReturn(error);
    }
  }
}
