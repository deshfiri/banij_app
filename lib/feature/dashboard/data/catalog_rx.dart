import 'package:rxdart/rxdart.dart';

import '../../../networks/rx_base.dart';
import '../model/catalog_model.dart';
import 'catalog_api.dart';

final class CatalogRx extends RxResponseInt<CatalogResponseModel> {
  final CatalogApi _api = CatalogApi.instance;

  CatalogRx()
      : super(
          empty: CatalogResponseModel(),
          dataFetcher: BehaviorSubject<CatalogResponseModel>(),
        );

  ValueStream<CatalogResponseModel> get getCatalogData => dataFetcher.stream;

  Future<CatalogResponseModel> fetchCatalogProducts(String endpoint) async {
    try {
      CatalogResponseModel data = await _api.getCatalogProducts(endpoint);
      return handleSuccessWithReturn(data);
    } catch (error) {
      return handleErrorWithReturn(error);
    }
  }
}
