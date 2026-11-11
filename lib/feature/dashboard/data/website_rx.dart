import 'package:rxdart/rxdart.dart';

import '../../../networks/rx_base.dart';
import '../model/website_model.dart';
import 'website_api.dart';

final class WebsiteRx extends RxResponseInt<MyWebsitesResponseModel> {
  final WebsiteApi _api = WebsiteApi.instance;

  WebsiteRx()
      : super(
          empty: MyWebsitesResponseModel(data: [], allocations: []),
          dataFetcher: BehaviorSubject<MyWebsitesResponseModel>(),
        );

  ValueStream get getWebsiteData => dataFetcher.stream;

  Future<MyWebsitesResponseModel> fetchWebsites() async {
    try {
      MyWebsitesResponseModel data = await _api.getWebsites();
      return handleSuccessWithReturn(data);
    } catch (error) {
      return handleErrorWithReturn(error);
    }
  }
}
