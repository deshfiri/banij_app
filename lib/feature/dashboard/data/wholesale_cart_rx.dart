import 'package:rxdart/rxdart.dart';

import '../../../networks/rx_base.dart';
import '../model/wholesale_cart_model.dart';
import 'wholesale_cart_api.dart';

final class WholesaleCartRx extends RxResponseInt<WholesaleCartModel> {
  final WholesaleCartApi _api = WholesaleCartApi.instance;

  WholesaleCartRx()
      : super(
          empty: WholesaleCartModel(),
          dataFetcher: BehaviorSubject<WholesaleCartModel>(),
        );

  ValueStream get getWholesaleCartData => dataFetcher.stream;

  Future<WholesaleCartModel> fetchCart() async {
    try {
      WholesaleCartModel data = await _api.getCart();
      return handleSuccessWithReturn(data);
    } catch (error) {
      return handleErrorWithReturn(error);
    }
  }

  Future<WholesaleCartModel> addCartItem(Map<String, dynamic> body) async {
    try {
      WholesaleCartModel data = await _api.addCartItem(body);
      return handleSuccessWithReturn(data);
    } catch (error) {
      return handleErrorWithReturn(error);
    }
  }

  Future<WholesaleCartModel> updateCartItemQuantity(String item, Map<String, dynamic> body) async {
    try {
      WholesaleCartModel data = await _api.updateCartItemQuantity(item, body);
      return handleSuccessWithReturn(data);
    } catch (error) {
      return handleErrorWithReturn(error);
    }
  }

  Future<WholesaleCartModel> deleteCartItem(String item) async {
    try {
      WholesaleCartModel data = await _api.deleteCartItem(item);
      return handleSuccessWithReturn(data);
    } catch (error) {
      return handleErrorWithReturn(error);
    }
  }

  Future<WholesaleCartModel> acceptCartPrices() async {
    try {
      WholesaleCartModel data = await _api.acceptCartPrices();
      return handleSuccessWithReturn(data);
    } catch (error) {
      return handleErrorWithReturn(error);
    }
  }
}
