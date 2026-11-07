import 'package:rxdart/rxdart.dart';

import '../../../networks/rx_base.dart';
import '../model/business_model.dart';
import 'business_api.dart';

final class BusinessRx extends RxResponseInt<BusinessModel> {
  final BusinessApi _api = BusinessApi.instance;

  BusinessRx()
      : super(
          empty: BusinessModel(success: false, message: ''),
          dataFetcher: BehaviorSubject<BusinessModel>(),
        );

  ValueStream get getBusinessData => dataFetcher.stream;

  Future<BusinessModel> postKyc(Map<String, dynamic> kycData) async {
    try {
      BusinessModel data = await _api.submitKyc(kycData);
      return handleSuccessWithReturn(data);
    } catch (error) {
      return handleErrorWithReturn(error);
    }
  }

  Future<BusinessModel> fetchKycStatus() async {
    try {
      BusinessModel data = await _api.getKycStatus();
      return handleSuccessWithReturn(data);
    } catch (error) {
      return handleErrorWithReturn(error);
    }
  }
}
