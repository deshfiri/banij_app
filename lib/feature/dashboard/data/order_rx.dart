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

  Future<OrderResponseModel> fetchOrders() async {
    try {
      OrderResponseModel data = await _api.getOrders();
      return handleSuccessWithReturn(data);
    } catch (error) {
      return handleErrorWithReturn(error);
    }
  }
}
