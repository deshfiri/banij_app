import 'package:rxdart/rxdart.dart';

import '../../../networks/rx_base.dart';
import '../model/order_model.dart';
import 'order_api.dart';

final class OrderRx extends RxResponseInt<OrderResponseModel> {
  final OrderApi _api = OrderApi.instance;

  OrderRx()
      : super(
          empty: OrderResponseModel(success: false, message: ''),
          dataFetcher: BehaviorSubject<OrderResponseModel>(),
        );

  ValueStream get getOrderData => dataFetcher.stream;

  Future<OrderResponseModel> fetchOrders([String? endpoint, Map<String, dynamic>? queryParameters]) async {
    try {
      OrderResponseModel data = await _api.getOrders(endpoint, queryParameters);
      return handleSuccessWithReturn(data);
    } catch (error) {
      return handleErrorWithReturn(error);
    }
  }

  Future<OrderItemModel> fetchOrderDetail(String orderId) async {
    return await _api.getOrderDetail(orderId);
  }

  Future<bool> cancelStoreOrder(String orderId, {String? reason}) async {
    return await _api.cancelStoreOrder(orderId, reason: reason);
  }

  Future<bool> exportOrders() async {
    return await _api.exportOrders();
  }
}
