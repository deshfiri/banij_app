import 'package:rxdart/rxdart.dart';

import '../../../networks/rx_base.dart';
import '../model/address_model.dart';
import 'address_api.dart';

final class AddressRx extends RxResponseInt<AddressResponseModel> {
  final AddressApi _api = AddressApi.instance;

  AddressRx()
      : super(
          empty: AddressResponseModel(data: []),
          dataFetcher: BehaviorSubject<AddressResponseModel>(),
        );

  ValueStream get getAddressData => dataFetcher.stream;

  Future<AddressResponseModel> fetchAddresses() async {
    try {
      AddressResponseModel data = await _api.getAddresses();
      return handleSuccessWithReturn(data);
    } catch (error) {
      return handleErrorWithReturn(error);
    }
  }
}
