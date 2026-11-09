import 'package:rxdart/rxdart.dart';

import '../../../networks/rx_base.dart';
import '../model/package_model.dart';
import 'package_api.dart';

final class PackageRx extends RxResponseInt<PackageResponseModel> {
  final PackageApi _api = PackageApi.instance;

  PackageRx()
      : super(
          empty: PackageResponseModel(success: false, message: ''),
          dataFetcher: BehaviorSubject<PackageResponseModel>(),
        );

  ValueStream get getPackageData => dataFetcher.stream;

  Future<PackageResponseModel> fetchPackages() async {
    try {
      PackageResponseModel data = await _api.getPackages();
      return handleSuccessWithReturn(data);
    } catch (error) {
      return handleErrorWithReturn(error);
    }
  }
}
