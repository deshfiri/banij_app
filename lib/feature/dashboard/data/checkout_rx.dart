import 'package:rxdart/rxdart.dart';

import '../../../networks/rx_base.dart';
import '../model/checkout_model.dart';
import '../model/checkout_response_model.dart';
import 'checkout_api.dart';

final class CheckoutRx extends RxResponseInt<CheckoutModel> {
  final CheckoutApi _api = CheckoutApi.instance;

  final BehaviorSubject<CheckoutResponseModel> checkoutDataFetcher =
      BehaviorSubject<CheckoutResponseModel>.seeded(CheckoutResponseModel());

  ValueStream get getCheckoutResponseStream => checkoutDataFetcher.stream;

  CheckoutRx()
      : super(
          empty: CheckoutModel(),
          dataFetcher: BehaviorSubject<CheckoutModel>(),
        );

  ValueStream get getCheckoutData => dataFetcher.stream;

  /// `GET /checkout`, optionally previewing [coupon].
  Future<CheckoutResponseModel> fetchCheckoutDetails({String? coupon}) async {
    try {
      CheckoutResponseModel data = await _api.getCheckout(coupon: coupon);
      checkoutDataFetcher.sink.add(data);
      return data;
    } catch (error) {
      checkoutDataFetcher.sink.addError(error);
      rethrow;
    }
  }

  Future<CheckoutModel> pay(Map<String, dynamic> body) async {
    try {
      CheckoutModel data = await _api.payCheckout(body);
      return handleSuccessWithReturn(data);
    } catch (error) {
      return handleErrorWithReturn(error);
    }
  }

  Future<CheckoutModel> coupon(Map<String, dynamic> body) async {
    try {
      CheckoutModel data = await _api.applyCoupon(body);
      return handleSuccessWithReturn(data);
    } catch (error) {
      return handleErrorWithReturn(error);
    }
  }

  Future<CheckoutModel> paymentStatus() async {
    try {
      CheckoutModel data = await _api.getPaymentStatus();
      return handleSuccessWithReturn(data);
    } catch (error) {
      return handleErrorWithReturn(error);
    }
  }

  /// `POST /checkout/payment/verify` (no body).
  Future<CheckoutModel> verify() async {
    try {
      CheckoutModel data = await _api.verifyPayment();
      return handleSuccessWithReturn(data);
    } catch (error) {
      return handleErrorWithReturn(error);
    }
  }
}
