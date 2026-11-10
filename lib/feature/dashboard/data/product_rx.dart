import 'package:rxdart/rxdart.dart';

import '../../../networks/rx_base.dart';
import '../model/my_product_model.dart';
import 'product_api.dart';

final class MyProductRx extends RxResponseInt<MyProductResponseModel> {
  final MyProductApi _api = MyProductApi.instance;

  MyProductRx()
      : super(
          empty: MyProductResponseModel(success: false, message: ''),
          dataFetcher: BehaviorSubject<MyProductResponseModel>(),
        );

  ValueStream get getMyProductData => dataFetcher.stream;

  Future<MyProductResponseModel> fetchProducts(String endpoint) async {
    try {
      MyProductResponseModel data = await _api.getProducts(endpoint);
      return handleSuccessWithReturn(data);
    } catch (error) {
      return handleErrorWithReturn(error);
    }
  }
}
