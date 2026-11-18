import 'package:rxdart/rxdart.dart';

import '../../../networks/rx_base.dart';
import '../model/wholesale_checkout_model.dart';
import 'wholesale_checkout_api.dart';

final class WholesaleCheckoutRx extends RxResponseInt<WholesaleCheckoutResponseModel> {
  final WholesaleCheckoutApi _api = WholesaleCheckoutApi.instance;

  WholesaleCheckoutRx()
      : super(
          empty: WholesaleCheckoutResponseModel(),
          dataFetcher: BehaviorSubject<WholesaleCheckoutResponseModel>(),
        );

  ValueStream<WholesaleCheckoutResponseModel> get getCheckoutData => dataFetcher.stream;

  Future<WholesaleCheckoutResponseModel> fetchCheckout() async {
    try {
      WholesaleCheckoutResponseModel data = await _api.getCheckout();
      return handleSuccessWithReturn(data);
    } catch (error) {
      return handleErrorWithReturn(error);
    }
  }

  Future<WholesaleCheckoutResponseModel> applyCoupon(String couponCode) async {
    try {
      WholesaleCheckoutResponseModel data = await _api.applyCoupon(couponCode);
      return handleSuccessWithReturn(data);
    } catch (error) {
      return handleErrorWithReturn(error);
    }
  }

  Future<WholesaleCheckoutResponseModel> removeCoupon() async {
    try {
      WholesaleCheckoutResponseModel data = await _api.removeCoupon();
      return handleSuccessWithReturn(data);
    } catch (error) {
      return handleErrorWithReturn(error);
    }
  }

  Future<WholesaleCheckoutResponseModel> selectAddress(String addressId) async {
    try {
      WholesaleCheckoutResponseModel data = await _api.selectAddress(addressId);
      return handleSuccessWithReturn(data);
    } catch (error) {
      return handleErrorWithReturn(error);
    }
  }

  Future<WholesaleCheckoutResponseModel> saveTypeAddress(String type, Map<String, dynamic> body) async {
    try {
      WholesaleCheckoutResponseModel data = await _api.saveTypeAddress(type, body);
      return handleSuccessWithReturn(data);
    } catch (error) {
      return handleErrorWithReturn(error);
    }
  }

  Future<WholesaleCheckoutResponseModel> confirmOrder() async {
    try {
      WholesaleCheckoutResponseModel data = await _api.confirmOrder();
      return handleSuccessWithReturn(data);
    } catch (error) {
      return handleErrorWithReturn(error);
    }
  }

  Future<WholesaleCheckoutResponseModel> withdrawConfirmation() async {
    try {
      WholesaleCheckoutResponseModel data = await _api.withdrawConfirmation();
      return handleSuccessWithReturn(data);
    } catch (error) {
      return handleErrorWithReturn(error);
    }
  }
}
